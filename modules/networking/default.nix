{
  fmx.networking = {
    includes = [
      <fmx/networking/networkmanager>
      <fmx/networking/dns>
      <fmx/networking/systemd-resolved>
    ];

    networkmanager = {
      includes = [ <fmx/networking/networkmanager/systemd-resolved> ];
      nixos.networking.networkmanager = {
        enable = true;
        wifi.powersave = true;
      };

      systemd-resolved.nixos.networking.networkmanager.dns = "systemd-resolved";
    };

    dns = {
      includes = [ <fmx/networking/dns/quad> ];
      cloudflare.nixos.networking.nameservers = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];

      quad.nixos.networking.nameservers = [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
      ];
    };
  };
}
