{
  # auto update lock (if adding / removing inputs)
  flake-file.write-hooks = [
    {
      index = 1000;
      program = pkgs: pkgs.writeShellApplication {
        name = "nix-flake-lock";
        runtimeInputs = [ pkgs.nix ];
        text = ''
          nix flake lock
        '';
      };
    }
  ];

  den.schema.flake-system.includes = [
    { packages = { pkgs, lib, ... }: import ../packages { inherit pkgs lib; }; }
  ];
}
