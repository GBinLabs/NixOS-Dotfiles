{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  vramBooster = osConfig.services.gnome-vram-booster;
in {
  xdg.userDirs = {
    enable = true;
    setSessionVariables = false;
    createDirectories = true;

    documents = "${config.home.homeDirectory}/Documentos";
    download = "${config.home.homeDirectory}/Descargas";
    music = "${config.home.homeDirectory}/Musica";
    pictures = "${config.home.homeDirectory}/Imagenes";
    videos = "${config.home.homeDirectory}/Videos";
    projects = "${config.home.homeDirectory}/Proyectos";
    publicShare = "${config.home.homeDirectory}/Publico";
    templates = "${config.home.homeDirectory}/Plantillas";
  };

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Ptyxis.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "MoreWaita";
      cursor-theme = "Bibata-Modern-Ice";
      cursor-size = 20;

      font-name = "Inter 11";
      document-font-name = "Inter 11";
      monospace-font-name = "JetBrains Mono 10";

      font-antialiasing = "rgba";
      font-hinting = "slight";

      enable-animations = false;
      gtk-enable-primary-paste = false;
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "adw-gtk3-dark";
    };

    "org/gnome/settings-daemon/plugins/housekeeping" = {
      donation-reminder-enabled = false;
    };

    "org/gnome/shell/extensions/just-perfection" = {
      animation = 3;
      dash-icon-size = 48;
      panel-size = 32;
      workspace-switcher-should-show = false;
      startup-status = 0;
      support-notifier-showed-version = 36;
      support-notifier-type = 0;
    };

    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "latam"
        ])
      ];
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      edge-tiling = true;
      experimental-features = [
        "autoclose-xwayland"
      ];
    };

    "org/gnome/gnome-screenshot" = {
      # Corregido: Imagenes sin tilde para coincidir con xdg.userDirs
      auto-save-directory = "file://${config.home.homeDirectory}/Imagenes/Capturas de pantalla";
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 1;
      button-layout = "appmenu:minimize,maximize,close";
      titlebar-font = "Inter Bold 11";
      focus-mode = "click";
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = 0.0;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
      tap-to-click = true;
      click-method = "areas";
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      remember-recent-files = false;
      remove-old-trash-files = true;
      old-files-age = 1;
      remove-old-temp-files = true;
      report-technical-problems = false;
    };

    "org/gnome/desktop/screensaver" = {
      lock-enabled = true;
      idle-activation-enabled = true;
      lock-delay = lib.hm.gvariant.mkUint32 0;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "nothing";
      sleep-inactive-ac-timeout = 0;
      sleep-inactive-battery-timeout = 0;
      power-button-action = "nothing";
      ambient-enabled = false;
    };

    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 600;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      search-filter-time-type = "last_modified";
      show-hidden-files = false;
      default-sort-order = "name";
      default-sort-in-reverse-order = false;
    };

    "org/gnome/nautilus/list-view" = {
      use-tree-view = false;
      default-zoom-level = "small";
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [
        "Utilidades"
        "LibreOffice"
      ];
    };

    "org/gnome/desktop/app-folders/folders/Utilidades" = {
      name = "Utilidades";
      translate = true;
      apps = [
        "org.gnome.baobab.desktop"
        "btop.desktop"
        "org.gnome.Settings.desktop"
        "org.gnome.DiskUtility.desktop"
        "org.gnome.TextEditor.desktop"
        "org.gnome.Extensions.desktop"
        "org.gnome.eog.desktop"
        "org.gnome.FileRoller.desktop"
        "org.freedesktop.Piper.desktop"
        "org.gnome.Papers.desktop"
      ];
    };

    "org/gnome/desktop/app-folders/folders/LibreOffice" = {
      name = "LibreOffice";
      translate = true;
      apps = [
        "startcenter.desktop"
        "base.desktop"
        "calc.desktop"
        "draw.desktop"
        "impress.desktop"
        "math.desktop"
        "writer.desktop"
      ];
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file://${config.home.homeDirectory}/Imagenes/Wallpapers/Hogwarts.png";
      picture-uri-dark = "file://${config.home.homeDirectory}/Imagenes/Wallpapers/Hogwarts.png";
      picture-options = "zoom";
    };
  };

  programs.gnome-shell = {
    enable = true;
    extensions =
      [
        {package = pkgs.gnomeExtensions.user-themes;}
        {package = pkgs.gnomeExtensions.appindicator;}
        {package = pkgs.gnomeExtensions.just-perfection;}
      ]
      ++ lib.optionals vramBooster.enable [
        {package = vramBooster.package;}
      ];
  };

  home.packages = with pkgs; [
    # Temas e iconos
    adw-gtk3
    morewaita-icon-theme
    bibata-cursors
    # Fuentes
    inter
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    liberation_ttf
    nerd-fonts.jetbrains-mono
    times-newer-roman
    xits-math
  ];

  home.language = {
    base = "es_AR.UTF-8";
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = ["Inter"];
      serif = ["Liberation Serif"];
      monospace = ["JetBrains Mono"];
      emoji = ["Noto Color Emoji"];
    };
    antialiasing = true;
    hinting = "slight"; # ← String directo, no attrset
    subpixelRendering = "rgb";
  };

  home.file."Imagenes/Wallpapers/NixOS.png".source = ./Wallpapers/NixOS.png;
  home.file."Imagenes/Wallpapers/Hogwarts.png".source = ./Wallpapers/Hogwarts.png;
}
