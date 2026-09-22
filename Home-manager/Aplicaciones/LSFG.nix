{
  config,
  lib,
  osConfig,
  ...
}:
{
  config = lib.mkIf osConfig.LSFG.enable {
    # El PC usa su biblioteca de Steam; la Netbook conserva una copia de la DLL.
    # Home Manager recrea el perfil; no requiere persistencia adicional.
    xdg.configFile."lsfg-vk/conf.toml".text = ''
      version = 2

      [global]
      dll = "${config.home.homeDirectory}/${
        if osConfig.Steam.enable then
          "Games/SteamLibrary/steamapps/common/Lossless Scaling"
        else
          ".local/share/lossless-scaling"
      }/lsfg-vk.dll"
      allow_fp16 = true

      [[profile]]
      name = "2x"
      active_in = []
      multiplier = 2
      flow_scale = 0.75
      performance_mode = true
      pacing_mode = "vsync"
      override_present_mode = true
    '';
  };
}
