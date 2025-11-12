{ config, lib, pkgs, ... }:
{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "cgi.local.com" = {
        root = "/srv/cgi";
        locations = {
          "/" = {
            index = "index.cgi index.html index.htm";
          };

          "~ \\.cgi$".extraConfig = /* nginx */ ''
            # rewrite ^/cgi/(.*) /$ break;
            gzip off;

            include fastcgi_params;
            fastcgi_pass = unix:${config.services.fcgiwrap.instances.fmway.socket.address};
            fastcgi_param SCRIPT_FILENAME /srv/cgi$fastcgi_script_name;
          '';
        };
      };

      "php.local.com" = {
        root = "/srv/php";
        locations."~ \\.php$".extraConfig = /* nginx */ ''
          # 
          fastcgi_pass unix:${config.services.phpfpm.pools.mypool.socket};
          fastcgi_index index.php;
        '';
      };
    };
  };

  services.phpfpm.pools.mypool = lib.mkIf config.services.nginx.enable {
    user = "nobody";
    settings = {
      "pm" = "dynamic";
      "listen.owner" = config.services.nginx.user;
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
    };
  };

  services.fcgiwrap.enable = lib.mkDefault true;

  services.fcgiwrap.instances = lib.mkIf config.services.nginx.enable {
    fmway = {
      socket = {
        group = config.services.nginx.group;
        user = config.users.users.fmway.name;
        mode = "0666";
      };
      process = {
        user = config.users.users.fmway.name;
        group = config.users.groups.users.name;
      };
    };
  };

  
  networking.hosts."127.0.0.1" = [
    "cgi.local.com"
  ];

  # services.certs = {
  #   cgi.cname = "cgi.local.com";
  #   cgi.alt = [ "DNS:cgi.local.com" ];
  # };
}
