{ internal, lib, _file, ... } @ v:
{ pkgs ? {}, config, ... } @ w: let
  var = v // w // { inherit pkgs config; };
  data = with builtins; fromJSON (readFile ./engines.json);
  toEngine = lib.firefox.mkEngine var;
  extracted = lib.mapAttrs toEngine data;
in {
  assertions = [
  {
    assertion = pkgs != {};
    message = ''
      You must add pkgs to profiles, e.g:
      ```nix
        { pkgs, ... }: let
          superPkgs = pkgs;
        in {
          programs.firefox.profiles.default = { pkgs, ... }: {
            _module.args.pkgs = superPkgs;
          };
        }
      ```
    '';
  }
  ];
  inherit _file;
  search.engines = extracted;
}
