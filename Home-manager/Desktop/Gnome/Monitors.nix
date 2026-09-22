{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  monitorPython = pkgs.python3.withPackages (ps: [ ps.dbus-python ]);
in
{
  config = lib.mkIf osConfig.Boot-PC.enable {
    # Mutter consulta los monitores reales; no se fijan números de serie
    # ni modos inventados en un monitors.xml estático.
    systemd.user.services.gnome-monitor-layout = {
      Unit = {
        Description = "Pantalla principal LG y Samsung a la izquierda";
        After = [ "graphical-session.target" ];
        PartOf = [ "gnome-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${monitorPython}/bin/python3 ${./monitor-layout.py}";
      };
      Install.WantedBy = [ "gnome-session.target" ];
    };
  };
}
