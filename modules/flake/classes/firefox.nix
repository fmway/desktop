# Assisted by kiro ai
# Battery: firefox-profile
#
# Adds support for managing Firefox (and Firefox-based browser) profiles
# via Home Manager.
#
# Users declare profiles on their user entity:
#
#   den.hosts.x86_64-linux.igloo.users.tux.firefox-profiles = {
#     tux.classes = [ "firefox" "zen" ];
#     tux.zen.variant = "twilight";
#   };
#   # or for standalone home-manager
#   den.homes.x86_64-linux."tux@igloo".firefox-profiles.tux = {  };
#
# Then configure them in the named aspect using the browser class(es):
#
#   den.aspects.tux = {
#     firefox = { pkgs, ... }: {
#       containers.general = { color = "blue"; icon = "fingerprint"; id = 1; };
#     };
#     zen = { pkgs, ... }: {
#       policies.DisableAppUpdate = true;
#     };
#     # parametric on profile context
#     includes = [
#       ({ profile, ... }: {
#         zen.policies.DisableTelemetry = true;
#       })
#     ];
#   };
#
# Den will forward each browser class into:
#   homeManager.programs.<browser>.profiles.<profileName>
#
# Supported classes (built-in to home-manager): firefox, floorp, librewolf
# Special class: zen (requires inputs.zen-browser)
#
# Requirements:
#   - The user must have `homeManager` in their `classes`.
#   - `programs.<browser>.enable = true` must be set in the user's homeManager config.
#   - For `zen` class: `inputs.zen-browser` must be in your flake inputs.

