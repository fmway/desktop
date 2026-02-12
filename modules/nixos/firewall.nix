{
  networking.firewall = {
    allowedTCPPorts = [
      80
      5900
      9000
      3000
      3001
      8080
      8000
      8888
      9876
      1234
      443
      445
      51820
    ];

    allowedUDPPortRanges = [
      # winbox problem
      {
        from = 40000;
        to = 50000;
      }
    ];
  
    # handling Wireguard to firewall in systemd
    checkReversePath = "loose";
    # if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    # up
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
    '';

    # down
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
    '';
  };
}
