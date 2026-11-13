{
  config,
  lib,
  ...
}:
let
  scanDirectories = [
    "/boot"
    "/etc"
    "/home"
    "/root"
    "/tmp"
    "/var"
  ];
in
{
  services.clamav = {
    # Las firmas se cargan al analizar y se liberan cuando termina clamscan.
    daemon.enable = false;
    scanner.enable = false;
    updater.enable = true;
  };

  systemd = {
    services.clamav-scan = {
      description = "Análisis semanal de ClamAV";
      wants = [ "clamav-freshclam.service" ];
      after = [ "clamav-freshclam.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${config.services.clamav.package}/bin/clamscan --recursive --infected --allmatch --database=/var/lib/clamav ${lib.escapeShellArgs scanDirectories}";
        Nice = 19;
        IOSchedulingClass = "idle";
        Slice = "system-clamav.slice";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [ "/tmp" ];
        # Se analiza el /tmp real, no un directorio privado del servicio.
        PrivateTmp = false;
      };
    };

    timers.clamav-scan = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "Sun *-*-* 04:00:00";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };

    slices.system-clamav.sliceConfig = {
      CPUWeight = 20;
      IOWeight = 20;
    };
  };
}
