{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  versionCheckHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pandoc";
  version = "3.11";

  # Binario oficial: evita compilar Haskell en la Netbook.
  # `nix run .#update` actualiza juntos la versión y su hash con nix-update.
  src = fetchurl {
    url = "https://github.com/jgm/pandoc/releases/download/${finalAttrs.version}/pandoc-${finalAttrs.version}-linux-amd64.tar.gz";
    hash = "sha256-N+2zu89yL5IaAJlBv1h04uDAkmMibJtKLZgHiMsGKrY=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a bin share "$out/"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Universal markup converter";
    homepage = "https://pandoc.org";
    changelog = "https://github.com/jgm/pandoc/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    mainProgram = "pandoc";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
