{ lib, ... }: self: super:
{
  scroll = self.sway.override {
    sway-unwrapped = self.scroll-unwrapped;
  };
  scroll-unwrapped = import ./unwrapped { inherit lib; pkgs = self; };
}
