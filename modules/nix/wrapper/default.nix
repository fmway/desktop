{ lib, den, fmx, ... }:
{
  fmx.nix.includes = [ <fmx/nix/wrapper> ];
  
  fmx.nix.wrapper = {
    description = "Evaluate cache urls first before rebuild";
    includes = [ <fmx/nix/wrapper/_> ];

    # FIXME, notfully wrapped
    nixos = { host, config, extraCaches, pkgs, ... }:
    {
      options.system."cache-info.json" = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        default = pkgs.writers.writeJSON "cache-info.json"
          (builtins.zipAttrsWith (_: v: lib.unique (builtins.concatLists v)) (
            lib.select "**.**.{?substituters,?trusted-public-keys}" extraCaches));
      };

      config = lib.mkMerge [
        {
          system.extraSystemBuilderCmds = /* sh */ ''
            ln -sf ${config.system."cache-info.json"} $out/cache-info.json
          '';
        }
        (lib.mkIf config.system.tools.nixos-rebuild.enable {
          environment.systemPackages = let
            package = config.system.build.nixos-rebuild;
            cmd = lib.getExe package;
            prev_cache_file = "${config.system."cache-info.json"}";
            pkg = pkgs.writeScriptBin package.meta.mainProgram /* nu */ ''
              #!/bin/env -S ${lib.getExe pkgs.nushell} -n
              source ${./wrap.nu}

              ${lib.concatMapStringsSep "\n" (subcommand: /* nu */ ''
                def --wrapped "main ${subcommand}" [--flake: string = "/etc/nixos", --no-reexec, --verbose (-v), ...args] {
                  wrap $flake ${prev_cache_file} $verbose [ ${cmd} ${subcommand} ...(if $no_reexec {[ --no-reexec ]} else {[]}) ] ...$args
                }
              '') ["switch" "test" "boot" "build" "build-image" "build-vm" "build-vm-with-downloader" "dry-build" "dry-activate"]}

              def --wrapped main [...args] {
                exec ${cmd} ...$args
              }
            '';
          in [
            (lib.hiPrio pkg)
          ];
        })
      ];
    };

    nh.nixos = { host, config, pkgs, ... }:
      lib.optionalAttrs (host.hasAspect <fmx/tools/cli/nh>) {        
        config = lib.mkIf config.programs.nh.enable {
          environment.systemPackages = let
            package = config.programs.nh.package;
            cmd = lib.getExe package;
            prev_cache_file = "${config.system."cache-info.json"}";
            pkg = pkgs.writeScriptBin package.meta.mainProgram /* nu */ ''
              #!/bin/env -S ${lib.getExe pkgs.nushell} -n
              source ${./wrap.nu}
              let flake_path: string = ($env.NH_OS_FLAKE | default "/etc/nixos")

              ${lib.concatMapStringsSep "\n" (subcommand: /* nu */ ''
                def --wrapped "main os ${subcommand}" [--verbose (-v), ...args] {
                  wrap $flake_path ${prev_cache_file} $verbose --separate-args [ ${cmd} os ${subcommand} ] ...$args
                }
              '') ["switch" "test" "boot" "build" "build-image" "build-vm"]}

              def --wrapped main [...args] {
                exec ${cmd} ...$args
              }
            '';
          in [
            (lib.hiPrio pkg)
          ];
        };
      };
  };
}
