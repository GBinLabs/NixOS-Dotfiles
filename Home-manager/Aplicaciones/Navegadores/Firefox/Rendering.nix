_: {
  # Preferencias nativas, compartidas por la configuración privada y pública.
  # No fuerzan un backend bloqueado por Firefox ni deshabilitan su sandbox.
  programs.firefox.profiles.default.settings = {
    "general.smoothScroll" = true;
    "layout.frame_rate" = -1; # Detectar la cadencia del monitor.
  };
}
