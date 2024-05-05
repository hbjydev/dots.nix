{ config, ... }:
{
  imports = [ ./nginx.nix ];

  sops.secrets.srht_netkey = {
    sopsFile = ../secrets/sourcehut.yaml;
    owner = "root";
    restartUnits = [ "matrix-sliding-sync.service" ];
  };
  sops.secrets.srht_srvkey = {
    sopsFile = ../secrets/sourcehut.yaml;
    owner = "root";
    restartUnits = [ "matrix-sliding-sync.service" ];
  };
  sops.secrets.srht_whprivkey = {
    sopsFile = ../secrets/sourcehut.yaml;
    owner = "root";
    restartUnits = [ "matrix-sliding-sync.service" ];
  };

  services.sourcehut = {
    enable = true;
    git.enable = true;
    man.enable = true;
    meta.enable = true;
    nginx.enable = true;
    postgresql.enable = true;
    redis.enable = true;
    settings = {
      "sr.ht" = {
        environment = "production";
        global-domain = "git.hayden.moe";
        origin = "https://git.hayden.moe";
        network-key = config.sops.secrets.srht_netkey.path;
        service-key = config.sops.secrets.srht_srvkey.path;
      };
      webhooks.private-key = config.sops.secrets.srht_whprivkey.path;
    };
  };
}
