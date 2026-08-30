{
  config,
  pkgs,
  ...
}: {
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
  };

  environment.systemPackages = with pkgs; [
    age
    sops
  ];
}
