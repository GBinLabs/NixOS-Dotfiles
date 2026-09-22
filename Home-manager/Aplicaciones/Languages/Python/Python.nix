{ pkgs, ... }: {
  home = {
    packages = [
      (pkgs.python3.withPackages (
        python-pkgs: with python-pkgs; [
          matplotlib
        ]
      ))
    ];
  };
}
