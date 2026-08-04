{ den, lib, ... }: let
  inherit (den.lib) policy; inherit (policy) pipe;
  isValidPort = p: builtins.isInt p && p >= 0 && p <= 65535;
  cleaning = builtins.concatMap (raw: let
    target = builtins.intersectAttrs { tcp = null; udp = null; } raw;
  in if target == {} then [] else [
    (builtins.mapAttrs (_: builtins.concatMap (val:
      if builtins.isString val then let
        r = lib.firewall.parse-range val;
      in if isNull r then [] else [r] else
      if isValidPort val then [val] else [])) target)
  ]);

  collectFirewall = firewall: let
    groupPorts = builtins.partition builtins.isInt;

    all = builtins.zipAttrsWith (_: vs: let
      ports = builtins.concatMap lib.fmway.flat vs;
    in groupPorts ports) firewall;
  in {
    allowedTCPPorts = all.tcp.right or [];
    allowedTCPPortRanges = all.tcp.wrong or [];
    allowedUDPPorts = all.udp.right or [];
    allowedUDPPortRanges = all.udp.wrong or [];
  };

in {
  den.quirks.firewall = {};
  den.policies.validate-firewall = { user ? null, ... }: [
    (pipe.from "firewall" [
      (pipe.for cleaning)
    ])
  ] ++ lib.optionals (user != null) [
    (pipe.from "firewall" [
      pipe.expose
    ])
  ];

  # TODO: cross entity
  # den.policies.fleet-firewall = _: [];

  den.default.includes = [
    den.policies.validate-firewall
    # den.policies.fleet-firewall
  ];

  den.schema.host.includes = [
    { nixos = { firewall, ... }: { _module.args.tete = firewall; networking.firewall = collectFirewall firewall; }; }
  ];
}
