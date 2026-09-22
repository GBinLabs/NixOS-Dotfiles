{
  lib,
  stdenv,
  cmake,
  ninja,
  makeWrapper,
  vulkan-loader,
  src,
}:
let
  is32Bit = stdenv.hostPlatform.is32bit;
  librarySuffix = lib.optionalString is32Bit ".x86";
in
stdenv.mkDerivation {
  pname = "lsfg-vk";
  version = "unstable-${src.shortRev or "unknown"}";
  inherit src;

  strictDeps = true;
  nativeBuildInputs = [
    cmake
    ninja
  ]
  ++ lib.optional (!is32Bit) makeWrapper;

  # Upstream incluye las cabeceras y los shaders necesarios para esta compilación.
  # Usamos sus opciones de instalación, sin modificar su código fuente.
  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeBool "CMAKE_INTERPROCEDURAL_OPTIMIZATION" true)
    (lib.cmakeBool "CMAKE_DISABLE_FIND_PACKAGE_Git" true)
    (lib.cmakeBool "LSFGVK_BUILD_LAYER" true)
    (lib.cmakeBool "LSFGVK_BUILD_CLI" (!is32Bit))
    (lib.cmakeBool "LSFGVK_BUILD_UI" false)
    (lib.cmakeBool "LSFGVK_LAYER_MULTILIB_X86" is32Bit)
    (lib.cmakeBool "LSFGVK_MANAGED" true)
    (lib.cmakeFeature "LSFGVK_LAYER_LIBRARY_PATH" "${placeholder "out"}/lib/liblsfg-vk-layer${librarySuffix}.so")
  ];

  # La CLI carga libvulkan dinámicamente; los juegos ya tienen su cargador Vulkan.
  postFixup = lib.optionalString (!is32Bit) ''
    wrapProgram "$out/bin/lsfg-vk-cli" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ vulkan-loader ]}"
  '';

  meta = {
    description = "Lossless Scaling Frame Generation for Vulkan (requires Lossless Scaling)";
    homepage = "https://lsfg-vk.dev/";
    license = lib.licenses.cc-by-nc-nd-40;
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}
