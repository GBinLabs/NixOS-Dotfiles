_: {
  services = {
    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;

      lowLatency = {
        enable = true;
        quantum = 128;
        rate = 48000;
      };
    };
  };

  environment.etc."wireplumber/wireplumber.conf.d/51-microphone-volume.conf".text = ''
    wireplumber.settings = {
      device.routes.default-source-volume = 0.027
    }
  '';

  security.rtkit.enable = true;
}
