{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    TPM.enable = lib.mkEnableOption "Activar TPM 2.0";
  };

  config = lib.mkIf config.TPM.enable {
    environment.systemPackages = with pkgs; [
      tpm2-tools
      tpm2-tss
    ];

    services.udev.extraRules = ''
      KERNEL=="tpm[0-9]*", MODE="0660", GROUP="tss"
      KERNEL=="tpmrm[0-9]*", MODE="0660", GROUP="tss"
    '';

    users.groups.tss = {};
    systemd.services = {
      "systemd-tpm2-setup-early".enable = false;
      "systemd-tpm2-setup".enable = false;
    };
  };
}
