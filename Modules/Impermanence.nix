{
  config,
  lib,
  pkgs,
  ...
}:
let

  mkResetService =
    device: subvolume:
    let
      mountPoint = "/mnt-reset-${device}";
    in
    {
      wantedBy = [ "initrd.target" ];

      after = [
        "systemd-cryptsetup@${device}.service"
        "local-fs-pre.target"
      ];

      before = [ "sysroot.mount" ];

      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";

      script = ''
        mkdir -p "${mountPoint}"

        mount -o subvolid=5 \
          "/dev/mapper/${device}" \
          "${mountPoint}"

        trap 'umount "${mountPoint}"' EXIT

        if [[ -e "${mountPoint}/${subvolume}" ]]; then
          btrfs subvolume list -o "${mountPoint}/${subvolume}" \
            | cut -f9- -d' ' \
            | sort -r \
            | while read -r sv; do
                btrfs subvolume delete "${mountPoint}/$sv" || true
              done

          btrfs subvolume delete \
            "${mountPoint}/${subvolume}" || true
        fi

        btrfs subvolume create \
          "${mountPoint}/${subvolume}"
      '';
    };

in
{
  options = {
    Reset.enable = lib.mkEnableOption "Reset PC (SSD + HDD)";
    Reset-Netbook.enable = lib.mkEnableOption "Reset Netbook (SSD único)";
    Persistencia = {
      enable = lib.mkEnableOption "Habilitar Persistencia";
      extraSystemDirectories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      extraUserDirectories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  config = lib.mkMerge [
    # ═══ PC DE JUEGOS ═══
    (lib.mkIf config.Reset.enable {
      fileSystems."/home".neededForBoot = true;
      fileSystems."/persist".neededForBoot = true;

      boot.initrd.systemd.services = {
        reset-root = mkResetService "main" "root";
        reset-home = mkResetService "data" "home";
      };

      systemd.services.setup-home = {
        description = "Configurar /home después del arranque";
        wantedBy = [ "multi-user.target" ];
        after = [ "local-fs.target" ];
        before = [ "display-manager.service" ];
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        script = ''
          for user in /persist/home/*; do
            [ -d "$user" ] || continue
            username=$(basename "$user")
            if [ ! -d "/home/$username" ]; then
              mkdir -p "/home/$username"
              cp -a /etc/skel/. "/home/$username/"
              id "$username" >/dev/null 2>&1 && chown -R "$username:users" "/home/$username"
              chmod 750 "/home/$username"
            fi
          done
        '';
        path = [ pkgs.coreutils ];
      };
    })

    # ═══ NETBOOK ═══
    (lib.mkIf config.Reset-Netbook.enable {
      fileSystems."/persist".neededForBoot = true;
      boot.initrd.systemd.services.reset-root = mkResetService "main" "root";
    })

    # ═══ PERSISTENCIA (ambos equipos) ═══
    (lib.mkIf config.Persistencia.enable {
      environment.persistence."/persist" = {
        enable = true;
        hideMounts = true;
        directories = [
          "/var/lib/nixos"
          "/var/lib/clamav"
          "/var/lib/systemd/timers"
          "/etc/NetworkManager/system-connections"
          "/var/lib/AccountsService"
          "/var/lib/sbctl"
        ]
        ++ config.Persistencia.extraSystemDirectories;

        users.bin = {
          directories = [
            "Descargas"
            "Documentos"
            "Imagenes"
            "Musica"
            "Videos"
            "Proyectos"
            "Publico"
            "Plantillas"
            ".GitHub"
            ".ssh"
            ".cache/nix"
            ".config/sops"
            ".config/git"
            ".config/obsidian"
            ".config/mozilla/firefox/default/storage/default"
            ".config/discord/Local Storage/leveldb"
            ".config/discord/Session Storage/leveldb"
            ".config/discord/IndexedDB/https_discord.com_0.indexeddb.leveldb"
          ]
          ++ config.Persistencia.extraUserDirectories;
          files = [
            ".p10k.zsh"
            ".zshrc"
            ".config/mozilla/firefox/default/favicons.sqlite"
            ".config/mozilla/firefox/default/cookies.sqlite"
            ".config/mozilla/firefox/default/key4.db"
            ".config/mozilla/firefox/default/places.sqlite"
            ".config/mozilla/firefox/default/permissions.sqlite"
            ".config/discord/Cookies"
            ".config/discord/Network/Cookies"
          ];
        };
      };
    })
  ];
}
