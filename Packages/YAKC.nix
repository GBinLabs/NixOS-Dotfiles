{
  lib,
  rustPlatform,
  cargo-tauri,
  pkg-config,
  wrapGAppsHook4,
  gtk3,
  webkitgtk_4_1,
  libsoup_3,
  glib-networking,
  libayatana-appindicator,
  libxkbcommon,
  libx11,
  openssl,
  alsa-lib,
  systemd,
  speechd,
  src,
}:

rustPlatform.buildRustPackage {
  pname = "yakc";
  version = "2.8.1";

  inherit src;

  cargoRoot = "src-tauri";
  buildAndTestSubdir = "src-tauri";

  cargoLock.lockFile = "${src}/src-tauri/Cargo.lock";

  nativeBuildInputs = [
    cargo-tauri.hook
    pkg-config
    wrapGAppsHook4
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    gtk3
    webkitgtk_4_1
    libsoup_3
    glib-networking
    libayatana-appindicator
    libxkbcommon
    libx11
    openssl
    alsa-lib
    systemd
    speechd
  ];

  patches = [
    ./YAKC-Mouse-Buttons.patch
  ];

  # Permitir la carga dinámica de Ayatana AppIndicator.
  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libayatana-appindicator
        ]
      }"
    )
  '';

  meta = {
    description = "Keyboard, mouse and gamepad visualizer for OBS";
    homepage = "https://github.com/iammodev/YAKC";
    license = lib.licenses.mit;
    mainProgram = "yakc";
    platforms = [ "x86_64-linux" ];
  };
}
