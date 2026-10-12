# majutsu.nix
{ pkgs, epkgs }:

epkgs.trivialBuild {
  pname = "majutsu";
  version = "main";
  src = pkgs.fetchFromGitHub {
    owner = "0WD0";
    repo = "majutsu";
    rev = "main";
    hash = "sha256-GVd8u2u9kHf21zia3szuM4iTaPVUwPMfBzpObmW0Lwk=";
  };
  packageRequires = with epkgs; [ magit magit-section transient compat dash s f ];

  # Skip byte-compilation to bypass the Emacs 30/Magit bug
  buildPhase = ":";
  installPhase = ''
    mkdir -p $out/share/emacs/site-lisp
    cp -r *.el $out/share/emacs/site-lisp/
  '';
}
