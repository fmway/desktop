# register APE format to binfmt
# ref: https://git.sr.ht/~jack/cosmo.nix/tree/master/item/modules/ape-loader.nix
{ internal, config, selfConfig ? config, ... }:
{ pkgs, inputs, ... }:
{
  nixpkgs.overlays = [
    selfConfig.flake.overlays.ape-loader
  ];
  boot.binfmt.registrations = let
    template = magicOrExtension: {
      inherit magicOrExtension;
      interpreter = "${pkgs.ape-loader}/bin/ape";
      preserveArgvZero = true;
      fixBinary = true;
      wrapInterpreterInShell = false;
      interpreterSandboxPath = "${pkgs.ape-loader}/bin/ape";
    };
  in {
    # :APE:M::MZqFpD::/usr/bin/ape:
    APE = template "MZqFpD";
    # :APE-jart:M::jartsr::/usr/bin/ape:
    APE-jart = template "jartsr";
  };
}
