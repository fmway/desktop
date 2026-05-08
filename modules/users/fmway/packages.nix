{ den, ... }:
{
  den.aspects.fmway.includes = [
    den.aspects.fmway._.packages
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
        telegram-desktop
        upscayl # image upscaler

        # development
        # wasmer
        deno
      ];
    };
  };
}
