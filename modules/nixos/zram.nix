{ lib, ... }:
{
  # zramSwap.enable = lib.mkDefault true;
  # zramSwap.swapDevices = lib.mkDefault 4;
  # zramSwap.memoryMax = lib.mkDefault 2147483648; # 2GB per devices
  services.zram-generator = {
    enable = true;
    settings = {
      zram0 = {
        compression-algorithm = "zstd lz4 (type=huge)";
        ram-size = 16384; # 16GB
        fs-type = "swap";
        swap-priority = 100;
      };
    };
  };
}
