{ stdenv, lib, mkYarnPackage, fetchFromGitHub, python39Packages, nodePackages, pkg-config, xcbuild, libusb, udev, AppKit, CoreFoundation, IOKit }:

mkYarnPackage rec {
  pname = "near-cli";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "near";
    repo = "near-cli";
    rev = "v${version}";
    sha256 = "sha256-GMgUD2QtMR3W0H2qERg7jvnAot74xmcGQt5WnFURkUM=";
  };

  nativeBuildInputs = [
    python39Packages.python
    nodePackages.node-gyp
    pkg-config
  ] ++ lib.optionals stdenv.isDarwin [
    xcbuild
  ];

  buildInputs = [
    libusb
  ] ++ lib.optionals stdenv.isLinux [
    udev
  ] ++ lib.optionals stdenv.isDarwin [
    AppKit
    CoreFoundation
    IOKit
  ];

  frameworkFlags = lib.optionalString stdenv.isDarwin (toString [
    "-F${AppKit}/Library/Frameworks"
    "-F${CoreFoundation}/Library/Frameworks"
    "-F${IOKit}/Library/Frameworks"
  ]);

  NIX_CFLAGS_COMPILE = frameworkFlags;
  NIX_LDFLAGS = frameworkFlags;
  dontStrip = true; # takes way too much time

  buildPhase = ''
    runHook preBuild

    pushd node_modules/usb
    node-gyp rebuild
    rm -rf build/Release/obj.target/
    popd

    pushd node_modules/node-hid
    node-gyp rebuild
    rm -rf build/Release/obj.target/
    popd

    runHook postBuild
  '';
}
