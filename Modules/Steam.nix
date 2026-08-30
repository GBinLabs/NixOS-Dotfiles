{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  options.Steam.enable = lib.mkEnableOption "Habilitar Steam con optimizaciones gaming";

  config = lib.mkIf config.Steam.enable {
    programs = {
      steam = {
        enable = true;
        platformOptimizations.enable = true;
        extraCompatPackages = with pkgs; [
          proton-ge-custom
          proton-cachyos_x86_64_v3
        ];
      };
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

          cpu = {
            park_cores = "no";
          };
        };
      };
    };

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="drm", KERNEL=="card[0-9]*", DRIVERS=="amdgpu", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/drm/%k/device/power_dpm_force_performance_level", RUN+="${pkgs.coreutils}/bin/chgrp gamemode /sys/class/drm/%k/device/power_dpm_force_performance_level"
    '';

    systemd.tmpfiles.rules = [
      "d /home/bin/Games 0755 bin users -"
      "d /home/bin/Games/SteamLibrary 0755 bin users -"
    ];

    environment.systemPackages = with pkgs; [
      low-latency-layer
      (freesmlauncher.override {
        controllerSupport = false;
        gamemodeSupport = true;
        textToSpeechSupport = false;
        jdks = inputs.freesmlauncher.packages.${pkgs.stdenv.hostPlatform.system}.jvmPack.temurin;
        msaClientID = null;
      })
      hytale-launcher
    ];
  };
}

