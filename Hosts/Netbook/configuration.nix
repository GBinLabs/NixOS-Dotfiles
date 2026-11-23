{ config, pkgs, ... }: {
  imports = [
    ../../Modules/default.nix
    ./disko.nix
  ];

  hardware.facter.reportPath = ./facter.json;
  Boot-Netbook.enable = true;
  Persistencia = {
    enable = true;
    extraUserDirectories = [ ".local/share/lossless-scaling" ];
  };
  Reset-Netbook.enable = true;
  Red-Netbook.enable = true;
  TPM.enable = true;
  Capture.obs = {
    enable = true;
    host = "Netbook";
  };

  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  users.mutableUsers = false;
  users.users.bin = {
    isNormalUser = true;
    description = "Bin";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "render"
      "input"
    ];
    hashedPasswordFile = config.sops.secrets.usuario-bin.path;
  };

  system.stateVersion = "24.11";
}
