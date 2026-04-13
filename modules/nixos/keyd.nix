{ internal, lib, _file, ... }:
{ pkgs, ... }:
{
  inherit _file;
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
    enable = lib.mkDefault true;
    keyboards.default = {
      ids = [ "*" ];
      settings = lib.keyd.parse (self: with self; {
        # default / insert mode
        main = {
          henkan           = layer control;
          muhenkan         = layer alt;
          katakanahiragana = layer altgr;
          capslock         = layer normal;
          shift            = layer shift;
        };
        shift.capslock = capslock;
        # normal mode
        normal = {
          h   = left;
          j   = down;
          k   = up;
          l   = right;
          b   = oneshot normal;
          i   = clear; # back to insert mode
          "[" = toggle normal;
          v   = toggle visual;
          g   = oneshot g_layer;

          shift."6" = home;
          shift."4" = end;
          shift."h" = pageup;
          shift."j" = pagedown;
          shift."g" = Ctrl end;

          f1 = mute;
          f2 = volumedown;
          f3 = volumeup;
          f4 = micmute;
          f5 = brightnessdown;
          f6 = brightnessup;
          f7 = display; # maybe
          f8 = connect; # maybe
          # f9 = ...;
          f10 = bluetooth;
          # f11 = ...;
          f12 = bookmarks;
        };

        g_layer = rec {
          g          = Ctrl home;
          normal.g   = g;
        };

        visual = {
          h   = Shift left;
          j   = Shift down;
          k   = Shift up;
          l   = Shift right;

          shift."6" = Shift home;
          shift."4" = Shift end;
          shift."h" = Shift pageup;
          shift."j" = Shift pagedown;

          y   = clearm (Ctrl v);
          x   = clearm (Ctrl x);
          esc = clearm esc;
        };
      });
    };
  };
}
