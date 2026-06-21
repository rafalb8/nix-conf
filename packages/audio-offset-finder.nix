{ lib
, python3
, fetchFromGitHub
, ffmpeg
, makeWrapper
}:

python3.pkgs.buildPythonApplication (final: {
  pname = "audio-offset-finder";
  version = "0.5.5";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "bbc";
    repo = "audio-offset-finder";
    rev = "v${final.version}";
    hash = "sha256-XIjRqm6EvQ9qp1xdMHk+6jtN5b8VwkcjoXDtXs7JvOY=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3.pkgs.pythonRelaxDepsHook
  ];

  # Relax the strict numpy < 2.0 restriction so it compiles with the newer NumPy in Nixpkgs
  pythonRelaxDeps = [
    "numpy"
  ];

  build-system = [
    python3.pkgs.setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    numpy
    scipy
    matplotlib
    librosa
  ];

  postInstall = ''
    wrapProgram $out/bin/audio-offset-finder \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';

  doCheck = false;

  meta = with lib; {
    description = "A simple tool and library for finding the offset of an audio file within another file";
    homepage = "https://github.com/bbc/audio-offset-finder";
    license = licenses.asl20;
    mainProgram = "audio-offset-finder";
    platforms = platforms.unix;
  };
})
