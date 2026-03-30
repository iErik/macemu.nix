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
  perl,
  file,
  src,
}:

stdenv.mkDerivation {
  pname = "sheepshaver";
  version = "unstable-2026-03-26";

  inherit src;

  sourceRoot = "source/SheepShaver/src/Unix";

  postUnpack = ''
    chmod -R u+w source
  '';

  postPatch = ''
    patchShebangs ../kpx_cpu
    scsi_cpp="../../../BasiliskII/src/Unix/Linux/scsi_linux.cpp"
    substituteInPlace "$scsi_cpp" \
      --replace-fail '#include <linux/../scsi/sg.h>	// workaround for broken RedHat 6.0 /usr/include/scsi' '#include <scsi/sg.h>'
    sed -i '/^#define DRIVER_SENSE 0x08$/d' "$scsi_cpp"
    mkdir -p scsi_compat/scsi
    cp ${./files/scsi/sg.h} scsi_compat/scsi/sg.h
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    perl
    file
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    SDL2
    libX11
    libXext
    libXxf86dga
    libXxf86vm
    ncurses
    readline
  ];

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="''${NIX_CFLAGS_COMPILE-} -isystem $(pwd)/scsi_compat"
    ( cd ../../.. && make -C SheepShaver links )
    NO_CONFIGURE=1 ./autogen.sh
    substituteInPlace configure --replace-fail '/usr/bin/file' '${file}/bin/file'
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
    "--with-mon=no"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "PowerPC Mac OS run-time environment (SheepShaver)";
    longDescription = ''
      SheepShaver runs classic PowerPC Mac OS (7.5.2 through 9.0.4) on Linux.
      You need a legal Power Macintosh ROM and Mac OS install media; neither is
      included. On non-PowerPC hosts the built-in CPU emulator is used.

      The optional cxmon in-emulator debugger is disabled (`--with-mon=no`) because
      the cxmon sources in macemu omit files that SheepShaver's build still expects.
    '';
    homepage = "https://github.com/kanjitalk755/macemu";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "SheepShaver";
    platforms = lib.platforms.linux;
  };
}
