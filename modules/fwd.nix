{ den, fmx, lib, ... }:
{
  # den.default.includes = [
  #   <fmx/utils>
  # ];

  # fmx.utils.includes = builtins.attrValues fmx.utils.provides;
   # programs -> homeManager.programs
   # TODO: support nixos class

  # FIXME: infinite recursion
  # fmx.utils._.nixvim = {
  #   description = "nixvim -> nixos.programs.nixvim";
  #   includes = [
  #     ({ class, aspect-chain }: den._.forward {
  #       each = [ "nixos" ];
  #       fromClass = _: "nixvim";
  #       intoClass = lib.id;
  #       intoPath = _: [ "programs" "nixvim" ];
  #       fromAspect = _: lib.head aspect-chain;
  #       guard = { options, ... }: options ? programs.nixvim;
  #       adaptArgs = { config, ... }: { osConfig = config; };
  #     })
  #   ];
  # };

  # fmx.utils._.browsers.includes = builtins.attrValues fmx.utils._.browsers.provides;

  # FIXME: (maybe use den.ctx),
  # from den.aspects.<profile> & den.firefox.<profile>.firefox (class firefox with additional args = { pkgs } (from homeManager))
  #   -> homeManager.programs.<all firefox-based>.profiles.<profile>
  # fmx.utils._.browsers._.firefox = let
  #   firefox-based = [ "zen" "floorp" "librewolf" ];
  # in {
  #   description = "firefox profiles class";
  #   __functor =
  #     { class, aspect-chain }:
  #     {
  #       each = [ "homeManager" ] ++ firefox-based;
  #       fromClass = _: "firefox";
  #       intoClass = lib.id;
  #       intoPath = name: if name == "homeManager" then [ "programs" "firefox" ] else [];
  #       fromAspect = _: lib.head aspect-chain;
  #       adaptArgs = lib.id;
  #     };
  #   includes = builtins.attrValues fmx.utils._.browsers._.firefox._;
  #   _ = builtins.listToAttrs (map (name: {
  #     inherit name;
  #     value.description = "${name} profiles class";
  #     value.__functor =
  #       { class, aspect-chain }:
  #       {
  #         each = [ "homeManager" ];
  #         fromClass = _: name;
  #         intoClass = lib.id;
  #         intoPath = _: [ "programs" name ];
  #         fromAspect = _: lib.head aspect-chain;
  #         adaptArgs = lib.id;
  #         guard = { options, ... }: options ? programs.${name};
  #       };
  #   }) firefox-based);
  # };

  # FIXME: nix classes (fmx.utils._.nix) replace arrays instead of merging
  # fmx.utils._.nix = {
  #   description = ''
  #     Forward nix classes to (nixos|darwin|homeManager).nix
  #   '';
  #   __functor = _self:
  #     { class, aspect-chain }:
  #     den._.forward {
  #       each = [ "nixos" "homeManager" "darwin" ];
  #       fromClass = _: "nix";
  #       intoClass = lib.id;
  #       intoPath = _: [ "nix" ];
  #       fromAspect = _: lib.head aspect-chain;
  #       guard = { options, ... }: options ? nix;
  #     };
  # };
}
