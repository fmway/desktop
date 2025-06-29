{ pkgs, config, lib, ... }:
{
  services.samba.enable = lib.mkDefault true;
  services.samba = {
    # enable = true;
    package = pkgs.sambaFull;
    settings.global = {
      "workgroup" = "WORKGROUP";
      "server string" = "smbnix";
      "netbios name" = "smbnix";
      "security" = "user ";
      # "use sendfile" = "yes";
      # "max protocol" = "smb2";
      # note: localhost is the ipv6 localhost ::1
      "hosts allow" = "192.168. 127.0.0.1 localhost";
      # "hosts deny" = "0.0.0.0/0";
      "guest account" = "nobody";
      "map to guest" = "bad user";
    };
    openFirewall = true;
  };

  services.samba-wsdd = {
    enable = config.services.samba.enable;
    openFirewall = true;
  };
}
