{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.Juegos.gamescope;

  mangoappX11 = pkgs.writeShellScriptBin "mangoapp" ''
    unset WAYLAND_DISPLAY
    export XDG_SESSION_TYPE=x11

    exec ${pkgs.mangohud}/bin/mangoapp "$@"
  '';

  gamescopeFixed =
    pkgs.runCommand "gamescope-fixed"
      {
        nativeBuildInputs = [
          pkgs.makeBinaryWrapper
        ];
      }
      ''
        mkdir -p "$out/bin"

        makeWrapper \
          ${pkgs.gamescope}/bin/gamescope \
          "$out/bin/gamescope" \
          --prefix PATH : "${mangoappX11}/bin"

        ln -s \
          ${pkgs.gamescope}/bin/gamescopectl \
          "$out/bin/gamescopectl"
      '';

in
{
  options.Juegos.gamescope.enable = lib.mkEnableOption "Gamescope y Mangoapp";

  config = lib.mkIf cfg.enable {
    programs.gamescope = {
      enable = true;
      enableWsi = true;
      capSysNice = false;
      package = gamescopeFixed;
      args = [
        "--backend"
        "wayland"
        "--fullscreen"
        "-S"
        "stretch"
        "--force-grab-cursor"
        "-r"
        "180"
        "--expose-wayland"
        "--force-composition"
        "--mangoapp"
      ];
    };
  };
}
