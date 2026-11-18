{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.Juegos.freesmlauncher;
in
{
  options.Juegos.freesmlauncher.enable = lib.mkEnableOption "FreesmLauncher (Minecraft)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.freesmlauncher.override {
        controllerSupport = false;
        gamemodeSupport = true;
        textToSpeechSupport = false;
        jdks = inputs.freesmlauncher.packages.${pkgs.stdenv.hostPlatform.system}.jvmPack.temurin;
        msaClientID = null;
      })
    ];
  };
}
