{ den, lib, ... }: let
  inherit (den.lib) policy; inherit (policy) pipe;
in {
  den.quirks.dns = { };
  den.policies.clean-dns = { user ? null, ... }:
    if isNull user then
      pipe.from "dns" [ pipe.expose ]
    else
      pipe.from "dns" [ (pipe.for (builtins.filter builtins.isString)) ]
  ;
  den.schema = rec {
    user.includes = [ den.policies.clean-dns ];
    host = user;
  };
  fmx.networking = {
    includes = [
      <fmx/networking/networkmanager>
      <fmx/networking/dns>
      <fmx/networking/systemd-resolved>
    ];

    _.networkmanager = {
      nixos = { host, lib, ... }:
      {
        config = lib.mkMerge [
          { networking.networkmanager = {
              enable = true;
              wifi.powersave = true;
            };
          }
          (lib.mkIf (host.hasAspect <fmx/networking/systemd-resolved>) {
            networking.networkmanager.dns = "systemd-resolved";
          })
        ];
        
      };
    };

    _.dns = {
      includes = [ <fmx/networking/dns/quad> ];
      nixos = { dns, ... }:
      {
        networking.nameservers = dns;
      };

      cloudflare.dns = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];

      quad.dns = [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
      ];
    };
  };
}
