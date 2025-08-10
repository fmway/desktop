let
  sources = builtins.fromJSON (builtins.readFile ./pin.json);
  res = builtins.mapAttrs (k: v: let
    type = v.type or "tarball";
    fn = if type == "file" then
      builtins.fetchurl
    else if type == "tarball" then
      fetchTarball
    else throw "undefined";
    source = fn {
      name = v.name or "source";
      inherit (v) url sha256;
    };
  in if v.flake or false then
    getFlake (builtins.toPath source)
  else source) sources;

  # FIXME add follow support
  getFlake = src: (import res.flake-compat { inherit src; }).outputs;
in res
