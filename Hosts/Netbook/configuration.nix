{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../Modules/default.nix
    ./disko.nix
  ];

  hardware.facter.reportPath = ./facter.json;
  Boot-Netbook.enable = true;
  Persistencia.enable = true;
  Reset-Netbook.enable = true;
  Red-Netbook.enable = true;
  TPM.enable = true;

  users.mutableUsers = false;
  users.users.bin = {
    isNormalUser = true;
    description = "Bin";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
    ];
    hashedPasswordFile = config.sops.secrets.usuario-bin.path;
  };

  system.stateVersion = "24.11";
}
