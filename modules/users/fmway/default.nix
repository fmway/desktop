{ den, ... }:
{
  den.homes.x86_64-linux."fmway@Namaku1801" = {};
  den.hosts.x86_64-linux.Namaku1801.users.fmway = {
    email = "fm18lv@gmail.com";
  };

  den.aspects.fmway = {
    includes = [
      <fmx/tools/productivity/zoom>
      <fmx/tools/productivity/zotero>
      <fmx/tools/productivity/h-m-m>
      <fmx/themes/catppuccin>
      <fmx/browsers/helium>
      (den._.user-shell "fish")
    ];
    excludes = [
      <fmx/programs/starship>
    ];
  };
}
