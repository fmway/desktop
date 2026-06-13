{
  fmx.browsers.helium.homeManager =
    { inputs', ... }:
    {
      home.packages = [
        (inputs'.helium.packages.default.overrideAttrs (o: {
          installPhase = builtins.replaceStrings 
            [ "makeWrapper $out/opt/helium/helium $out/bin/helium \\" "--enable-features=" ] [ /* sh */ ''
              makeWrapper $out/opt/helium/helium $out/bin/helium \
                --add-flags "--ozone-platform=wayland" \
                --add-flags "--use-gl=angle" \
                --add-flags "--use-angle=gl" \''
              "--enable-features=VaapiVideoDecodeLinuxGL,TouchpadOverscrollHistoryNavigation,AcceleratedVideoEncoder,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo,"
            ] o.installPhase;
        }))
      ];
    };
  fmx.browsers.helium = {
    includes = [
      ({ host, user, persistent, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".cache/net.imput.helium"
        ];
        persistence.${persistent.defaultDirectory}.users.${user.userName}.directories = [
          ".config/net.imput.helium"
        ];
      })
    ];
  };
  flake-file.inputs = {
    helium.url = "github:vikingnope/helium-browser-nix-flake";
    helium.inputs.nixpkgs.follows = "nixpkgs";
  };
}
