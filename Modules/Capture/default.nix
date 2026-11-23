{ config, lib, ... }:
{
  imports = [
    ./OBS.nix
    ./PushToTalk.nix
    ./YAKC.nix
  ];

  options.Capture.enable = lib.mkEnableOption "Grabación y producción audiovisual";

  config = {
    Capture.obs.enable = lib.mkDefault config.Capture.enable;

    Capture.yakc.enable = lib.mkDefault config.Capture.enable;
  };
}
