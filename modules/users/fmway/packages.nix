{ den, ... }:
{
  den.aspects.fmway.includes = [
    <fmway/packages>
    <fmx/desktops/apps/telegram>
  ];
  den.aspects.fmway.packages = {
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
