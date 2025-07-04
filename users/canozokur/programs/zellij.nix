{ pkgs, lib, ... }:
let
  # catppuccin colorscheme
  colors = {
    rosewater = "#f5e0dc";
    flamingo = "#f2cdcd";
    pink = "#f5c2e7";
    mauve = "#cba6f7";
    red = "#f38ba8";
    maroon = "#eba0ac";
    peach = "#fab387";
    yellow = "#f9e2af";
    green = "#a6e3a1";
    teal = "#94e2d5";
    sky = "#89dceb";
    sapphire = "#74c7ec";
    blue = "#89b4fa";
    lavender = "#b4befe";
    text = "#cdd6f4";
    subtext1 = "#bac2de";
    subtext0 = "#a6adc8";
    overlay2 = "#9399b2";
    overlay1 = "#7f849c";
    overlay0 = "#6c7086";
    surface2 = "#585b70";
    surface1 = "#45475a";
    surface0 = "#313244";
    base = "#1e1e2e";
    mantle = "#181825";
    crust = "#11111b";
  };

  formatPaddedAttrSet = attrset: paddingSize:
    let
      keyNames = builtins.attrNames attrset;
      findMaxLength = maxLengthSoFar: currentKey: lib.max (builtins.stringLength currentKey) maxLengthSoFar;
      maxKeyLength = lib.foldl' findMaxLength 0 keyNames;
      totalWidth = maxKeyLength + paddingSize;

      formatLine = key:
        let
          value = attrset.${key};
          spacesToAdd = totalWidth - (builtins.stringLength key);
          paddingString = lib.strings.replicate (lib.max 0 spacesToAdd) " ";
          paddedKey = "${key}${paddingString}";
        in
        "${paddedKey}\"${value}\"";
        sortedKeys = lib.sort builtins.lessThan keyNames;
        formattedLines = lib.map formatLine sortedKeys;
    in builtins.concatStringsSep "\n" formattedLines;

  prefixedColors = lib.mapAttrs'
    (k: v: lib.nameValuePair ("color_" + k) v)
    colors;

  zellijColors = formatPaddedAttrSet prefixedColors 1;