{ den, lib, inputs, ... }: let
  allHosts = lib.concatMap builtins.attrValues (builtins.attrValues den.hosts);
  allHomes = lib.concatMap builtins.attrValues (builtins.attrValues den.homes);
  allUsers = lib.concatMap (h: builtins.attrValues h.users) allHosts;
  allFirefoxProfiles = lib.concatMap (p: builtins.attrValues p.firefox-profiles) (allUsers ++ allHomes);

  deps = map (from: {
    ${from.name} = lib.genAttrs from.classes (_: { });
  }) allFirefoxProfiles;

  # Browser classes that map directly to homeManager.programs.<class>.profiles.<name>
  # These are built-in to home-manager and need no extra module imports.
  builtinBrowserClasses = [
    "firefox"
    "floorp"
    "librewolf"
  ];

  # Classes that need an extra OS-level module imported.
  # Each entry: { class, getModule, optionPath }
  externalBrowserClasses = [
    { class = "zen";
      # zen-browser provides homeModules.<variant>
      # variant defaults to "beta" if not set on the profile
      getModule =
        { user, ... }: let
          variant = user.zen.variant or "beta";
        in inputs.zen-browser.homeModules.${variant} or (
          throw "den: zen-browser variant '${variant}' not found in inputs.zen-browser.homeModules"
        );
      optionPath = "zen-browser";
    }
  ];

  allBrowserClasses = builtinBrowserClasses ++ map (e: e.class) externalBrowserClasses;

  # For builtins it's 1:1; external classes may differ (e.g. zen → zen-browser).
  browserOptionPath =
    browserClass: let
      external = lib.findFirst (e: e.class == browserClass) null externalBrowserClasses;
    in if external != null then external.optionPath else browserClass;

  # The firefox-profile entity type — declared on the user via den.schema.user.
  firefoxProfileType =
    { user, host }:
    lib.types.submodule (
      { name, config, ... }:
      {
        freeformType = lib.types.attrsOf lib.types.anything;
        config._module.args.host = host;
        config._module.args.user = user;
        config._module.args.profile = config;
        options = {
          host = lib.mkOption {
            default = host;
          };
          user = lib.mkOption {
            default = user;
          };
          name = lib.mkOption {
            type = lib.types.str;
            description = "Firefox profile key (attrset name).";
            internal = true; readOnly = true;
            default = name;
          };
          profileName = lib.mkOption {
            type = lib.types.str;
            description = "Profile name used in home-manager (defaults to the attrset key).";
            default = name;
          };
          classes = lib.mkOption {
            type = lib.types.listOf (lib.types.enum allBrowserClasses);
            description = ''
              Browser classes to enable for this profile.
              Each class maps to homeManager.programs.<class>.profiles.<profileName>.

              Built-in (no extra inputs needed): firefox, floorp, librewolf
              External (needs inputs.zen-browser): zen
            '';
            default = [ "firefox" ];
          };
          classAliases = lib.mkOption {
            type = lib.types.attrsOf (lib.types.listOf lib.types.str);
            description = ''
              Map a browser class to additional source classes whose content
              is merged in when resolving that class.

              Useful when you want to reuse config written for one browser
              (e.g. `firefox`) as the base for another (e.g. `zen`):

                den.hosts.x86_64-linux.igloo.users.tux.firefox-profiles.tux = {
                  classes = [ "firefox" "zen" ];
                  # zen also collects firefox class content as its base
                  classAliases.zen = [ "firefox" ];
                };

              The aliased classes are resolved from the same aspect and merged
              (via lib.recursiveUpdate) before the target class content is applied,
              so the target class always wins on conflicts.
            '';
            default = { };
            defaultText = lib.literalExpression "{ }";
            example = lib.literalExpression ''{ zen = [ "firefox" ]; }'';
          };
          aspect = lib.mkOption {
            description = "Aspect that configures this profile (defaults to den.aspects.<name>).";
            type = lib.types.raw;
            defaultText = "den.aspects.<name>";
            readOnly = true;
            default = den.aspects.${config.name};
          };
        };
      }
    );

  # Resolve a single browser class from an aspect (with profile context injected).
  # Returns a lib.mkMerge of the inner module functions extracted from the
  # pipeline-wrapped imports. These are passed directly as the profile value,
  # so the Firefox profile submodule's own module system evaluates them with
  # the correct types, pkgs, lib, etc. — no intermediate evalModules needed.
  resolveBrowserClass =
    { profile, browserClass, profileAspectWithCtx }: let
      resolved = den.lib.aspects.resolve browserClass profileAspectWithCtx;
      # The pipeline wraps each class module as { _file; key; imports = [fn] }.
      # Extract the inner module functions so they can be used as profile values.
      innerModules = lib.concatMap (m: m.imports or [ ]) resolved.imports;
    in lib.mkMerge innerModules;

  # Build a homeManager include aspect for a single profile + browser class.
  # Evaluates the browser class content from the profile's aspect and injects
  # it into homeManager.programs.<browser>.profiles.<profileName>.
  #
  # Aliased classes (profile.classAliases.<browserClass>) are resolved first
  # and merged as a base; the target class content is applied on top.
  #
  # Uses policy.include so the content lands in scopedClassImports (Phase 1),
  # before the hm-user forward runs (Phase 3).
  mkBrowserProfileInclude =
    { profile, browserClass }:
    den.lib.policy.include {
      name = "firefox-profile/${profile.profileName}/${browserClass}";
      homeManager =
        { pkgs, lib, config, osConfig, ... }: let
          # Inject `profile` into the aspect's scope handlers so parametric
          # aspects can use it via `{ profile, ... }:`.
          profileAspectWithCtx = let
            raw = profile.aspect;
            inherit (den.lib.aspects.fx.handlers) constantHandler;
          in if builtins.isAttrs raw then
            raw // {
              __scopeHandlers = (raw.__scopeHandlers or { }) // constantHandler { inherit profile pkgs osConfig; homeConfig = config; };
            }
          else raw;

          resolveClass = cls: resolveBrowserClass { inherit profile profileAspectWithCtx; browserClass = cls; };

          # Resolve aliased classes first (base layer), then the target class on top.
          # lib.mkMerge: later entries win on conflicts, so target class wins.
          aliasedClasses = profile.classAliases.${browserClass} or [ ];
          browserValue = lib.mkMerge (map resolveClass (aliasedClasses ++ [ browserClass ]));

          optPath = browserOptionPath browserClass;
        in {
          # Auto-enable the browser when a profile uses it.
          # lib.mkDefault allows users to override with `programs.<browser>.enable = false`.
          programs.${optPath} = {
            enable = lib.mkDefault true;
            profiles.${profile.profileName} = browserValue;
          };
        };
    };

  # For external browser classes (e.g. zen), also inject the module
  # into the homeManger so the browser is available.
  mkExternalBrowserHostModule =
    { profile, externalEntry, host, user }: let
      hostModule = externalEntry.getModule { inherit profile host user; };
    in den.lib.policy.include {
      name = "firefox-profile/${profile.profileName}/${externalEntry.class}-host-module";
      homeManager.imports = [
        {
          key = "den:firefox-profile-${externalEntry.class}-${profile.profileName}";
          imports = [ hostModule ];
        }
      ];
    };

  # Policy: for each firefox profile declared on the user, inject homeManager
  # content for each enabled browser class.
  toFirefoxProfiles =
    home-or-user:
    { user, host, ... }: let
      profiles = lib.attrValues (home-or-user.firefox-profiles or { });
    in lib.concatMap (
      profile: let
        enabledClasses = profile.classes;
        # Include for each enabled browser class
        browserIncludes = map (
          browserClass: mkBrowserProfileInclude { inherit profile browserClass; }
        ) enabledClasses;
        # Extra host module includes for external browser classes
        externalIncludes = lib.concatMap (
          externalEntry:
          lib.optional (lib.elem externalEntry.class enabledClasses) (
            mkExternalBrowserHostModule { inherit profile externalEntry host user; }
          )
        ) externalBrowserClasses;
      in browserIncludes ++ externalIncludes
    ) profiles;

