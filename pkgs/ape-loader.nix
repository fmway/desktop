# https://git.sr.ht/~jack/cosmo.nix/tree/master/item/pkgs/ape-loader/default.nix
{ internal, lib, self, pkgs ? self, ... }:
_: let
  pname = "ape-loader";
  version = "4.0.2";
  arch = pkgs.hostPlatform.linuxArch;
in pkgs.stdenv.mkDerivation {
  inherit pname version;
  src = pkgs.fetchurl {
    url = "https://cosmo.zip/pub/cosmos/v/${version}/bin/ape-${arch}.elf";
    hash = {
      aarch64 = "sha256-h3zL1GUkMGVCbLSjyrQ1GsrZGGSfhlZVa7YEiC7q0I8=";
      x86_64  = "sha256-fBz4sk4bbdatfaOBcEXVgq2hRrTW7AxqRb6oMOOmX00=";
    }.${arch};
  };

  dontUnpack = true;
  installPhase = "install -D -m 755 $src $out/bin/ape";

  meta = {
    homepage = "https://justine.lol/ape.html";
    description = "Loader for αcτµαlly pδrταblε εxεcµταblεs";
    longDescription = ''
      A loader for polyglot executables that run on AArch64 and
      x86_64 under Linux + Mac + Windows + FreeBSD + OpenBSD 7.3 +
      NetBSD + BIOS.
    '';
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.endgame ];
    platforms = [ "aarch64-linux" "x86_64-linux" ];
  };
}
