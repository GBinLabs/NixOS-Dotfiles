{
  config,
  lib,
  pkgs,
  ...
}:
{
  # GNOME y Mesa proceden del mismo nixpkgs fijado por la flake.
  hardware.graphics = {
    enable = true;
    enable32Bit = lib.mkDefault config.Steam.enable;
    extraPackages = lib.optionals config.Boot-Netbook.enable [
      pkgs.intel-media-driver
    ];
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = [
    pkgs.libva-utils
    pkgs.vulkan-tools
  ];
}
