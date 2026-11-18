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
    set -eu
    case "''${1-}" in
      mute|unmute) ;;
      *) echo 'Uso: obs-mic {mute|unmute}' >&2; exit 2 ;;
    esac

    password="$(<${lib.escapeShellArg passwordFile})"
    if [[ -z "$password" ]]; then
      echo 'obs-mic: secreto vacío' >&2
      exit 1
    fi
    export OBS_WEBSOCKET_URL="obsws://127.0.0.1:4455/$password"
    exec ${lib.getExe pkgs.obs-cmd} audio "$1" "Mic/Aux"
  '';

  obsPtt = pkgs.writeShellScript "obs-ptt" ''
    set -eu
    exec ${lib.getExe pkgs.evsieve} \
      --input ${lib.escapeShellArg cfg.mouseDevice} \
      --hook 'btn:%275:1' exec-shell='${obsMic} unmute' \
      --hook 'btn:%275:0' exec-shell='${obsMic} mute'
  '';
in
{
  options.Capture.pushToTalk = {
    enable = lib.mkEnableOption "Push-to-Talk para OBS mediante evsieve y obs-websocket";

    user = lib.mkOption {
      type = lib.types.str;
      default = "bin";
      example = "usuario";
      description = "Usuario propietario de la sesión OBS";
    };

    mouseDevice = lib.mkOption {
      type = lib.types.str;
      example = "/dev/input/by-id/usb-Logitech_G203_LIGHTSYNC-event-mouse";
      description = "Ruta del dispositivo de entrada que contiene el botón configurado";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.Capture.obs.enable;
        message = "Capture.pushToTalk requiere Capture.obs.enable = true.";
      }
    ];

    systemd.user.services.obs-ptt = {
      description = "OBS push-to-talk (evsieve)";
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
  };
}
