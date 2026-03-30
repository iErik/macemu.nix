{
  lib,
  stdenv,
  autoconf,
  automake,
  pkg-config,
  wrapGAppsHook3,
  gtk3,
  SDL2,
  libX11,
  libXext,
  libXxf86dga,
  libXxf86vm,
  ncurses,
  readline,
  gmp,
  mpfr,
  src,
}:

stdenv.mkDerivation {
  pname = "basilisk2";
  version = "unstable-2026-03-26";

  inherit src;

  sourceRoot = "source/BasiliskII/src/Unix";

  patches = [ ./patches/scsi-linux-nix.patch ];

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs =
    [
      gtk3
      SDL2
      libX11
      libXext
      libXxf86dga
      libXxf86vm
      ncurses
      readline
    ]
    ++ lib.optionals (with stdenv.hostPlatform; isAarch32 || isAarch64) [
      gmp
      mpfr
    ];

  postPatch = ''
    mkdir -p scsi_compat/scsi
    cp ${./files/scsi/sg.h} scsi_compat/scsi/sg.h
  '';

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="''${NIX_CFLAGS_COMPILE-} -isystem $(pwd)/scsi_compat"
    NO_CONFIGURE=1 ./autogen.sh
  '';

  postConfigure = ''
    if ! grep -q '^#define STDC_HEADERS' config.h; then
      echo '#define STDC_HEADERS 1' >> config.h
    fi
  '';

  configureFlags = [
    "--enable-sdl-video"
    "--enable-sdl-audio"
    "--with-esd=no"
  ] ++ lib.optionals (with stdenv.hostPlatform; isx86_32 || isx86_64) [ "--enable-jit-compiler" ];

  enableParallelBuilding = true;

  meta = {
    description = "68k Macintosh emulator (Basilisk II)";
    longDescription = ''
      Basilisk II runs 68k Mac OS software on Linux and other systems. You need a
      legal Mac ROM image and Mac OS install media; neither is included.
    '';
    homepage = "https://github.com/kanjitalk755/macemu";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "BasiliskII";
    platforms = lib.platforms.linux;
  };
}
