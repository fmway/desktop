# TODO: expose as schema / keyd class
{ lib, ... }:
{
  fmx.tools.keymapper.keyd.includes = [
    # register keyd group for each user
    ({ user, host, ... }: {
      nixos.users.users.${user.userName}.extraGroups = [ "keyd" ];
    })
    { nixos.users.groups.keyd = {}; }
  ];
  fmx.tools.keymapper.keyd.nixos = { pkgs, ... }:
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
      keyboards.default = {
        ids = [ "*" ];
        settings = lib.keymapper.keyd.parse (import ./_keymap.nix);
      };
    };
  };
}
