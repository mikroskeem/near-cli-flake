{ stdenv
, lib
, fetchFromGitHub
, mkYarnPackage
, nodePackages
, pkg-config
, python39Packages
, xcbuild
, libusb
, udev
, AppKit
, CoreFoundation
, IOKit
}:

mkYarnPackage rec {
  pname = "near-cli";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "near";
    repo = "near-cli";
    rev = "v${version}";
    sha256 = "sha256-ektEEmODHXerHFRRERYqoyt2TUMw8vA3ybQmpO/mbfo=";
  };

  nativeBuildInputs = [
    python39Packages.python
    nodePackages.node-gyp
    pkg-config
  ] ++ lib.optionals stdenv.isDarwin [
    xcbuild
  ];

  extraBuildInputs = [
    libusb
  ] ++ lib.optionals stdenv.isLinux [
    udev
  ] ++ lib.optionals stdenv.isDarwin [
    AppKit
    CoreFoundation
    IOKit
  ];

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
