{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    Boot-PC.enable = lib.mkEnableOption "Boot-PC (AMD)";
    Boot-Netbook.enable = lib.mkEnableOption "Boot-Netbook (Intel)";
  };

  config = lib.mkMerge [
    {
      boot = {
        loader = {
          systemd-boot = {
            enable = lib.mkForce false;
          };
          efi.canTouchEfiVariables = true;
          timeout = 10;
        };

        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };

        kernelPackages = pkgs.linuxPackages_cachyos-lto;

        initrd = {
          compressor = "zstd";
          compressorArgs = [
            "-10"
            "-T0"
          ];
          verbose = false;
          systemd.enable = true;
        };

        plymouth = {
          enable = true;
          theme = "bgrt";
        };

        consoleLogLevel = 0;
      };

      hardware.bluetooth = {
        enable = false;
        powerOnBoot = false;
      };

      networking.networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        wifi.powersave = true;
      };

      documentation.enable = false;
      documentation.nixos.enable = false;
    }

    (lib.mkIf config.Boot-PC.enable {
  boot = {
    kernelModules = [
      "amdgpu"
    ];

    kernelParams = [
      "threadirqs"
      "preempt=full"
    ];
  };
})

    (lib.mkIf config.Boot-Netbook.enable {
      boot = {
        kernelModules = ["i915"];
      };
    })
  ];
}
