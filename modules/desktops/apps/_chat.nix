{
  dbus = {
    enable = true;
    policies = {
      "org.gnome.Mutter.IdleMonitor" = "talk";
      "org.freedesktop.Notifications" = "talk";
      "org.kde.StatusNotifierWatcher" = "talk";
      "com.canonical.AppMenu.Registrar" = "talk";
      "com.canonical.indicator.application" = "talk";
      "org.ayatana.indicator.application" = "talk";
      "org.sigxcpu.Feedback" = "talk";
    };
  };
}
