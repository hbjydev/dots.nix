# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ../../../lib/nixosModules/grafana-agent-flow.nix
    ];

  sops.secrets =
    let
      mkNixnucSecret =
        filename: (
          { ... }@args:
          {
            sopsFile = ../../../secrets/nixnuc/${filename};
          } // args
        );

      mkMediaSecret = filename: args: mkNixnucSecret filename args // {
        owner = "media";
      };
    in
    {
      # Access keys for Grafana Agent
      "gc_token" = mkNixnucSecret "grafana-cloud.yaml" {
        owner = "grafana-agent-flow";
        restartUnits = [ "grafana-agent-flow.service" ];
      };
      "hass_token" = mkNixnucSecret "grafana-cloud.yaml" {
        owner = "grafana-agent-flow";
        restartUnits = [ "grafana-agent-flow.service" ];
      };

      # Download client keys for exporters
      "sabnzbd_key" = mkMediaSecret "downloads-tokens.yaml" {
        restartUnits = [ "docker-exportarr-sabnzbd.service" ];
      };
      "lidarr_key" = mkMediaSecret "downloads-tokens.yaml" {
        restartUnits = [ "docker-exportarr-lidarr.service" ];
      };
      "prowlarr_key" = mkMediaSecret "downloads-tokens.yaml" {
        restartUnits = [ "docker-exportarr-prowlarr.service" ];
      };
      "readarr_key" = mkMediaSecret "downloads-tokens.yaml" {
        restartUnits = [ "docker-exportarr-readarr.service" ];
      };
      "radarr_key" = mkMediaSecret "downloads-tokens.yaml" {
        restartUnits = [ "docker-exportarr-radarr.service" ];
      };
      "sonarr_key" = mkMediaSecret "downloads-tokens.yaml" {
        restartUnits = [ "docker-exportarr-sonarr.service" ];
      };
    };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  services.xserver.videoDrivers = [ "modesetting" ];
  services.rpcbind.enable = true;
  programs.dconf.enable = true;

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/f8948e68-b255-4173-b824-6d7f10d21c39";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/D629-8B4D";
      fsType = "vfat";
    };

  fileSystems."/local" =
    {
      device = "/dev/disk/by-uuid/20cbe703-a000-4b7d-98f0-eae0ca6571e3";
      fsType = "ext4";
    };

  fileSystems."/storage" =
    {
      device = "192.168.4.2:/volume1/media";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" ];
    };

  fileSystems."/downloads" =
    {
      device = "192.168.4.2:/volume1/downloads";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" ];
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/99c2f4f1-420b-4435-9350-0d3b75e92b8a"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.home-assistant = {
    enable = true;

    extraComponents = [
      "apple_tv"
      "bluetooth"
      "cast"
      "dlna_dmr"
      "github"
      "google_translate"
      "homekit"
      "homekit_controller"
      "matter"
      "met"
      "mqtt"
      "plex"
      "prometheus"
      "radarr"
      "sabnzbd"
      "sonarr"
      "spotify"
      "synology_dsm"
      "thread"
      "tuya"
      "upnp"
    ];

    config = {
      default_config = { };
      homeassistant = {
        name = "The Hole";
        unit_system = "metric";
        time_zone = "Europe/London";
        temperature_unit = "C";

        external_url = "https://home.hayden.moe";
      };

      prometheus = { namespace = "hy_hass"; };

      #waste_collection_schedule = {
      #  sources = [ { name = "sheffield_gov_uk"; } ];
      #};

      #sensor = [
      #  {
      #    platform = "waste_collection_schedule";
      #    source_index = 0;
      #    name = "Sheffield Waste Collection";
      #  }
      #];

      frontend = {
        themes = "!include_dir_merge_named themes";
      };

      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" "::1" ];
      };
    };
  };

  services.fwupd.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
    ];
  };

  environment.systemPackages = with pkgs; [ cloudflared ];

  boot.kernel.sysctl."net.core.rmem_max" = 2500000;

  services.cloudflared = {
    enable = true;
    tunnels.hy-8hh-nixnuc = {
      warp-routing.enabled = false;
      default = "http_status:404";
      credentialsFile = "/etc/cloudflared/0162d32a-13af-4de8-886f-3d6c68167f9e.json";
      ingress = {
        "*.home.hbjy.io" = "http://localhost:80";
      };
    };
  };

  systemd.services."cloudflared-tunnel-hy-8hh-nixnuc" = {
    environment.TUNNEL_METRICS = "localhost:8927";
  };

  #users.extraUsers.grafana-agent-flow = {
  #  isSystemUser = true;
  #  group = "grafana-agent-flow";
  #  home = "/var/lib/grafana-agent-flow";
  #  createHome = true;
  #  extraGroups = [ "docker" ];
  #  shell = "/run/current-system/sw/bin/nologin";
  #};

  #users.groups.grafana-agent-flow = {};

  services.grafana-agent-flow = {
    enable = true;

    enableJournaldLogging = true;

    grafanaCloud = {
      enable = true;
      stack = "kuraudo";
      tokenFile = config.sops.secrets.gc_token.path;
    };

    staticScrapes = {
      hass = {
        targets = [ "localhost:8123" ];
        bearerTokenFile = config.sops.secrets.hass_token.path;
        metricsPath = "/api/prometheus";
      };

      jellyfin = {
        targets = [ "localhost:8096" ];
      };

      cloudflared = {
        targets = [ "localhost:8927" ];
      };
    };
  };

  # systemd.services.grafana-agent-flow = {
  #   wantedBy = [ "multi-user.target" ];
  #   environment.AGENT_MODE = "flow";
  #   serviceConfig =
  #     let
  #       configFile = (pkgs.writeText "config.river" ''
  #         local.file "gc_token" {
  #           filename = "/run/secrets/gc_token"
  #           is_secret = true
  #         }

  #         local.file "hass_token" {
  #           filename = "/run/secrets/hass_token"
  #           is_secret = true
  #         }

  #         module.git "grafana_cloud" {
  #           repository = "https://github.com/grafana/agent-modules.git"
  #           path = "modules/grafana-cloud/autoconfigure/module.river"
  #           revision = "main"
  #           pull_frequency = "0s"
  #           arguments {
  #             stack_name = "kuraudo"
  #             token = local.file.gc_token.content
  #           }
  #         }

  #         prometheus.scrape "linux_node" {
  #           targets = prometheus.exporter.unix.main.targets
  #           forward_to = [
  #             module.git.grafana_cloud.exports.metrics_receiver,
  #           ]
  #         }

  #         prometheus.exporter.unix "main" {
  #         }

  #         loki.relabel "journal" {
  #           forward_to = []

  #           rule {
  #             source_labels = ["__journal__systemd_unit"]
  #             target_label  = "unit"
  #           }
  #           rule {
  #             source_labels = ["__journal__boot_id"]
  #             target_label  = "boot_id"
  #           }
  #           rule {
  #             source_labels = ["__journal__transport"]
  #             target_label  = "transport"
  #           }
  #           rule {
  #             source_labels = ["__journal_priority_keyword"]
  #             target_label  = "level"
  #           }
  #           rule {
  #             source_labels = ["__journal__hostname"]
  #             target_label  = "instance"
  #           }
  #         }

  #         loki.source.journal "read" {
  #           forward_to = [module.git.grafana_cloud.exports.logs_receiver]
  #           relabel_rules = loki.relabel.journal.rules
  #           labels = {
  #             "job" = "integrations/node_exporter",
  #           }
  #         }

  #         prometheus.scrape "static" {
  #           forward_to = [module.git.grafana_cloud.exports.metrics_receiver]
  #           targets = [{"__address__" = "localhost:8123"}]

  #           authorization {
  #             type = "Bearer"
  #             credentials = local.file.hass_token.content
  #           }

  #           scrape_interval = "10s"
  #           metrics_path = "/api/prometheus"
  #         }

  #         prometheus.scrape "cloudflared" {
  #           forward_to = [module.git.grafana_cloud.exports.metrics_receiver]
  #           targets = [{"__address__" = "localhost:8927"}]
  #           scrape_interval = "10s"
  #         }

  #         prometheus.scrape "jellyfin" {
  #           forward_to = [module.git.grafana_cloud.exports.metrics_receiver]
  #           targets = [{"__address__" = "localhost:8096"}]
  #           scrape_interval = "10s"
  #         }

  #         ${lib.concatMapStringsSep "\n" (port: ''
  #           prometheus.scrape "exportarr_${toString port}" {
  #             forward_to = [module.git.grafana_cloud.exports.metrics_receiver]
  #             targets = [{"__address__" = "localhost:${toString port}"}]
  #             scrape_interval = "10s"
  #             metrics_path = "/metrics"
  #           }
  #         '') (lib.range 9707 9712)}
  #       '');
  #     in
  #     {
  #       ExecStart = "${lib.getExe pkgs.grafana-agent} run ${configFile} --storage.path /var/lib/grafana-agent-flow --server.http.listen-addr 0.0.0.0:12345";
  #       Restart = "always";
  #       User = "grafana-agent-flow";
  #       RestartSec = 2;
  #       StateDirectory = "grafana-agent-flow";
  #       Type = "simple";
  #     };
  # };

  virtualisation.oci-containers = {
    backend = "docker";
  };
}
