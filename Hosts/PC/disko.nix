_:

let
  # LUKS2: AES-256-XTS + Argon2id.
  luksFormatArgs = [
    "--type luks2"
    "--cipher aes-xts-plain64"
    "--key-size 512"
    "--pbkdf argon2id"
    "--pbkdf-memory 2097152"
    "--pbkdf-parallel 4"
    "--iter-time 2000"
  ];

  # SSD: compresion, sin atime y TRIM asincrono.
  ssdMountOptions = [
    "compress=zstd:3"
    "noatime"
    "discard=async"
  ];

  # HDD: compresion, sin atime.
  hddMountOptions = [
    "compress=zstd:3"
    "noatime"
  ];
in
{
  disko.devices.disk = {

    # SSD 1: Sistema operativo.
    nixos = {
      type = "disk";
      device = "/dev/disk/by-id/ata-CT240BX500SSD1_2405E89596E8";

      content = {
        type = "gpt";

        partitions = {
          ESP = {
            priority = 1;
            type = "EF00";
            size = "2048M";

            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          luks-main = {
            size = "100%";

            content = {
              type = "luks";
              name = "main";

              settings.allowDiscards = true;
              extraFormatArgs = luksFormatArgs;

              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = ssdMountOptions;
                  };

                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = ssdMountOptions;
                  };

                  # Swap cifrada y separada para hibernacion.
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    mountOptions = ssdMountOptions;
                    swap.swapfile.size = "32G";
                  };
                };
              };
            };
          };
        };
      };
    };

    # SSD 2: Juegos y modelos de IA.
    games = {
      type = "disk";
      device = "/dev/disk/by-id/ata-CT240BX500SSD1_1927E18C1B5A";

      content = {
        type = "gpt";

        partitions = {
          luks-games = {
            size = "100%";

            content = {
              type = "luks";
              name = "games";

              settings.allowDiscards = true;
              extraFormatArgs = luksFormatArgs;

              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {
                  "/games" = {
                    mountpoint = "/home/bin/Games";
                    mountOptions = ssdMountOptions;
                  };
                };
              };
            };
          };
        };
      };
    };

    # HDD: Datos personales y persistencia.
    data = {
      type = "disk";
      device = "/dev/disk/by-id/ata-ST2000DM005-2CW102_ZFM1M48B";

      content = {
        type = "gpt";

        partitions = {
          luks-data = {
            size = "100%";

            content = {
              type = "luks";
              name = "data";

              settings.allowDiscards = false;
              extraFormatArgs = luksFormatArgs;

              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = hddMountOptions;
                  };

                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = hddMountOptions;
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  # TRIM periodico de los SSD.
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # Verificacion mensual de integridad Btrfs.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";

    fileSystems = [
      "/"
      "/home/bin/Games"
      "/home"
    ];
  };
}
