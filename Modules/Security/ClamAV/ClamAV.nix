{...}: {
  services.clamav = {
    daemon = {
      enable = true;
      settings.LocalSocketMode = "660";
    };

    updater.enable = true;

    scanner = {
      enable = true;
      interval = "Sun *-*-* 04:00:00";
      scanDirectories = [
        "/boot"
        "/etc"
        "/home"
        "/nix/store"
        "/root"
        "/tmp"
        "/var"
      ];
    };
  };

  systemd = {
    timers.clamdscan.timerConfig = {
      Persistent = true;
      RandomizedDelaySec = "30m";
    };

    slices.system-clamav.sliceConfig = {
      CPUWeight = 20;
      IOWeight = 20;
    };
  };
}
