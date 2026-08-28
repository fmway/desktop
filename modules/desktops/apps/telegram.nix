{
  fmx.desktops._.apps._.telegram = {
    includes = [
      ({ persistent, user, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".var/app/org.telegram.desktop"
        ];
      })
    ];

    # ref: https://github.com/mnixry/nixos-config/blob/main/pkgs/nixpaks/telegram.nix
    nixpak.telegram-desktop = { pkgs, sloth, ... }:
    {
      app.package = pkgs.telegram-desktop;
      flatpak.appId = "org.telegram.desktop";

      # FIXME: or maybe we use another sandbox tools?
      # bubblewrap.bind = with sloth; {
      #   ro = [
      #     (concat' homeDir "/Downloads")
      #   ];
      #   rw = [
      #     (concat' homeDir "/Downloads/Telegram Desktop")
      #   ];
      # };

      dbus = {
        enable = true;
        policies = {
          "org.gnome.Mutter.IdleMonitor" = "talk";
          "org.freedesktop.Notifications" = "talk";
          "org.kde.StatusNotifierWatcher" = "talk";
          "com.canonical.AppMenu.Registrar" = "talk";
          "com.canonical.indicator.application" = "talk";
          "org.ayatana.indicator.application" = "talk";
          "org.sigxcpu.Feedback" = "talk";
        };
      };
    };
    homeManager = { pkgs, ... }:
    {
      home.packages = [ pkgs.telegram-desktop ];
    };
  };
}
