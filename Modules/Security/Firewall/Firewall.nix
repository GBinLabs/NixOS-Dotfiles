{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [];
    allowedUDPPorts = [];
    allowedTCPPortRanges = [];
    allowedUDPPortRanges = [];

    trustedInterfaces = ["lo"];

    rejectPackets = false;
    allowPing = false;

    logRefusedConnections = true;
    logRefusedPackets = false;
    logRefusedUnicastsOnly = false;
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;

    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;

    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;

    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.conf.all.log_martians" = 1;

    # Protección adicional ICMP rate limit
    "net.ipv4.icmp_ratelimit" = 100;
    "net.ipv4.icmp_ratemask" = 88;

    # TCP timestamp para mejor tracking
    "net.ipv4.tcp_timestamps" = 1;
  };
}
