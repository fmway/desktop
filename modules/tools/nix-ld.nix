{
  fmx.tools.nix-ld = {
    includes = [ <fmx/tools/nix-ld/core> ];
    nixos = {
      programs.nix-ld = {
        enable = true;
      };
    };

    core.nixos = { pkgs, ... }:
    {
      programs.nix-ld.libraries = with pkgs; [
        glibc
        openssl
      ];
    };
  };
}
