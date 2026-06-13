{
  fmx.essentials.zram.nixos = { host, ... }:
  {
    # zramSwap.enable = lib.mkDefault true;
    # zramSwap.swapDevices = lib.mkDefault 4;
    # zramSwap.memoryMax = lib.mkDefault 2147483648; # 2GB per devices
    services.zram-generator = {
      enable = true;
      settings = {
        zram0 = {
          compression-algorithm = "zstd lz4 (type=huge)";
          zram-size = host.zram.size or "ram / 2";
          fs-type = "swap";
          swap-priority = host.zram.priority or 100;
        };
      };
    };
  };
}
