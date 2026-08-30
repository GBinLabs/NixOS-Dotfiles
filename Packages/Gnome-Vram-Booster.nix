{
  lib,
  rustPlatform,
  glib,
  src,
}: let
  cargoManifest = builtins.fromTOML (builtins.readFile "${src}/daemon/Cargo.toml");
  extensionUuid = "vram-booster@local";
in
  rustPlatform.buildRustPackage {
    pname = "gnome-vram-booster";
    version = cargoManifest.package.version;

    inherit src;

    cargoRoot = "daemon";
    buildAndTestSubdir = "daemon";
    cargoLock.lockFile = "${src}/daemon/Cargo.lock";

    nativeBuildInputs = [glib];

    postInstall = ''
      extensionDirectory="$out/share/gnome-shell/extensions/${extensionUuid}"

      mkdir -p "$extensionDirectory"
      cp -r --no-preserve=mode "${src}/extension/." "$extensionDirectory/"
      glib-compile-schemas --strict "$extensionDirectory/schemas"

      install -Dm644 \
        "${src}/packaging/usr/share/dbus-1/system.d/org.gnome.VramBooster.conf" \
        "$out/share/dbus-1/system.d/org.gnome.VramBooster.conf"
    '';

    passthru = {
      inherit extensionUuid;
    };

    meta = {
      description = "Dynamic VRAM prioritization for foreground GNOME applications";
      homepage = "https://github.com/sachesi/gnome-vram-booster";
      license = lib.licenses.gpl3Plus;
      mainProgram = "gnome-vram-booster";
      platforms = lib.platforms.linux;
    };
  }
