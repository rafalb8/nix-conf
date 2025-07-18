{ lib
, stdenv
, writeText
, fetchFromGitHub
, python313Packages
, lzip
, util-linux
}:
let
  pythonPackages = python313Packages;

  pname = "waydroid_script";
  version = "2025.07.13";
  src = fetchFromGitHub {
    owner = "casualsnek";
    repo = "waydroid_script";
    rev = "3e344b360f64f4a417c4f5e9a3b1aae3da9fdfb9";
    sha256 = "sha256-l4L11Ilz3Y2lmKceg0+ZROPADgqhOwxzR/8V+ffyTjY=";
  };

  meta = with lib; {
    description = "Python Script to add libraries to waydroid";
    homepage = "https://github.com/casualsnek/waydroid_script";
    license = licenses.gpl3;
    platforms = platforms.linux;
    mainProgram = "waydroid-script";
  };

  resetprop = stdenv.mkDerivation {
    pname = "resetprop";
    inherit version src;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share
      cp -r bin/* $out/share/
    '';
  };

  setup = writeText "setup.py" ''
    from setuptools import setup

    with open('requirements.txt') as f:
      install_requires = f.read().splitlines()

    setup(
        name='${pname}',
        version='${version}',
        packages=["main", "stuff", "tools"],
        install_requires = install_requires,
        package_dir = {
            'main': '.',
        },
        entry_points = {
            'console_scripts': ['waydroid-script=main.main:main'],
        }
    )
  '';
in
pythonPackages.buildPythonPackage {
  inherit pname version src meta;
  pyproject = true;
  build-system = [ pythonPackages.setuptools ];
  doCheck = false;

  propagatedBuildInputs = with pythonPackages; [
    inquirerpy
    requests
    tqdm

    lzip
    util-linux
  ];

  postPatch = ''
    ln -s ${setup} setup.py
    substituteInPlace stuff/general.py \
        --replace-fail "os.path.dirname(__file__), \"..\", \"bin\"," "\"${resetprop}/share\","
  '';
}
