{ pkgs, ... }: {
  services = {
    fwupd.enable = true;
    power-profiles-daemon.enable = true;
    scx-loader = {
      enable = true;
      package = pkgs.scx.rustscheds;
      #schedsPackages = [pkgs.scx.bpfland];
      #config = {
      #  "-m"
      #  "all"
      #	};
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
