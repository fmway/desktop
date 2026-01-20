{ inputs, config, ... }:
{
  perSystem = { pkgs, lib, ... }: {
    apps = lib.fmway.stringification' {
      get-keys-keyd = {
        type = "app";
        program = pkgs.writeScript "update-keys-keyd.fish" /* fish */ ''
          #!${lib.getExe pkgs.fish}
          ${lib.mkFishPath (with pkgs; [ keyd ])}

          echo "{ lib, ... }:"
          echo "lib.flip lib.genAttrs (name: name) ["
          keyd list-keys | while read line; printf '  "%s"\n' $(if [ "$line" = '"' ] || [ "$line" = \\ ]; echo \\$line; else; echo $line; end); end
          echo "]"
        '';
      };
      # generate stubby certs
      updateStubbyCert = {
        type = "app";
        program = pkgs.writeScript "update-stubby-cert.fish" /* fish */ ''
          #!${lib.getExe pkgs.fish}
          ${lib.mkFishPath (with pkgs; [
            jq
            knot-dns
            gnugrep
            gnused
          ])}

          set -q argv[1] && set CTX $argv[1] || set CTX $PWD/modules/nixos/stuby/__dns.json

          set tmp_json "$(cat $CTX)"
          #
          for i in (echo "$tmp_json" | jq -r 'keys_unsorted[]')
            set tls_host "$(echo "$tmp_json" | jq -r '."'$i'".tls_host')"
            set oldCert "$(echo "$tmp_json" | jq -r '."'$i'".signedCert')"
            
            set newCert "$(kdig -d @$i +tls-ca +tls-host=$tls_host example.com 2>/dev/null | grep '#1,' -A 1 | tail -n1 | sed 's/.\+ PIN: \(.\+\)/\1/')"

            if [ $oldCert != $newCert ]
              echo "$tmp_json" | jq '."'$i'".signedCert = "'$newCert'"' > $CTX
              set tmp_json "$(cat $CTX)"
            end
          end
        '';
      };
      # generate cachix on nix.conf
      gcn = {
        type = "app";
        program = let
          settings = config.flake.nixConfig;
        in pkgs.writeScript "gen-nix-conf.sh" /* sh */ ''
          #!${lib.getExe pkgs.bash}

          ${lib.concatStringsSep "" (map (x: /* sh */ ''
            echo ${x} = ${lib.concatStringsSep " " settings.${x} or []};
          '') [ "substituters" "trusted-public-keys" "experimental-features" ])}
        '';
      };
      # generate nixConf on flake.nix
      generateNixConf = {
        type = "app";
        program = let
          inherit (config.flake) nixConfig;
          substituters = nixConfig.substituters or [];
          trusted-public-keys = nixConfig.trusted-public-keys or [];
          experimental-features = nixConfig.experimental-features or [];
        in pkgs.writeScript "nixConf.sh" /* sh */ ''
          #!${lib.getExe pkgs.bash}
          FLAKE=''${1:-$PWD/flake.nix}
          if cat $FLAKE | grep "nixConfig = " &>/dev/null; then
            cat $FLAKE | sed '/nixConfig = /,$d'
          else
            cat $FLAKE | head -n -1
          fi
          cat <<EOF
            nixConfig = {
              extra-trusted-substituters = [
                ${lib.concatStringsSep "\n      " (map builtins.toJSON substituters)}
              ];
              extra-trusted-public-keys = [
                ${lib.concatStringsSep "\n      " (map builtins.toJSON trusted-public-keys)}
              ];
              extra-experimental-features = [
                ${lib.concatStringsSep "\n      " (map builtins.toJSON experimental-features)}
              ];
            };
          }
          EOF
        '';
      };
    };
  };
}
