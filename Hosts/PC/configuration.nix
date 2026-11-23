{ config, ... }: {
  imports = [
    ../../Modules/default.nix
    ./disko.nix
  ];

  hardware.facter = {
    reportPath = ./facter.json;

    detected = {
      graphics.enable = true;
      graphics.amd.enable = true;
      uefi.supported = true;
    };
  };
  Boot-PC.enable = true;
  Juegos.enable = true;
  Reset.enable = true;
  Red-PC.enable = true;
  Capture = {
    enable = true;
    pushToTalk = {
      enable = true;
      user = "bin";
      mouseDevice = "/dev/input/by-id/usb-Logitech_G203_LIGHTSYNC_Gaming_Mouse_205C37855631-event-mouse";
    };
  };
  Persistencia = {
    enable = true;
    extraUserDirectories = [
      ".local/share/Steam"
      ".local/share/FreesmLauncher"
      ".local/share/Hytale"
    ];
  };

  networking.firewall.interfaces."enp37s0".allowedTCPPorts = [ 9876 ];

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
