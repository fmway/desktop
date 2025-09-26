{
  services.zfs.autoSnapshot = {
    enable = true;
    frequent = 0;
    hourly = 0;
    daily = 0;
    weekly = 2;
    monthly = 1;
  };

  services.zfs.autoScrub.interval = "weekly";
}
