{pkgs, ...}: {
  home = {
    packages = [
      (pkgs.texliveSmall.withPackages (texlive:
        with texlive; [
          scheme-basic
          pgf
          standalone
          latexmk
        ]))
    ];
  };
}
