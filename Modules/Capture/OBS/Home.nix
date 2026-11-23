{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  isNetbook = osConfig.Capture.obs.host == "Netbook";

  profileName = if isNetbook then "Twitch900p" else "Twitch-900p";
  profileFiles =
    if isNetbook then
      {
        ini = ./Netbook/Profiles/basic.ini;
        record = ./Netbook/Profiles/recordEncoder.json;
        stream = ./Netbook/Profiles/streamEncoder.json;
      }
    else
      {
        ini = ./PC/Profiles/Twitch-900p/basic.ini;
        record = ./PC/Profiles/Twitch-900p/recordEncoder.json;
        stream = ./PC/Profiles/Twitch-900p/streamEncoder.json;
      };

  obsDir = "${config.xdg.configHome}/obs-studio";
  profileDir = "${obsDir}/basic/profiles/${profileName}";
  scenesDir = "${obsDir}/basic/scenes";

  netbookGlobalIni = pkgs.writeText "obs-netbook-global.ini" ''
    [Basic]
    Profile=Twitch900p
    ProfileDir=Twitch900p
    SceneCollection=Linux-Gaming
    SceneCollectionFile=Linux-Gaming
  '';
in
{
  programs.obs-studio = {
    enable = true;
    plugins =
      with pkgs.obs-studio-plugins;
      if isNetbook then
        [
          obs-multi-rtmp
          obs-teleport
        ]
      else
        [
          obs-pipewire-audio-capture
          obs-vkcapture
          obs-multi-rtmp
          obs-teleport
        ];
  };

  home.activation.obsCaptureTemplates = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.coreutils}/bin/mkdir -p \
      "${config.home.homeDirectory}/Videos/YouTube" \
      "${profileDir}" \
      "${scenesDir}"

    run ${pkgs.coreutils}/bin/install -m 0644 \
      ${profileFiles.ini} "${profileDir}/basic.ini"

    run ${pkgs.coreutils}/bin/install -m 0644 \
      ${profileFiles.record} "${profileDir}/recordEncoder.json"

    run ${pkgs.coreutils}/bin/install -m 0644 \
      ${profileFiles.stream} "${profileDir}/streamEncoder.json"

    run ${pkgs.coreutils}/bin/install -m 0600 \
      "${osConfig.sops.templates."obs-linux-gaming.json".path}" \
      "${scenesDir}/Linux-Gaming.json"

    ${lib.optionalString isNetbook ''
      run ${pkgs.coreutils}/bin/install -m 0644 \
        ${netbookGlobalIni} "${obsDir}/global.ini"

      run ${pkgs.coreutils}/bin/install -m 0600 \
        "${osConfig.sops.templates."obs-multi-rtmp.json".path}" \
        "${profileDir}/obs-multi-rtmp.json"
    ''}
  '';

  home.activation.obsTwitchService = lib.hm.dag.entryAfter [ "obsCaptureTemplates" ] ''
    if [ -z "''${DRY_RUN:-}" ]; then
      destination="${profileDir}/service.json"
      source="${osConfig.sops.templates."obs-twitch-service.json".path}"

      test -r "$source" || {
        echo "OBS: no se encuentra la plantilla SOPS de Twitch" >&2
        exit 1
      }

      tmp="$(${pkgs.coreutils}/bin/mktemp "$destination.XXXXXX")"
      ${pkgs.coreutils}/bin/install -m 0600 "$source" "$tmp"
      ${pkgs.coreutils}/bin/mv -f "$tmp" "$destination"
    fi
  '';

  home.activation.obsTeleportSender = lib.mkIf (!isNetbook) (
    lib.hm.dag.entryAfter [ "obsCaptureTemplates" ] ''
      run ${pkgs.coreutils}/bin/install \
        -D -m 0644 \
        ${./PC/Teleport/obs-teleport.json} \
        "${obsDir}/plugin_config/obs-teleport/obs-teleport.json"
    ''
  );

  xdg.configFile = lib.optionalAttrs (!isNetbook) {
    "obs-studio/plugin_config/obs-websocket/config.json" = {
      source =
        config.lib.file.mkOutOfStoreSymlink
          osConfig.sops.templates."obs-websocket-config.json".path;
      force = true;
    };
  };
}
