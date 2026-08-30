{lib, ...}: {
  programs.mangohud = {
    enable = true;
    enableSessionWide = false;
  };

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
    frame_timing

    legacy_layout=false
    horizontal
    horizontal_stretch=0
    round_corners=10
    background_alpha=0.7
    position=top-left
    font_size=18

    hud_no_margin

    text_outline
    text_outline_color=000000
    text_outline_thickness=1

    gpu_text=RX 5500 XT 4GB
    gpu_color=2e9762
    gpu_load_value=60,90
    gpu_load_color=92e79a,ffaa7f,cc0000

    cpu_text=Ryzen 5 3600
    cpu_color=2e97cb
    cpu_load_value=60,90
    cpu_load_color=92e79a,ffaa7f,cc0000

    background_color=000000
    text_color=ffffff
    vram_color=ad64c1
    ram_color=c26693
    frametime_color=00ff00
    wine_color=eb5b5b
    engine_color=eb5b5b
    media_player_color=ffffff
    network_color=e07b85
    battery_color=92e79a
    horizontal_separator_color=ffffff

    fps_value=30,60
    fps_color=cc0000,ffaa7f,92e79a
    fps_limit_method=late
    fps_limit=180

    vsync=1
    gl_vsync=0

    toggle_hud=Shift_R+F12
  '';
}
