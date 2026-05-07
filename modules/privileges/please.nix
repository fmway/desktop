{
  fmx.privileges._.please.nixos.security.please = {
    enable = true;
    settings = {
      users_as_root = {
        name = "users";
        target = "root";
        type = "run";
        rule = ".*";
      };
    };
  };
}
