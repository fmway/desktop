{ den, lib, ... }:
{
  den.homes.x86_64-linux."fmway@Namaku1801" = {};
  den.hosts.x86_64-linux.Namaku1801.users.fmway = { };

  # apply to all hosts for user "fmway"
  den.schema.user = { name, ... }:
  {
    config = lib.mkIf (name == "fmway") {
      email = "fm18lv@gmail.com";
      sshKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDD7g5NRKn0VP/TGMO7RsNRZVlOcOFRHZg2flAkrEIABkbYS93ERGphDk5f18SPECiElUr9a9OdkkjYsvcfDsJ976BBQFqwAAAcfk/V8eJoZCyS/IR7IDLTI0kxAb+kr8OO4+jztuKY4qmBMPli0TYK6WoFqdBouegbgVE/6tUgp+Cif1BDHNjgWgPqE4Iz/gtWI5j+5SnBfZDIoMB+dqBgOx42AWZvlCJegRds6Rqk/2TmsIyX+/DvCllQjPC1VdKWkOcNQCDBt8WkBlo8gBzrtwiPp4kdFSgxWo3iuBKyAAixlfaUI87KvoDqQqQEmxfnTQkXHpyNOFnZp5nXxgXwO3W8Dzi4Kt9Wnyb//F6umH6CKor57iDxbXxjtvp0Klu4c/Ioj8bpJzbMYSlmpSY57b6Jsbq7FUEebo7GTCTvSSfeybZtw409r3Vk8hxqk7uVlZQOh5r+Or0KXae+rBU6DPGVeAcnBzg3B2V/mZn9QKELcXBSQb2+M9NJdDx5TP0= namaku1801@gmail.com"
      ];
    };
  };

  den.aspects.fmway = {
    includes = [
      <fmx/tools/drive/megasync>
      <fmx/tools/productivity/zoom>
      <fmx/tools/productivity/zotero>
      <fmx/tools/productivity/h-m-m>
      <fmx/tools/dev/_>
      <fmx/themes/catppuccin>
      <fmx/browsers/helium>
      <fmx/editors/zed>
      <fmx/games/steam>
      (den._.user-shell "fish")
    ];
  };
}
