{
  config,
  lib,
  ...
}: {
  options = {
    Red-PC.enable = lib.mkEnableOption "Red para PC";
    Red-Netbook.enable = lib.mkEnableOption "Red para Netbook";
  };

  config = lib.mkMerge [
    (lib.mkIf config.Red-PC.enable {
      networking.hostName = "Bin-PC";
    })

    (lib.mkIf config.Red-Netbook.enable {
      networking.hostName = "Bin-Netbook";
    })
  ];
}
