{pkgs, ...}: {
  home = {
    packages = [
      (pkgs.python314.withPackages (
        python-pkgs:
          with python-pkgs; [
            matplotlib
          ]
      ))
    ];
  };
}
