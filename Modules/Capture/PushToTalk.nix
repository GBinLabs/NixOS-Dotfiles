{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.Capture.pushToTalk;

  passwordFile = config.sops.secrets."obs-websocket-password".path;

  obsMic = pkgs.writeShellScript "obs-mic" ''
    set -euo pipefail

    case "''${1-}" in
      mute|unmute) ;;
      *) exit 2 ;;
    esac

    password="$(<${lib.escapeShellArg passwordFile})"

    if [[ -z "$password" ]]; then
      echo "obs-mic: secreto vacío" >&2
      exit 1
    fi

    export OBS_WEBSOCKET_URL="obsws://127.0.0.1:4455/$password"

    exec ${lib.getExe pkgs.obs-cmd} audio "$1" "Mic/Aux"
  '';

  obsMicMode = pkgs.writeShellScriptBin "obs-mic-mode" ''
    set -euo pipefail
    umask 077

    action="''${1-}"

    case "$action" in
      press|release|toggle|reset|sync|status) ;;
      *)
        echo "Uso: obs-mic-mode {press|release|toggle|reset|sync|status}" >&2
        exit 2
        ;;
    esac

    runtime="''${XDG_RUNTIME_DIR:?Se requiere XDG_RUNTIME_DIR}"
    state_file="$runtime/obs-ptt.state"
    lock_file="$runtime/obs-ptt.lock"

    exec 9>"$lock_file"
    ${pkgs.util-linux}/bin/flock -x 9

    mode="ptt"
    held=0

    if [[ -f "$state_file" ]]; then
      read -r mode held < "$state_file"

      if [[ "$mode" != "ptt" && "$mode" != "open" ]]; then
        mode="ptt"
      fi

      if [[ "$held" != 0 && "$held" != 1 ]]; then
        held=0
      fi
    fi

    if [[ "$action" == "status" ]]; then
      echo "Modo: $mode | Botón presionado: $held"
      exit 0
    fi

    old_mode="$mode"
    old_held="$held"

    case "$action" in
      press)
        held=1
        ;;
      release)
        held=0
        ;;
      toggle)
        if [[ "$mode" == "ptt" ]]; then
          mode="open"
        else
          mode="ptt"
        fi
        ;;
      reset)
        mode="ptt"
        held=0
        ;;
      sync)
        ;;
    esac

    old_unmuted=0
    new_unmuted=0

    if [[ "$old_mode" == "open" || "$old_held" == 1 ]]; then
      old_unmuted=1
    fi

    if [[ "$mode" == "open" || "$held" == 1 ]]; then
      new_unmuted=1
    fi

    if [[ "$action" == "reset" ||
          "$action" == "sync" ||
          "$old_unmuted" != "$new_unmuted" ]]; then

      if [[ "$new_unmuted" == 1 ]]; then
        ${obsMic} unmute
      else
        ${obsMic} mute
      fi
    fi

    printf '%s %s\n' "$mode" "$held" > "$state_file"

    if [[ "$action" == "toggle" ]]; then
      echo "Modo: $mode"
    fi
  '';

  obsPtt = pkgs.writeShellScript "obs-ptt" ''
    set -eu

    exec ${lib.getExe pkgs.evsieve} \
      --input ${lib.escapeShellArg cfg.mouseDevice} \
      --hook 'btn:%275:1' \
        exec-shell='${lib.getExe obsMicMode} press' \
      --hook 'btn:%275:0' \
        exec-shell='${lib.getExe obsMicMode} release'
  '';
in
{
  options.Capture.pushToTalk = {
    enable = lib.mkEnableOption "Push-to-Talk de OBS con modo abierto permanente";

    user = lib.mkOption {
      type = lib.types.str;
      default = "bin";
      example = "usuario";
      description = "Usuario propietario de OBS";
    };

    mouseDevice = lib.mkOption {
      type = lib.types.str;
      example = "/dev/input/by-id/usb-Logitech_G203_LIGHTSYNC-event-mouse";
      description = "Dispositivo del botón Push-to-Talk";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.Capture.obs.enable;
        message = "Capture.pushToTalk requiere Capture.obs.enable = true.";
      }
    ];

    environment.systemPackages = [
      obsMicMode
    ];

    systemd.user.services.obs-ptt = {
      description = "OBS Push-to-Talk con modo permanente";

      wantedBy = [ "default.target" ];

      unitConfig.ConditionUser = cfg.user;

      serviceConfig = {
        ExecStart = obsPtt;
        Restart = "always";
        RestartSec = "5s";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
      };
    };

    home-manager.users.${cfg.user}.dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/obs-mic-mode/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/obs-mic-mode" = {
        name = "OBS — Micrófono permanente";
        command = "${lib.getExe obsMicMode} toggle";
        binding = "<Alt>f";
      };
    };

  };
}
