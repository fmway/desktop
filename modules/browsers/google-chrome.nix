{ den, ... }:
{
  fmx.browsers._.google-chrome = {
    includes = [
      (den._.unfree [ "google-chrome" ])
    ];

    homeManager = { pkgs, ... }:
    {
      home.packages = [
        (pkgs.google-chrome.override (o: {
          commandLineArgs = o.commandLineArgs or [] ++ [
            "--enable-features=VaapiVideoDecodeLinuxGL,TouchpadOverscrollHistoryNavigation,AcceleratedVideoEncoder,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo"
            "--use-gl=angle"
            "--use-angle=gl"
            "--ozone-platform=wayland"
          ];
        }))
      ];
    };
  };
}