in {
  # create aspect for each profiles
  den.aspects = lib.mkMerge deps;

  # Register browser classes so aspects can use them.
  den.classes.firefox.description = "Firefox profile configuration forwarded to homeManager.programs.firefox.profiles.<name>";
  den.classes.floorp.description = "Floorp profile configuration forwarded to homeManager.programs.floorp.profiles.<name>";
  den.classes.librewolf.description = "LibreWolf profile configuration forwarded to homeManager.programs.librewolf.profiles.<name>";
  den.classes.zen.description = "Zen Browser profile configuration forwarded to homeManager.programs.zen-browser.profiles.<name>";

  # Add `firefox-profiles` option to every user via den.schema.user.imports.
  den.schema = rec {
    firefox-profile = { };
    user.imports = [
      ({ user, host, ... }: {
        options.firefox-profiles = lib.mkOption {
          description = ''
            Firefox (and Firefox-based browser) profiles to manage via Home Manager.

            Each key becomes a profile name under
            `homeManager.programs.<browser>.profiles.<name>`.

            Configure the profile content in `den.aspects.<profileName>.<browserClass>`.
            The `profile` context arg is available in parametric aspects.
          '';
          default = { };
          defaultText = lib.literalExpression "{ }";
          type = lib.types.attrsOf (firefoxProfileType { inherit user host; });
        };
      })
    ];
    # Activate the user-to-firefox-profiles policy via den.schema.user.includes.
    user.includes = [
      { __isPolicy = true; name = "user-to-firefox-profiles"; fn = { user, host, ... }: toFirefoxProfiles user { inherit user host; }; }
    ];

    # for standalone home-manager
    home.imports = user.imports;
    home.includes = [
      { __isPolicy = true; name = "home-to-firefox-profiles"; fn = { home, ... }: toFirefoxProfiles home { inherit (home) user host; }; }
    ];
  };
}
