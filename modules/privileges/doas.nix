{
  fmx.privileges._.doas.nixos.security.doas = {
    enable = true;
    extraRules = [
    {
      groups = [ "users" ];
      keepEnv = true;
      persist = true;
      setEnv = [
        "PATH"
        "NIX_PATH"
      ];
    }
    ];
  };
}
