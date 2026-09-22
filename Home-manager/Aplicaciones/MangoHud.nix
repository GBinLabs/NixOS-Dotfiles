{ lib, pkgs, ... }: {
  programs.mangohud = {
    enable = true;
    enableSessionWide = false;

    # Aplica el orden al ejecutar mangohud; LSFG conserva su carga implícita.
    package = pkgs.symlinkJoin {
      name = "mangohud-${pkgs.mangohud.version}";
      paths = [ pkgs.mangohud ];
      nativeBuildInputs = [
        pkgs.makeWrapper
        pkgs.jq
      ];

      postBuild = ''
        # Lee las capas instaladas, incluidas las de 32 y 64 bits.
        mangoHudLayers="$(jq -r -s 'map(.layer.name) | unique | join(":")' \
          ${pkgs.mangohud}/share/vulkan/implicit_layer.d/MangoHud*.json)"

        wrapProgram "$out/bin/mangohud" \
          --suffix VK_INSTANCE_LAYERS : "$mangoHudLayers"
      '';

      meta = pkgs.mangohud.meta // {
        outputsToInstall = [ "out" ];
      };
    };
  };

  home.activation.mangoHudSysInfo = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/mangohud"
    printf "NixOS %s · Kernel %s" \
      "$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')" \
      "$(uname -r)" \
      > "$HOME/.config/mangohud/sysinfo"
  '';

  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    cpu_stats
    cpu_temp
    gpu_stats
    gpu_temp
    vram
    ram
    fps
    fps_metrics=avg,0.01,0.001
    display_server
    gamemode
    exec=cat /home/bin/.config/mangohud/sysinfo
    frame_timing

    # Azul editorial: tinta, acero y blanco frío.
    legacy_layout=false
    horizontal
    horizontal_stretch=0
    round_corners=6
    background_alpha=0.88
    position=top-left
    font_size=18

    hud_no_margin

    text_outline
    text_outline_color=030C14
    text_outline_thickness=1

    gpu_text=RX 5500XT 4GB
    gpu_color=78B4E3
    gpu_load_change
    gpu_load_value=60,90
    gpu_load_color=A6C6E3,82B3DB,6CAADB

    cpu_text=Ryzen 5 3600
    cpu_color=A4C8E8
    cpu_load_change
    cpu_load_value=60,90
    cpu_load_color=A6C6E3,82B3DB,6CAADB

    background_color=081B2C
    text_color=E7EFF7
    vram_color=91ADD1
    ram_color=B5CEE5
    frametime_color=7FBFE9
    wine_color=94B9DC
    engine_color=94B9DC
    media_player_color=E7EFF7
    network_color=7DAFCF
    battery_color=B0CEE5
    horizontal_separator_color=3B5973

    # Coral y ámbar para FPS bajos; azul para el tramo superior.
    fps_color_change
    fps_value=30,60
    fps_color=D997A1,E0C08D,A8CCE8
    fps_limit_method=late
    fps_limit=0

    # Respetar el modo de presentación de la aplicación o de LSFG.
    # En MangoHud, vsync=1 significa «desactivado», no «activado».

    toggle_hud=Shift_R+F12
  '';
}
