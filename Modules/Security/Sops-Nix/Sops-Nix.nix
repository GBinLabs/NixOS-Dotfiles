{
  config,
  pkgs,
  ...
}:
{
  sops = {
    defaultSopsFile = ../../../Secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = "/persist/home/bin/.config/sops/age/keys.txt";
    };

    secrets = {
      usuario-bin = {
        neededForUsers = true;
      };

      "obs-websocket-password" = {
        owner = "bin";
        mode = "0400";
      };
      "twitch" = {
        owner = "bin";
        mode = "0400";
      };
      "twitch-alert-url" = {
        owner = "bin";
        mode = "0400";
      };
      "starvios" = {
        owner = "bin";
        mode = "0400";
      };
      "starvios-alert-url" = {
        owner = "bin";
        mode = "0400";
      };
      "starvios-chat-url" = {
        owner = "bin";
        mode = "0400";
      };
    };

    templates."obs-websocket-config.json" = {
      owner = "bin";
      mode = "0600";

      content = ''
        {
          "alerts_enabled": false,
          "auth_required": true,
          "first_load": false,
          "server_enabled": true,
          "server_password": "${config.sops.placeholder."obs-websocket-password"}",
          "server_port": 4455
        }
      '';
    };
    templates."obs-twitch-service.json" = {
      owner = "bin";
      mode = "0600";

      content = builtins.toJSON {
        type = "rtmp_common";

        settings = {
          service = "Twitch";
          protocol = "RTMPS";
          server = "rtmps://sae10.contribute.live-video.net:443/app/";
          bwtest = false;

          key = config.sops.placeholder.twitch;
        };
      };
    };
    templates."obs-multi-rtmp.json" = {
      owner = "bin";
      mode = "0600";
      content =
        builtins.replaceStrings [ "__STARVIOS_STREAM_KEY__" ] [ config.sops.placeholder.starvios ]
          (builtins.readFile ../../Capture/OBS/Netbook/Profiles/obs-multi-rtmp.json);
    };

    templates."obs-linux-gaming.json" = {
      owner = "bin";
      mode = "0400";
      content =
        builtins.replaceStrings
          [
            "__TWITCH_ALERT_URL__"
            "__STARVIOS_ALERT_URL__"
            "__STARVIOS_CHAT_URL__"
          ]
          [
            config.sops.placeholder."twitch-alert-url"
            config.sops.placeholder."starvios-alert-url"
            config.sops.placeholder."starvios-chat-url"
          ]
          (
            builtins.readFile (
              if config.Capture.obs.host == "Netbook" then
                ../../Capture/OBS/Netbook/Scenes/Linux-Gaming.json
              else
                ../../Capture/OBS/PC/Scenes/Linux-Gaming.json
            )
          );
    };
  };
  environment.systemPackages = with pkgs; [
    age
    sops
  ];
}
