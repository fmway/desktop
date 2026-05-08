{
  fmx.essentials._.timezone = { host, ... }: let
    timeZone = host.aspect.meta.timeZone or host.aspect.meta.timezone or "Asia/Jakarta";
    defaultLocale = host.aspect.meta.defaultLocale or host.aspect.meta.locale or "en_US.UTF-8";
    extraLocale = host.aspect.meta.extraLocale or defaultLocale;
  in {
    nixos = { ... }:
    {
      time.timeZone = timeZone;
      i18n.defaultLocale = defaultLocale;
      i18n.extraLocaleSettings = {
        LC_ADDRESS = extraLocale;
        LC_IDENTIFICATION = extraLocale;
        LC_MEASUREMENT = extraLocale;
        LC_MONETARY = extraLocale;
        LC_NAME = extraLocale;
        LC_NUMERIC = extraLocale;
        LC_PAPER = extraLocale;
        LC_TELEPHONE = extraLocale;
        LC_TIME = extraLocale;
      };
    };
  };
}
