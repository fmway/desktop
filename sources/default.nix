let
  sources = builtins.fromJSON (builtins.readFile ./pin.json);
  res = builtins.mapAttrs (k: v: let
    source = fetchTarball {
      name = v.name or "source";
      inherit (v) url sha256;
    };
  in if v.flake or false then
    getFlake (builtins.toPath source)
  else source) sources;

  # FIXME add follow support
  getFlake = src: (import res.flake-compat { inherit src; }).outputs;
in res
