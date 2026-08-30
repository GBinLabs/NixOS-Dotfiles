{
  config,
  lib,
  ...
}: {
  options = {
    git-config = {
      enable = lib.mkEnableOption "Habilitar Git";

      keyFile = lib.mkOption {
        type = lib.types.str;
        description = "Ruta a la clave SSH para Git";
      };
    };

    ssh-config = {
      enable = lib.mkEnableOption "Configuración SSH extendida";

      pcKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Clave privada para conectar al PC";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.git-config.enable {
      programs.git = {
        enable = true;
        signing = {
          signByDefault = true;
          key = config.git-config.keyFile;
          format = "ssh";
        };
        settings = {
          user = {
            name = "GBinLabs";
            email = "anonimo@anonimo.com";
          };
          init.defaultBranch = "main";
          core = {
            fsmonitor = true;
            untrackedCache = true;
            pager = "delta";
          };
          feature.manyFiles = true;
          interactive.diffFilter = "delta --color-only";
          delta = {
            navigate = true;
            line-numbers = true;
            side-by-side = true;
          };
          merge.conflictstyle = "diff3";
          diff.colorMoved = "default";
          pack = {
            threads = "0";
            windowMemory = "100m";
          };
        };
      };
    })

    (lib.mkIf config.ssh-config.enable {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        matchBlocks = {
          "*" = {
            extraOptions = {
              AddKeysToAgent = "yes";
              IdentitiesOnly = "yes";
            };
          };

          "github.com" = {
            hostname = "github.com";
            user = "git";
            identityFile = config.git-config.keyFile;
            identitiesOnly = true;
          };

          "codeberg.org" = {
            hostname = "codeberg.org";
            user = "git";
            identityFile = config.git-config.keyFile;
            identitiesOnly = true;
          };

          "bin-pc" = lib.mkIf (config.ssh-config.pcKeyFile != null) {
            hostname = "bin-pc";
            user = "bin";
            identityFile = config.ssh-config.pcKeyFile;
            identitiesOnly = true;
            extraOptions = {
              ConnectTimeout = "10";
              ServerAliveInterval = "60";
              ServerAliveCountMax = "3";
            };
          };
        };
      };

      services.ssh-agent.enable = true;
    })
  ];
}
