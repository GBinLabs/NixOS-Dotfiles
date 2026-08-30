{
  config,
  lib,
  pkgs,
  ...
}: let
  passwordFile = config.sops.secrets."obs-websocket-password".path;

  mouseDevice = "/dev/input/by-id/usb-Logitech_G203_LIGHTSYNC_Gaming_Mouse_205C37855631-event-mouse";

  obsMic = pkgs.writeShellScript "obs-mic" ''
    set -eu

    case "''${1-}" in
      mute | unmute) ;;
      *)
        printf 'Uso: obs-mic {mute|unmute}\n' >&2
        exit 2
        ;;
    esac

    password="$(<${lib.escapeShellArg passwordFile})"

    if [[ -z "$password" ]]; then
      printf 'obs-mic: el secreto está vacío\n' >&2
      exit 1
    fi

    export OBS_WEBSOCKET_URL="obsws://127.0.0.1:4455/$password"

    exec ${lib.getExe pkgs.obs-cmd} \
      audio "$1" "Mic/Aux"
  '';

  obsPtt = pkgs.writeShellScript "obs-ptt" ''
    set -eu

    exec ${lib.getExe pkgs.evsieve} \
      --input ${lib.escapeShellArg mouseDevice} \
      --hook 'btn:%275:1' \
        exec-shell='${obsMic} unmute' \
      --hook 'btn:%275:0' \
        exec-shell='${obsMic} mute'
  '';
in {
  systemd.user.services.obs-ptt = {
    description = "OBS push-to-talk";

    # Gnome usa graphical.target, no graphical-session.target
    wantedBy = ["default.target"];

    # Dependencias genéricas que funcionan en Gnome
    after = ["sops.service" "network-online.target"];

    unitConfig.ConditionUser = "bin";

    serviceConfig = {
      ExecStart = obsPtt;

      Restart = "always";
      RestartSec = "5s";

      NoNewPrivileges = true;
      ProtectSystem = "strict";
    };
  };
}
