{ den, ... }:
{
  fmx.desktops._.apps._.telegram = {
    includes = [
      (den._.user-packages [ "telegram-desktop" ])
      ({ persistent, user, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".var/app/org.telegram.desktop"
        ];
      })
    ];

    # ref: https://github.com/mnixry/nixos-config/blob/main/pkgs/nixpaks/telegram.nix
    nixpak.telegram-desktop = { pkgs, sloth, ... }:
    {
      imports = [ ./_chat.nix ];
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
    };
  };
}
