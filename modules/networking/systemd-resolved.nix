{
  fmx.networking.systemd-resolved = {
    includes = [ <fmx/networking/systemd-resolved/quad> ];

    nixos.services.resolved = {
      enable = true;
      settings.Resolve.DNSOverTLS = "true";
    };

    quad.nixos.services.resolved.settings.Resolve.FallbackDNS = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];

    cloudflare.nixos.services.resolved.settings.Resolve.FallbackDNS = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
    ];
  };
}
