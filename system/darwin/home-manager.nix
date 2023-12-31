{ inputs, work }:

{ pkgs, ... }:

let
  shared-config = import ../shared/home-manager.nix { inherit inputs work; };
  shared-packages = import ../shared/home-manager-packages.nix { inherit pkgs inputs work; };
in
{
  imports = [ shared-config ];

  home.file."Library/Application Support/k9s/skin.yml".source = ../../config/k9s/skin.yml;

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      ${builtins.readFile ../../config/wezterm/colorutils.lua}
      ${builtins.readFile ../../config/wezterm/wezterm.lua}
    '';
  };

  programs.kitty = {
    enable = true;

    font = {
      name = "IntoneMono Nerd Font";
      package = pkgs.nerdfonts.override {
        fonts = [ "IntelOneMono" ];
      };
      size = 12;
    };

    settings = {
      active_border_color = "#ee5396";
      active_tab_background = "#ee5396";
      active_tab_foreground = "#161616";
      allow_remote_control = "yes";
      background = "#161616";
      background_opacity = "0.9";
      bell_border_color = "#ee5396";
      color0 = "#262626";
      color1 = "#ff7eb6";
      color10 = "#42be65";
      color11 = "#82cfff";
      color12 = "#33b1ff";
      color13 = "#ee5396";
      color14 = "#3ddbd9";
      color15 = "#ffffff";
      color2 = "#42be65";
      color3 = "#82cfff";
      color4 = "#33b1ff";
      color5 = "#ee5396";
      color6 = "#3ddbd9";
      color7 = "#dde1e6";
      color8 = "#393939";
      color9 = "#ff7eb6";
      cursor = "#f2f4f8";
      cursor_text_color = "#393939";
      enabled_layouts = "splits";
      foreground = "#dde1e6";
      hide_window_decorations = "titlebar-and-corners";
      inactive_border_color = "#ff7eb6";
      inactive_tab_background = "#393939";
      inactive_tab_foreground = "#dde1e6";
      listen_on = "unix:/tmp/kitty";
      macos_option_as_alt = "yes";
      macos_quit_when_last_window_closed = "yes";
      macos_titlebar_color = "system";
      selection_background = "#525252";
      selection_foreground = "#f2f4f8";
      tab_bar_background = "#161616";
      url_color = "#ee5396";
      url_style = "single";
      wayland_titlebar_color = "system";
    };
  };

  home.packages = shared-packages ++ [ ];
}
