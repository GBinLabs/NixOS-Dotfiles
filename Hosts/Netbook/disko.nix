{
  disko.devices = {
    disk = {
      ssd = {
        device = "/dev/disk/by-id/ata-kimtigo_SSD_480GB_HNSD237012N_3307385";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2048M";
              type = "EF00";
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
                  "--pbkdf-parallel 2"
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
                        "compress=zstd:3"
                        "noatime"
                        "space_cache=v2"
                        "discard=async"
                        "ssd"
                      ];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "subvol=persist"
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
    };
  };
}
