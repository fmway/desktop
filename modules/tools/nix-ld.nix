{
  fmx.tools._.nix-ld = { config, ... }: {
    includes = builtins.attrValues config.provides;
    nixos = {
      programs.nix-ld = {
        enable = true;
      };
    };

    _.core.nixos = { pkgs, ... }:
    {
      programs.nix-ld.libraries = with pkgs; [
        glibc
        openssl
      ];
    };
  };
}
