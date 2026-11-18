{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  profileName = "Twitch-900p-YouTube-1080p";
  obsDir = "${config.xdg.configHome}/obs-studio";
  profileDir = "${obsDir}/basic/profiles/${profileName}";
  scenesDir = "${obsDir}/basic/scenes";
  ini = ./Profiles/Twitch-900p-YouTube-1080p/basic.ini;
  encoder = ./Profiles/Twitch-900p-YouTube-1080p/recordEncoder.json;
  streamEncoder = ./Profiles/Twitch-900p-YouTube-1080p/streamEncoder.json;
  scene = ./Scenes/Linux-Gaming.json;
in
{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-vkcapture
      obs-multi-rtmp
    ];
  };

  home.activation.obsCaptureTemplates = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.coreutils}/bin/mkdir -p \
        "${config.home.homeDirectory}/Videos/YouTube" \
        "${profileDir}" \
        "${scenesDir}"

      run ${pkgs.coreutils}/bin/install -m 0644 \
        ${ini} "${profileDir}/basic.ini"

      run ${pkgs.coreutils}/bin/install -m 0644 \
        ${encoder} "${profileDir}/recordEncoder.json"

      run ${pkgs.coreutils}/bin/install -m 0644 \
        ${streamEncoder} "${profileDir}/streamEncoder.json"

      run ${pkgs.coreutils}/bin/install -m 0600 \
    "${osConfig.sops.templates."obs-linux-gaming.json".path}" \
    "${scenesDir}/Linux-Gaming.json"
  '';

  home.activation.obsTwitchService = lib.hm.dag.entryAfter [ "obsCaptureTemplates" ] ''
    if [ -z "''${DRY_RUN:-}" ]; then
      destination="${profileDir}/service.json"
      source="${osConfig.sops.templates."obs-twitch-service.json".path}"

      test -r "$source" || {
        echo "OBS: no se encuentra la plantilla SOPS" >&2
        exit 1
      }

      tmp="$(${pkgs.coreutils}/bin/mktemp "$destination.XXXXXX")"

      ${pkgs.coreutils}/bin/install \
        -m 0600 "$source" "$tmp"

      ${pkgs.coreutils}/bin/mv -f \
        "$tmp" "$destination"
    fi
  '';

  home.activation.obsMultiRTMP = lib.hm.dag.entryAfter [ "obsCaptureTemplates" ] ''
    run ${pkgs.coreutils}/bin/install -m 0600 \
      "${osConfig.sops.templates."obs-multi-rtmp.json".path}" \
      "${profileDir}/obs-multi-rtmp.json"
  '';

  xdg.configFile."obs-studio/plugin_config/obs-websocket/config.json" = {
    source =
      config.lib.file.mkOutOfStoreSymlink
        osConfig.sops.templates."obs-websocket-config.json".path;
    force = true;
  };
}
