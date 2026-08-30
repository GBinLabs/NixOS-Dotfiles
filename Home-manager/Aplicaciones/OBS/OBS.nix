{
  pkgs,
  config,
  osConfig,
  ...
}: {
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-vkcapture
    ];
  };

  xdg.configFile."obs-studio/basic/profiles/YouTube-HEVC-1440p/basic.ini".source =
    ./YouTube-HEVC-1440p/basic.ini;

  xdg.configFile."obs-studio/basic/profiles/YouTube-HEVC-1440p/recordEncoder.json".source =
    ./YouTube-HEVC-1440p/recordEncoder.json;

  xdg.configFile."obs-studio/basic/scenes/Linux-Gaming.json".source =
    ./YouTube-HEVC-1440p/Linux-Gaming.json;

  xdg.configFile."obs-studio/plugin_config/obs-websocket/config.json" = {
    source =
      config.lib.file.mkOutOfStoreSymlink
      osConfig.sops.templates."obs-websocket-config.json".path;

    force = true;
  };
}
