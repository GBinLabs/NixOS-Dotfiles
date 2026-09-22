{ config, ... }: {
  imports = [
    ../../Modules/default.nix
    ./disko.nix
  ];

  hardware.facter.reportPath = ./facter.json;
  Boot-PC.enable = true;
  Steam.enable = true;
  LSFG.enable = true;
  Reset.enable = true;
  Red-PC.enable = true;
  Persistencia = {
    enable = true;
    extraUserDirectories = [
      ".local/share/Steam"
      ".local/share/FreesmLauncher"
      ".local/share/Hytale"
    ];
  };

  users = {
    mutableUsers = false;
    users.bin = {
      isNormalUser = true;
      description = "Bin";
      extraGroups = [
        "networkmanager"
        "wheel"
        "audio"
        "video"
        "render"
        "gamemode"
        "input"
      ];
      hashedPasswordFile = config.sops.secrets.usuario-bin.path;
    };
  };

  system.stateVersion = "24.11";
}
