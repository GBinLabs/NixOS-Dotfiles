{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.Juegos.environment;
in
{
  options.Juegos.environment.enable = lib.mkEnableOption "GameMode y optimizaciones para juegos";

  config = lib.mkIf cfg.enable {
    programs = {
      gamemode = {
        enable = true;
        enableRenice = true;

        settings = {
          general = {
            renice = 10;
            ioprio = 0;
            inhibit_screensaver = 1;
          };
          gpu = {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = 1;
            amd_performance_level = "high";
          };
          cpu.park_cores = "no";
        };
      };
    };

    services.udev.extraRules = ''ACTION=="add", SUBSYSTEM=="drm", KERNEL=="card[0-9]*", DRIVERS=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/drm/%k/device/power_dpm_force_performance_level", RUN+="${pkgs.coreutils}/bin/chgrp gamemode /sys/class/drm/%k/device/power_dpm_force_performance_level" '';

    environment.systemPackages = with pkgs; [
      low-latency-layer
    ];
  };
}