in
{
  home.packages = [ pkgs.zjstatus ];

  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    attachExistingSession = true;
  };

  # see: https://github.com/nix-community/home-manager/pull/4665#issuecomment-1822999684
  # current KDL generator is not good enough to have the whole config here
  xdg.configFile."zellij/config.kdl".text = ''
    theme "catppuccin-mocha"
    keybinds clear-defaults=true {
        locked {
            bind "Ctrl g" { SwitchToMode "normal"; }
        }
        pane {
            bind "left" { MoveFocus "left"; }
            bind "down" { MoveFocus "down"; }
            bind "up" { MoveFocus "up"; }
            bind "right" { MoveFocus "right"; }
            bind "c" { SwitchToMode "renamepane"; PaneNameInput 0; }
            bind "d" { NewPane "down"; SwitchToMode "normal"; }
            bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "normal"; }
            bind "f" { ToggleFocusFullscreen; SwitchToMode "normal"; }
            bind "h" { MoveFocus "left"; }
            bind "j" { MoveFocus "down"; }
            bind "k" { MoveFocus "up"; }
            bind "l" { MoveFocus "right"; }
            bind "n" { NewPane; SwitchToMode "normal"; }
            bind "p" { SwitchFocus; }
            bind "]" { BreakPaneRight; SwitchToMode "normal"; }
            bind "[" { BreakPaneLeft; SwitchToMode "normal"; }
            bind "b" { BreakPane; SwitchToMode "normal"; }
            bind "Alt p" { SwitchToMode "normal"; }
            bind "r" { NewPane "right"; SwitchToMode "normal"; }
            bind "w" { ToggleFloatingPanes; SwitchToMode "normal"; }
            bind "x" { CloseFocus; SwitchToMode "normal"; }
            bind "z" { TogglePaneFrames; SwitchToMode "normal"; }
            bind "i" { TogglePanePinned; SwitchToMode "Normal"; }
        }
        tab {
            bind "left" { GoToPreviousTab; }
            bind "down" { GoToNextTab; }
            bind "up" { GoToPreviousTab; }
            bind "right" { GoToNextTab; }
            bind "1" { GoToTab 1; SwitchToMode "normal"; }
            bind "2" { GoToTab 2; SwitchToMode "normal"; }
            bind "3" { GoToTab 3; SwitchToMode "normal"; }
            bind "4" { GoToTab 4; SwitchToMode "normal"; }
            bind "5" { GoToTab 5; SwitchToMode "normal"; }
            bind "6" { GoToTab 6; SwitchToMode "normal"; }
            bind "7" { GoToTab 7; SwitchToMode "normal"; }
            bind "8" { GoToTab 8; SwitchToMode "normal"; }
            bind "9" { GoToTab 9; SwitchToMode "normal"; }
            bind "h" { GoToPreviousTab; }
            bind "j" { GoToNextTab; }
            bind "k" { GoToPreviousTab; }
            bind "l" { GoToNextTab; }
            bind "n" { NewTab; SwitchToMode "normal"; }
            bind "r" { SwitchToMode "renametab"; TabNameInput 0; }
            bind "s" { ToggleActiveSyncTab; SwitchToMode "normal"; }
            bind "Alt t" { SwitchToMode "normal"; }
            bind "x" { CloseTab; SwitchToMode "normal"; }
            bind "tab" { ToggleTab; }
        }
        resize {
            bind "left" { Resize "Increase left"; }
            bind "down" { Resize "Increase down"; }
            bind "up" { Resize "Increase up"; }
            bind "right" { Resize "Increase right"; }
            bind "+" { Resize "Increase"; }
            bind "-" { Resize "Decrease"; }
            bind "=" { Resize "Increase"; }
            bind "H" { Resize "Decrease left"; }
            bind "J" { Resize "Decrease down"; }
            bind "K" { Resize "Decrease up"; }
            bind "L" { Resize "Decrease right"; }
            bind "h" { Resize "Increase left"; }
            bind "j" { Resize "Increase down"; }
            bind "k" { Resize "Increase up"; }
                    bind "l" { Resize "Increase right"; }
            bind "Alt n" { SwitchToMode "normal"; }
        }
        move {
            bind "left" { MovePane "left"; }
            bind "down" { MovePane "down"; }
            bind "up" { MovePane "up"; }
            bind "right" { MovePane "right"; }
            bind "h" { MovePane "left"; }
            bind "Alt h" { SwitchToMode "normal"; }
            bind "j" { MovePane "down"; }
            bind "k" { MovePane "up"; }
            bind "l" { MovePane "right"; }
            bind "n" { MovePane; }
            bind "p" { MovePaneBackwards; }
            bind "tab" { MovePane; }
        }
        scroll {
            bind "/" { SwitchToMode "entersearch"; SearchInput 0; }
            bind "D" { ScrollToBottom; }
            bind "U" { ScrollToTop; }
            bind "c" { }
            bind "e" { EditScrollback; SwitchToMode "normal"; }
        }
        search {
            bind "c" { SearchToggleOption "CaseSensitivity"; }
            bind "n" { Search "down"; }
            bind "o" { SearchToggleOption "WholeWord"; }
            bind "p" { Search "up"; }
            bind "w" { SearchToggleOption "Wrap"; }
        }
        session {
            bind "d" { Detach; }
            bind "Alt o" { SwitchToMode "normal"; }
            bind "w" {
                LaunchOrFocusPlugin "session-manager" {
                    floating true
                    move_to_focused_tab true
                }
                SwitchToMode "normal"
            }
        }
        shared_except "locked" {
            bind "Alt +" { Resize "Increase"; }
            bind "Alt -" { Resize "Decrease"; }
            bind "Alt =" { Resize "Increase"; }
            bind "Alt Q" { Quit; }
            bind "Alt g" { SwitchToMode "locked"; }
        }
        shared_except "locked" "move" {
            bind "Alt h" { SwitchToMode "move"; }
        }
        shared_except "locked" "session" {
            bind "Alt o" { SwitchToMode "session"; }
        }
        shared_except "locked" "scroll" "search" {
            bind "Alt s" { SwitchToMode "scroll"; }
        }
        shared_except "locked" "tab" {
            bind "Alt t" { SwitchToMode "tab"; }
        }
        shared_except "locked" "pane" {
            bind "Alt p" { SwitchToMode "pane"; }
            bind "Alt w" { ToggleFloatingPanes; SwitchToMode "normal"; }
        }
        shared_except "locked" "resize" {
            bind "Alt n" { SwitchToMode "resize"; }
        }
        shared_except "normal" "locked" "entersearch" {
            bind "enter" { SwitchToMode "normal"; }
        }
            shared_except "normal" "locked" "entersearch" "renametab" "renamepane" {
            bind "esc" { SwitchToMode "normal"; }
        }
        shared_among "scroll" "search" {
            bind "PageDown" { PageScrollDown; }
            bind "PageUp" { PageScrollUp; }
            bind "left" { PageScrollUp; }
            bind "down" { ScrollDown; }
            bind "up" { ScrollUp; }
            bind "right" { PageScrollDown; }
            bind "Ctrl b" { PageScrollUp; }
            bind "Alt c" { ScrollToBottom; SwitchToMode "normal"; }
            bind "d" { HalfPageScrollDown; }
            bind "Ctrl f" { PageScrollDown; }
            bind "h" { PageScrollUp; }
            bind "j" { ScrollDown; }
            bind "k" { ScrollUp; }
            bind "l" { PageScrollDown; }
            bind "Alt s" { SwitchToMode "normal"; }
            bind "u" { HalfPageScrollUp; }
        }
        entersearch {
            bind "Alt c" { SwitchToMode "scroll"; }
            bind "esc" { SwitchToMode "scroll"; }
            bind "enter" { SwitchToMode "search"; }
        }
        renametab {
            bind "esc" { UndoRenameTab; SwitchToMode "tab"; }
        }
        shared_among "renametab" "renamepane" {
            bind "Alt c" { SwitchToMode "normal"; }
        }
        renamepane {
            bind "esc" { UndoRenamePane; SwitchToMode "pane"; }
        }
    }

    plugins {
        about location="zellij:about"
        compact-bar location="zellij:compact-bar"
        configuration location="zellij:configuration"
        filepicker location="zellij:strider" {
            cwd "/"
        }
        plugin-manager location="zellij:plugin-manager"
        session-manager location="zellij:session-manager"
        status-bar location="zellij:status-bar"
        strider location="zellij:strider"
        tab-bar location="zellij:tab-bar"
        welcome-screen location="zellij:session-manager" {
            welcome_screen true
        }
    }
    load_plugins {
    }
    pane_frames false
    scrollback_editor "/usr/bin/nvim"
    show_startup_tips false
  '';
  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
      default_tab_template {
        children
          pane size=1 borderless=true {
            plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
              ${zellijColors}
              format_left   "{mode}#[fg=$base]{tabs}"
              format_space  ""

              mode_normal        "#[bg=$base,fg=$text]  #[bg=$base,fg=$base]"
              mode_tab           "#[bg=$base,fg=$text,bold] 󰌒 #[bg=$base,fg=$base]"
              mode_tmux          "#[bg=$peach,fg=$text]  #[fg=$peach,bg=$base]"
              mode_locked        "#[bg=$red,fg=$base]  #[fg=$red,bg=$base]"
              mode_resize        "#[bg=$teal,fg=$base] 󰑝 #[fg=$teal,bg=$base]"
              mode_pane          "#[bg=$mauve,fg=$base] 󰃻 #[fg=$mauve,bg=$base]"
              mode_scroll        "#[bg=$blue,fg=$base]  #[fg=$blue,bg=$base]"
              mode_enter_search  "#[bg=$lavender,fg=$base,bold]  #[fg=$lavender,bg=$base]"
              mode_search        "#[bg=$sapphire,fg=$base]  #[fg=$sapphire,bg=$base]"
              mode_rename_tab    "#[bg=$green,fg=$base]  #[fg=$green,bg=$base]"
              mode_rename_pane   "#[bg=$green,fg=$base]  #[fg=$green,bg=$base]"
              mode_session       "#[bg=$rosewater,fg=$base]  #[fg=$rosewater,bg=$base]"
              mode_move          "#[bg=$maroon,fg=$base]  #[fg=$maroon,bg=$base]"
              mode_prompt        "#[bg=$green,fg=$base]  #[fg=$green,bg=$base]"

              tab_normal   "#[fg=$base,bg=$overlay0] {index} #[fg=$overlay0,bg=$base]"
              tab_active   "#[fg=$base,bg=$blue,bold] {index} #[fg=$blue,bg=$base]"
            }
          }
      }
    }
  '';
}
