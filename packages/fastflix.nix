{ python3Packages
, fetchFromGitHub
, fetchPypi
, makeDesktopItem
}:
let
  # Missing
  reusables = python3Packages.buildPythonPackage rec {
    pname = "reusables";
    version = "0.9.6";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-2A5ULQgP7HQUeIUUmMx+X3xiTU7hTXOo/UxIwsbCE1U=";
    };
    propagatedBuildInputs = with python3Packages; [ pytest-runner ];
    doCheck = false;
  };

  iso639-lang = python3Packages.buildPythonPackage rec {
    pname = "iso639-lang";
    version = "0.0.9";
    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-teH7pM6sevpoSfPx9zUDUbFCCFJnQ5HOGMIIskJ/BMM=";
    };

    # Run once, to generate mappings
    postInstall = ''
      pushd $out/lib/python3.11/site-packages/
      python3 -c 'import iso639;'
      popd
    '';

    propagatedBuildInputs = with python3Packages; [ setuptools ];
    doCheck = false;
  };

  # Version mismatch
  chardet = python3Packages.chardet.overrideAttrs (final: prev: {
    version = "5.1.0";
    src = fetchPypi {
      inherit (final) version;
      pname = "chardet";
      hash = "sha256-DWJxK5VrwVT4X7CiZuKjxZE8KWfgA0hwGzJBHW3vMeU=";
    };
  });

  mistune = python3Packages.mistune.overrideAttrs (final: prev: {
    version = "2.0.5";
    src = fetchFromGitHub {
      owner = "lepture";
      repo = "mistune";
      rev = "refs/tags/v${final.version}";
      sha256 = "sha256-fMZlqbqfUcnzt+WB0qBkKXzOAlpS6KKgdyg3ZfjIqKY=";
    };
  });

  pathvalidate = python3Packages.pathvalidate.overrideAttrs (final: prev: {
    version = "2.5.2";
    src = fetchPypi {
      inherit (final) version;
      pname = "pathvalidate";
      hash = "sha256-X/V9D6vl7Lek8eSVe/61rYq1q0wPpx95xrvCS9m30U0=";
    };
  });

  python-box = python3Packages.python-box.overrideAttrs (final: prev: {
    version = "6.1.0";
    src = fetchFromGitHub {
      owner = "cdgriffith";
      repo = "Box";
      rev = "refs/tags/${final.version}";
      sha256 = "sha256-42VDZ4aASFFWhRY3ApBQ4dq76eD1flZtxUM9hpA9iiI=";
    };
  });
in
python3Packages.buildPythonPackage rec {
  pname = "fastflix";
  version = "5.8.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "cdgriffith";
    repo = "FastFlix";
    rev = version;
    sha256 = "sha256-M8vjim5ZX1jTRAi69E2tZE/5BMTxfGztwH2CCYv3TUs=";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools
    setuptools-scm
    appdirs
    colorama
    coloredlogs
    psutil
    pydantic
    pyside6
    requests

    ruamel-yaml
  ] ++ [
    # Missing
    reusables
    iso639-lang
    # Version mismatch
    chardet
    mistune
    pathvalidate
    python-box
  ];

  doCheck = false;

  desktopItem = makeDesktopItem {
    name = "FastFlix";
    exec = pname;
    desktopName = "FastFlix";
    categories = [ "AudioVideo" "Video" "TV" ];
  };

  postInstall = ''
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/*.desktop $out/share/applications
  '';
}
