{
  fmx.networking._.systemd-resolved = {
    nixos = { dns, ... }:
    {
      services.resolved = {
        enable = true;
        settings.Resolve.DNSOverTLS = "true";
        settings.Resolve.FallbackDNS = dns;
      };
    };
  };
}
