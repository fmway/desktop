{
  fmx.networking = { config, ... }: {
    includes = [
      config._.networkmanager
      config._.dns
      config._.systemd-resolved
    ];

    _.networkmanager = { config, ... }: {
      includes = [ config.provides.systemd-resolved ];
      nixos.networking.networkmanager = {
        enable = true;
        wifi.powersave = true;
      };

      provides.systemd-resolved.nixos.networking.networkmanager.dns = "systemd-resolved";
    };

    _.dns = { config, ... }: {
      includes = [ config.provides.quad ];
      _.cloudflare.nixos.networking.nameservers = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];

      _.quad.nixos.networking.nameservers = [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
      ];
    };
  };
}
