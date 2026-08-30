{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.gnome-vram-booster;
  dmemcgBooster = pkgs.jovian-chaotic.dmemcg-booster;
in {
  options.services.gnome-vram-booster = {
    enable = lib.mkEnableOption "priorización dinámica de VRAM para GNOME";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gnome-vram-booster;
      defaultText = lib.literalExpression "pkgs.gnome-vram-booster";
      description = "Paquete que contiene el daemon y la extensión de GNOME.";
    };

    boostRatio = lib.mkOption {
      type = lib.types.float;
      default = 0.90;
      description = "Fracción de la VRAM protegida para la aplicación enfocada.";
    };

    drmKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "drm/0000:03:00.0/vram";
      description = "Clave DRM que se debe priorizar; null selecciona automáticamente la GPU con más VRAM.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.desktopManager.gnome.enable;
        message = "services.gnome-vram-booster requiere GNOME.";
      }
      {
        assertion = cfg.boostRatio > 0.0 && cfg.boostRatio <= 1.0;
        message = "services.gnome-vram-booster.boostRatio debe pertenecer al intervalo (0, 1].";
      }
    ];

    environment.systemPackages = [cfg.package];

    services.dbus.packages = [cfg.package];

    systemd.packages = [dmemcgBooster];

    systemd.services.dmemcg-booster-system = {
      overrideStrategy = "asDropin";
      wantedBy = ["multi-user.target"];
    };

    systemd.user.services.dmemcg-booster-user = {
      overrideStrategy = "asDropin";
      wantedBy = ["graphical-session-pre.target"];
    };

    systemd.services.gnome-vram-booster = {
      description = "GNOME VRAM Booster";
      requires = ["dmemcg-booster-system.service"];
      after = ["dmemcg-booster-system.service"];
      wantedBy = ["multi-user.target"];

      environment =
        {
          RUST_LOG = "warn";
          VRAM_BOOST_RATIO = toString cfg.boostRatio;
        }
        // lib.optionalAttrs (cfg.drmKey != null) {
          DRM_KEY = cfg.drmKey;
        };

      serviceConfig = {
        Type = "dbus";
        BusName = "org.gnome.VramBooster";
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = "3s";

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = ["/sys/fs/cgroup"];
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectClock = true;
        ProtectHostname = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        RestrictAddressFamilies = ["AF_UNIX"];
        IPAddressDeny = "any";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service"];
        SystemCallErrorNumber = "EPERM";
        CapabilityBoundingSet = ["CAP_DAC_OVERRIDE"];
        UMask = "0077";
      };
    };
  };
}
