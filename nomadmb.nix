{ lib, python3Packages, fetchFromGitHub, python312 }:

let
  python312Packages = python312.pkgs;
in
python312Packages.buildPythonApplication rec {
  pname = "nomadmb";
  version = "0.1.0";

  src = ./.;

  propagatedBuildInputs = with python312Packages; [
    rns
    lxmf
    msgpack
  ];

  format = "other";

  installPhase = ''
    mkdir -p $out/bin
    cp messageboard.py $out/bin/nomadmb
    chmod +x $out/bin/nomadmb
    sed -i '1s;^;#!/usr/bin/env python3\n;' $out/bin/nomadmb
  '';

  meta = with lib; {
    description = "NomadNet Message Board";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
