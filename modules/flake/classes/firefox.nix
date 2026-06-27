{ den, lib, inputs, ... }: let
  inherit (import "${inputs.den}/nix/lib/entities/_types.nix" { inherit lib den; }) resolvedCtxModule;
  allHosts = lib.concatMap builtins.attrValues (builtins.attrValues den.hosts);
  allHomes = lib.concatMap builtins.attrValues (builtins.attrValues den.homes);
  allUsers = lib.concatMap (h: builtins.attrValues h.users) allHosts;
  allFirefoxProfiles = lib.concatMap (p: builtins.attrValues p.firefox-profiles) (allUsers ++ allHomes);

  deps = map (from: {
    ${from.name} = lib.genAttrs from.classes (_: { });
  }) allFirefoxProfiles;

  builtinBrowserClasses = [ "firefox" "floorp" "librewolf" ];

  externalBrowserClasses = [
    { class = "zen";
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

  resolveBrowserClass =
    { profile, browserClass, profileAspectWithCtx }: let
      resolved = den.lib.aspects.resolve browserClass profileAspectWithCtx;
      # The pipeline wraps each class module as { _file; key; imports = [fn] }.
      # Extract the inner module functions so they can be used as profile values.
      innerModules = lib.concatMap (m: m.imports or [ ]) resolved.imports;
    in lib.mkMerge innerModules;

  mkBrowserProfileInclude =
    { profile, browserClass }:
    den.lib.policy.include {
      name = "firefox-profile/${profile.profileName}/${browserClass}";
      homeManager =
        { pkgs, lib, config, osConfig, ... }: let
          profileAspectWithCtx = let
            raw = profile.aspect;
            inherit (den.lib.aspects.fx.handlers) constantHandler;
          in if builtins.isAttrs raw then
            raw // {
              __scopeHandlers = (raw.__scopeHandlers or { }) // constantHandler { inherit profile pkgs osConfig; homeConfig = config; };
            }
          else raw;

          resolveClass = cls: resolveBrowserClass { inherit profile profileAspectWithCtx; browserClass = cls; };

          aliasedClasses = profile.classAliases.${browserClass} or [ ];
          browserValue = lib.mkMerge (map resolveClass (aliasedClasses ++ [ browserClass ]));

          optPath = browserOptionPath browserClass;
        in {
          programs.${optPath} = {
            enable = lib.mkDefault true;
            profiles.${profile.profileName} = browserValue;
          };
        };
    };

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

  firefoxProfileType = { user, host, ... }: den.lib.schema.mkInstanceType den.schema.firefox-profile {
    strict = false;
    extraModules = [
      (resolvedCtxModule "firefox-profile")
      ({ config, name, ... }: {
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
      })
    ];
  };
  firefoxs = { lib, user, ... }: {
    options.firefox-profiles = lib.mkOption {
      type = lib.types.attrsOf (firefoxProfileType { user = user; host = user.host; });
      default = {};
    };
  };
in {
  # create aspect for each profiles
  den.aspects = lib.mkMerge deps;

  # Register browser classes so aspects can use them.
  den.classes.firefox.description = "Firefox profile configuration forwarded to homeManager.programs.firefox.profiles.<name>";
  den.classes.floorp.description = "Floorp profile configuration forwarded to homeManager.programs.floorp.profiles.<name>";
  den.classes.librewolf.description = "LibreWolf profile configuration forwarded to homeManager.programs.librewolf.profiles.<name>";
  den.classes.zen.description = "Zen Browser profile configuration forwarded to homeManager.programs.zen-browser.profiles.<name>";
  den.schema = rec {
    firefox-profile.isEntity = true;
    user.imports = [ firefoxs ];
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
