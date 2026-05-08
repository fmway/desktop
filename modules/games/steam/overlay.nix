self: super:
{
  # gamescope with tap-to-click feature
  gamescope = super.gamescope.overrideAttrs (o: {
    patches = o.patches or [] ++ [
      ./libinput.patch
    ];
  });
}
