{ ... }:
{
  imports = [
    ./gh.nix
    ./git.nix
    ./nix.nix
    ./packages.nix
    ./sops.nix
    ./ssh.nix
    ./zsh.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    LANG = "en_GB.UTF-8";
    LC_ALL = "en_GB.UTF-8";
    LC_CTYPE = "en_GB.UTF-8";
    PATH = "$PATH:$GOPATH/bin";
  };

  home.stateVersion = "24.11";
}
