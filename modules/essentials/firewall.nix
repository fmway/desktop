{
  # default allow tcp port
  # TODO: add class or schema to expose firewall open ports
  fmx.essentials._.firewall.nixos.networking.firewall.allowedTCPPorts = [
    1234
    3000
    3001
    5900
    8000
    8080
    8888
    9000
    9876
  ];
}
