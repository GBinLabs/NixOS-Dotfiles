{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.LSFG;
  launcher = pkgs.writeShellApplication {
    name = "lsfg-run";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      if (( $# == 0 )); then
        printf 'Uso: lsfg-run COMANDO [ARGUMENTOS…]\nSolo aplicaciones que presenten mediante Vulkan.\n' >&2
        exit 2
      fi
      exec env -u DISABLE_LSFGVK LSFGVK_PROFILE="''${LSFGVK_PROFILE:-2x}" "$@"
    '';
  };
in
{
  options.LSFG = {
    enable = lib.mkEnableOption "LSFG para aplicaciones Vulkan";
    enable32Bit = lib.mkOption {
      type = lib.types.bool;
      default = config.Steam.enable;
      description = "Instalar también la capa LSFG de 32 bits.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      extraPackages = [ pkgs.lsfg-vk ];
      enable32Bit = lib.mkIf cfg.enable32Bit true;
      extraPackages32 = lib.optionals cfg.enable32Bit [ pkgs.pkgsi686Linux.lsfg-vk ];
    };

    # Instalar la capa no activa interpolación en todos los procesos.
    environment.sessionVariables.DISABLE_LSFGVK = "1";
    environment.systemPackages = [
      pkgs.lsfg-vk
      launcher
    ];
  };
}
