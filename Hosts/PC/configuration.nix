{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../Modules/default.nix
    ./disko.nix
  ];

  hardware.facter.reportPath = ./facter.json;
  Boot-PC.enable = true;
  Steam.enable = true;
  Reset.enable = true;
  Red-PC.enable = true;
  Persistencia = {
    enable = true;
    extraSystemDirectories = [
    ];
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
      initialPassword = "1234";
    };
  };

  system.stateVersion = "24.11";
}
