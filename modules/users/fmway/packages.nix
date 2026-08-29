{ den, ... }:
{
  den.aspects.fmway.includes = [
    <fmway/packages>
    <fmx/desktops/apps/telegram>
    <fmx/desktops/apps/appflowy>
  ];
  den.aspects.fmway._.packages = {
    homeManager = { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # TODO
        # scripts.all

        # cli
        element # periodic table
        # matui
        ttyper # monkeytype in terminal
        
        # gui
        upscayl # image upscaler

        # development
        # wasmer
        deno
      ];
    };
  };
}
