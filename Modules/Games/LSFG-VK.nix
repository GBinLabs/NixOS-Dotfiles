{ config, lib, ... }:
let
  cfg = config.Juegos.LSFG-VK;
in
{
  options.Juegos.LSFG-VK.enable = lib.mkEnableOption "LSFG-VK (Home Manager)";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      (
        { pkgs, ... }:
        let
          lsfgConfig = (pkgs.formats.toml { }).generate "conf.toml" {
            version = 2;

            global = {
              allow_fp16 = true;
              dll = "/home/bin/Games/SteamLibrary/steamapps/common/Lossless Scaling/lsfg-vk.dll";
            };

            profile = [
              {
                name = "3x";
                multiplier = 3;
                flow_scale = 0.40;
                performance_mode = true;
                pacing = "vsync";
                override_present_mode = false;
                preserve_swapchain_image_count = false;
              }
            ];
          };
        in
        {
          xdg.configFile."lsfg-vk/conf.toml".source = lsfgConfig;
          home.packages = with pkgs; [ lsfg-vk ];
        }
      )
    ];
  };
}
