{ inputs, ... }:
{
  fmx.desktops._.shells._.dms = {
    includes = [
      <fmx/desktops/utils/ddc>
      <fmx/desktops/shells/dms/danksearch>
    ];
    # TODO: use home-manager or replace systemd-user, per-user
    nixos = { pkgs, config, ... }:
    {
      environment.systemPackages = with pkgs; [
        cups-pk-helper
      ];
      programs.dms-shell = {
        enable = true;
        # systemd.target = "wayland-session.target";
        systemd.restartIfChanged = true;
        systemd.enable = true;

        enableSystemMonitoring = true;
        enableDynamicTheming = true;
        enableAudioWavelength = true;
        enableCalendarEvents = true;
        enableClipboardPaste = true;
      };
    };
    # homeManager.imports = [
    #   inputs.dms.homeModules.dank-material-shell
    # ];

    _.danksearch.homeManager = {
      imports = [
        inputs.dsearch.homeModules.default
      ];
      programs.dsearch.enable = true;
    };
  };


  flake-file.inputs = {
    dsearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
