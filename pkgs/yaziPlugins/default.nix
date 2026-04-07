{ internal, inputs, self, lib, super, ... }: let
  src = inputs.yazi-plugins // { owner = "yazi-rs"; };
  version = "unstable-${inputs.yazi-plugins.shortRev}";

  officials = a: builtins.foldl' (acc: curr: let name = lib.removeSuffix ".yazi" curr; in acc // (if super.yaziPlugins ? ${name} then {
    "${name}".__output = {
      src.__assign = src;
      version.__assign = version;
    };
  } else {
    ${name}.__add = {
      inherit version;
      src = src;
      pname = curr;

      meta = {
        description = let
          p = "${inputs.yazi-plugins}/${curr}/README.md";
          d = builtins.elemAt (lib.splitString "\n" (builtins.readFile p)) 2;
        in
          lib.optionalString (builtins.pathExists p) d;
        homepage = "https://github.com/yazi-rs/plugins";
        license = lib.licenses.mit;
      };
    };
  })) a (builtins.attrNames (lib.filterAttrs (k: t: t == "directory" && lib.hasSuffix ".yazi" k) (builtins.readDir inputs.yazi-plugins.outPath)));
in {
  __infuse = officials {
    bunny.__add = rec {
      pname = "bunny.yazi";
      version = "1.4.0";

      src = self.fetchFromGitHub {
        owner = "stelcodes";
        repo = "bunny.yazi";
        rev = "v${version}";
        hash = "sha256-Bycoiac5lVeJAJUoFt6HV4JsHpOlFul0jncygDK/D3s=";
      };

      meta = {
        description = "Bookmarks menu for yazi with persistent and ephemeral bookmarks, fuzzy searching, previous directory, directory from another tab";
        homepage = "https://github.com/stelcodes/bunny.yazi";
        changelog = "https://github.com/stelcodes/bunny.yazi/blob/${src.rev}/CHANGELOG.md";
        license = lib.licenses.mit;
      };
    };
  };
}
