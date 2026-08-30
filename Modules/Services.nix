{
  config,
  pkgs,
  ...
}: {
  services = {
    fwupd.enable = true;
    power-profiles-daemon.enable = true;
    scx = {
      enable = true;
      package = pkgs.scx.rustscheds;
      scheduler = "scx_bpfland";
      extraArgs = [
        "-m"
        "all"
      ];
    };

    gnome-vram-booster = {
      enable = true;
      boostRatio = 0.90;
    };
    
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    ratbagd = {
      enable = true;
      package = pkgs.libratbag;
    };
  };
}
