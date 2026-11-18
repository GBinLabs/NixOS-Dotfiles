{
  config,
  lib,
  ...
}:
{
  options.Capture.yakc.enable = lib.mkEnableOption "YAKC para visualizacion de inputs en OBS";

  config = lib.mkIf config.Capture.yakc.enable {
    home-manager.sharedModules = [
      (
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          yakcConfig = pkgs.writeText "yakc-config.json" (
            builtins.toJSON {
              displayStyle = "keyboard";

              keyboardVisibleKeys = [
                "Backquote"
                "Digit1"
                "Digit2"
                "Digit3"
                "Digit4"
                "Tab"
                "KeyQ"
                "KeyW"
                "KeyE"
                "KeyR"
                "KeyT"
                "KeyA"
                "KeyS"
                "KeyD"
                "KeyF"
                "KeyG"
                "ShiftLeft"
                "KeyZ"
                "KeyX"
                "KeyC"
                "KeyV"
                "ControlLeft"
                "Space"
              ];

              showKeyboardClick = true;
              showMouseClick = true;
              showMouseMovement = true;
              showMouseScroll = true;
              showGamepad = false;

              obsServerEnabled = true;
              obsServerPort = 7238;
              showOverlayOnScreen = false;

              popupFontColor = "#E7EFF7";
              popupBackgroundColor = "#081B2C";
              popupOpacity = 0.85;
              deviceWidgetScale = 0.7;

              textToSpeech = false;
              toggleCaptureHotkey = "Ctrl+Alt+Y";
            }
          );
        in
        {
          home.packages = [ pkgs.yakc ];

          home.activation.yakcConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            run ${pkgs.coreutils}/bin/install -Dm0644 \
              ${yakcConfig} \
              "${config.xdg.configHome}/dev.iammodev.yakc/config.json"
          '';

          systemd.user.services.yakc = {
            Unit = {
              Description = "YAKC - Input Overlay for OBS";
              After = [ "graphical-session.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            
            Install.WantedBy = [ "graphical-session.target" ];

            Service = {
              ExecStart = "${pkgs.yakc}/bin/yakc";
              Restart = "on-failure";
              RestartSec = 3;
            };
          };
        }
      )
    ];
  };
}
