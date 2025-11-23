{ config, lib, pkgs, ... }: let
  cfg = config.programs.tmux;
  # fix socket problem in systemd services
  tmux = pkgs.writeScript "tmux" /* sh */ ''
    #!${pkgs.bash}/bin/bash
    
    export TMUX_TMPDIR=${config.home.sessionVariables.TMUX_TMPDIR or "/tmp/tmux-$(id -u)"}

    OPTS=()
    CONFIG_DIR="${config.xdg.configHome}/tmux/tmux.conf"
    [ ! -e "$CONFIG_DIR" ] || OPTS+=( "-f" "$CONFIG_DIR" )
    exec ${lib.getExe cfg.package} "''${OPTS[@]}" "$@"
  '';
in {
  config = lib.mkIf cfg.enable {
    # Tmux sometimes so fucked slow at first startup, we need to daemonize
    systemd.user.services = {
      tmux-daemon = {
        Unit = {
          Description = "Tmux Daemon";
          After = ["default.target"];
        };
        Service = {
          Type = "simple";
          ExecStart = "${tmux} -D";
          ExecStop = "${tmux} kill-server";
        };
        Install.WantedBy = ["default.target"];
      };

      tmux-run = {
        Unit = {
          Description = "Run tmux in once";
          After = ["tmux-daemon.service"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c '${tmux} new -d;${tmux} kill-session'";
        };
        Install.WantedBy = ["tmux-daemon.service"];
      };
    };
  };
}
