{ pkgs, ... }: {
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
    ratbagd = {
      enable = true;
      package = pkgs.libratbag;
    };
    gnome-vram-booster = {
      enable = true;
      boostRatio = 0.90;
    };
  };
}
