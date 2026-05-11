{ __findFile, den, ... }:
{
  # den.homes.x86_64-linux."fmway@Namaku1801" = {};
  den.hosts.x86_64-linux.Namaku1801.users.fmway = {};

  den.aspects.fmway = {
    includes = [
      <fmx/tools/productivity/zoom>
      <fmx/tools/productivity/zotero>
      <fmx/tools/productivity/h-m-m>
      <fmx/themes/catppuccin>
      (den._.user-shell "fish")
    ];

    meta.email = "fm18lv@gmail.com";
  };
}
