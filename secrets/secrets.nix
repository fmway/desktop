let
  keys = {
    system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOcO6Gzc82fRDIb+DtYMM9yQzz6N1w31aQcj2tQUaRZj";
    fmway = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGM2l3zhUoxYpBzzmH7KsWdo1XMrc1eCgNrwaIHVM2pZ";
  };
  
  mySecret = arr: builtins.listToAttrs (map (name: {
    name = "${name}.age";
    value.publicKeys = builtins.attrValues keys;
  }) arr);

in mySecret [ 
  "nix" # another nix.conf with encryption
  "tailscale"
  # "fmway"
] 
