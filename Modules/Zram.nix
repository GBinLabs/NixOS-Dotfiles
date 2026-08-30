{lib, ...}: {
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 100;
    priority = 100;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 80;
    "vm.page-cluster" = 0;
    "vm.vfs_cache_pressure" = 50;
    "vm.compaction_proactiveness" = 0;
  };
}
