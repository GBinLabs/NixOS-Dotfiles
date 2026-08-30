{
  disko.devices = {
    disk = {
      nixos = {
        type = "disk";
        device = "/dev/disk/by-id/ata-CT240BX500SSD1_2405E89596E8";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "2048M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            luks-main = {
              size = "100%";
              content = {
                type = "luks";
                name = "main";
                settings = {
                  allowDiscards = true;
                };
                extraFormatArgs = [
                  "--type luks2"
                  "--cipher aes-xts-plain64"
                  "--key-size 512"
                  "--pbkdf argon2id"
                  "--pbkdf-memory 2097152"
                  "--pbkdf-parallel 4"
                  "--iter-time 2000"
                ];
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "subvol=root"
                        "compress=zstd:3"
                        "noatime"
                        "space_cache=v2"
                        "discard=async"
                        "ssd"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "subvol=nix"
                        "compress=zstd:6"
                        "noatime"
                        "space_cache=v2"
                        "discard=async"
                        "ssd"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };

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
                settings = {
                  allowDiscards = true;
                };
                extraFormatArgs = [
                  "--type luks2"
                  "--cipher aes-xts-plain64"
                  "--key-size 512"
                  "--pbkdf argon2id"
                  "--pbkdf-memory 2097152"
                  "--pbkdf-parallel 4"
                  "--iter-time 2000"
                ];
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/games" = {
                      mountpoint = "/home/bin/Games";
                      mountOptions = [
                        "subvol=games"
                        "compress=zstd:3"
                        "noatime"
                        "space_cache=v2"
                        "discard=async"
                        "ssd"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };

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
                settings = {
                  allowDiscards = false;
                };
                extraFormatArgs = [
                  "--type luks2"
                  "--cipher aes-xts-plain64"
                  "--key-size 512"
                  "--pbkdf argon2id"
                  "--pbkdf-memory 2097152"
                  "--pbkdf-parallel 4"
                  "--iter-time 2000"
                ];
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "subvol=home"
                        "compress=zstd:3"
                        "noatime"
                        "space_cache=v2"
                        "autodefrag"
                      ];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "subvol=persist"
                        "compress=zstd:3"
                        "noatime"
                        "space_cache=v2"
                        "autodefrag"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
