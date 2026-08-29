{ den, lib, ... }: let
  inherit (den.lib.policy) pipe;
in {
  den.quirks.keyd-config = {};
  den.policies.collect-keyd-config = { host ? null, user ? null, ... }:
    if isNull user then
      pipe.from "keyd-config" [ (pipe.for (x: [(lib.keymapper.keyd.parse.from-quirks x)])) ]
    else
      pipe.from "keyd-config" [ pipe.expose ];
  den.schema = rec {
    host.includes = [ den.policies.collect-keyd-config ];
    user = host;
  };
  fmx.tools.keymapper.keyd.includes = [
    # register keyd group for each user
    ({ user, host, ... }: {
      nixos.users.users.${user.userName}.extraGroups = [ "keyd" ];
    })
    { nixos.users.groups.keyd = {}; }
    {
      keyd-config = {
        default.ids = [ "*" ];
        default.settings = import ./_keymap.nix;
      };
    }
  ];
  fmx.tools.keymapper.keyd.nixos = { pkgs, keyd-config, ... }:
  {
    # Link keyd-keyboard to /dev/input/keyd
    services.udev.extraRules = /* udev */ ''
      SUBSYSTEM=="input", \
        ATTRS{name}=="keyd virtual keyboard", \
        SYMLINK+="input/keyd"
    '';

    environment.etc."libinput/local-overrides.quirks".text = /* ini */ ''
      [Serial Keyboards]
      MatchUdevType=keyboard
      MatchName=keyd virtual keyboard
      AttrKeyboardIntegration=internal
    '';
    
    systemd.services.keyd = lib.mkForce {
      description = "key remapping daemon";
      enable = true;
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.keyd}/bin/keyd";
      };
      wantedBy = [ "sysinit.target" ];
      requires = [ "local-fs.target" ];
      after = [ "local-fs.target" ];
    };

    services.keyd = {
      enable = true;
      keyboards = builtins.head keyd-config;
    };
  };
}
