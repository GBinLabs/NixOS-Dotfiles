"""Aplicar en Mutter la disposición declarada para los dos monitores del PC."""


def find_monitor(monitors, connectors, product):
    matches = [m for m in monitors if m[0][0] in connectors]
    if len(matches) == 1:
        return matches[0]
    matches = [m for m in monitors if product in m[0][2]]
    return matches[0] if len(matches) == 1 else None


def select_mode(monitor, target_hz):
    modes = [m for m in monitor[1] if list(m[1:3]) == [1920, 1080]]
    modes = [m for m in modes if 1.0 in m[5] and not m[6].get("is-interlaced", False)]
    if not modes:
        raise ValueError(f"{monitor[0][0]} no anuncia un modo 1920x1080 con escala 1")
    return min(modes, key=lambda m: abs(float(m[3]) - target_hz))


def build_layout(monitors):
    main = find_monitor(monitors, {"DP-3"}, "LG ULTRAGEAR")
    left = find_monitor(monitors, {"HDMI-1", "HDMI-A-1"}, "S22F350")
    if main is None:
        return None
    selected = [main] + ([left] if left is not None else [])
    if len(selected) != len(monitors):
        # No desactivar pantallas nuevas que no formen parte de esta disposición.
        return None
    main_mode = select_mode(main, 180.0)
    main_x = 1920 if left is not None else 0
    layout = [(main_x, 0, 1.0, 0, True, [(str(main[0][0]), str(main_mode[0]), {})])]
    if left is not None:
        left_mode = select_mode(left, 75.0)
        layout.insert(0, (0, 0, 1.0, 0, False, [(str(left[0][0]), str(left_mode[0]), {})]))
    return layout


def layout_matches(monitors, current, desired):
    current_positions = sorted(
        (int(x), int(y), float(scale), int(transform), bool(primary), tuple(str(s[0]) for s in specs))
        for x, y, scale, transform, primary, specs, _ in current
    )
    desired_positions = sorted(
        (x, y, scale, transform, primary, tuple(s[0] for s in specs))
        for x, y, scale, transform, primary, specs in desired
    )
    active_modes = {
        str(monitor[0][0]): str(mode[0])
        for monitor in monitors
        for mode in monitor[1]
        if mode[6].get("is-current", False)
    }
    return current_positions == desired_positions and all(
        active_modes.get(connector) == mode_id
        for *_, specs in desired
        for connector, mode_id, _ in specs
    )


def main():
    import dbus

    proxy = dbus.SessionBus().get_object("org.gnome.Mutter.DisplayConfig", "/org/gnome/Mutter/DisplayConfig")
    display = dbus.Interface(proxy, "org.gnome.Mutter.DisplayConfig")
    serial, monitors, current, properties = display.GetCurrentState()
    desired = build_layout(monitors)
    if desired is None:
        print("Disposición no reconocida: se conserva la elegida por GNOME.")
        return
    if layout_matches(monitors, current, desired):
        print("La disposición de pantallas ya es correcta.")
        return
    options = dbus.Dictionary({}, signature="sv")
    if properties.get("supports-changing-layout-mode", False):
        options["layout-mode"] = properties["layout-mode"]
    display.ApplyMonitorsConfig(
        serial,
        dbus.UInt32(1),  # Sesión actual, sin diálogo; se reaplica en cada inicio.
        dbus.Array(desired, signature="(iiduba(ssa{sv}))"),
        options,
    )
    print("Pantalla principal LG; Samsung a la izquierda cuando está conectado.")


if __name__ == "__main__":
    main()
