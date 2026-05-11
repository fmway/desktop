{
  fmx.essentials._.timezone.nixos = { host, ... }: let
    timeZone = host.timeZone or null;
    defaultLocale = host.locale or "en_US.UTF-8";
    extraLocale = host.extraLocale or defaultLocale;
  in {
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
}
