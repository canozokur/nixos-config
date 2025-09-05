{ ... }:
{
  xdg.configFile."wezterm/util.lua".text = ''
    local module = {}

    module.build_link_regex = function(protocols)
      local prefix = "(?:"
      for _, proto in pairs(protocols) do
        proto = proto .. "://"
        if proto == "git" then
          proto = proto .. "@"
        end
        prefix = prefix .. proto
      end
      local postfix = ")\\S+"
      return prefix .. postfix
    end

    return module
  '';

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require("wezterm")
      local act = wezterm.action
      local util = require("util")
      local disabled = wezterm.action.DisableDefaultAssignment

      return {
        color_scheme = "catppuccin-mocha",
        term = "wezterm",
        font = wezterm.font({family="CaskaydiaCove Nerd Font Mono", weight="Regular"}),
        font_rules = {
          {
            intensity = "Half",
            font = wezterm.font_with_fallback({
              {family="CaskaydiaCove Nerd Font Mono", weight = "Light", style = "Normal"},
              "JetBrains Mono",
              "Noto Color Emoji",
            })
          }
        },
        font_size = 12,
        enable_wayland = true,
        window_background_opacity = 0.95,
        window_decorations = "NONE",
        use_fancy_tab_bar = false,
        enable_tab_bar = false,
        tab_bar_at_bottom = false,
        enable_scroll_bar = false,
        cursor_blink_rate = 0,
        -- enable kitty keyb proto to report more modifiers to apps
        enable_kitty_keyboard = true,

        window_padding = {
          left = 0,
          right = 0,
          top = 0,
          bottom = 0,
        },

        window_close_confirmation = "NeverPrompt",

        -- (shamelessly) snatched from:
        -- https://github.com/ruslanSorokin/dotfiles/blob/e8e3b9f5aaf14d32fbc773c657659f8d8a2e6419/home/chezmoi/private_dot_config/wezterm/wezterm.
        quick_select_patterns = {
          -- markdown_url
          "\\[[^]]*\\]\\(([^)]+)\\)",

          -- diff_a
          "--- a/(\\S+)",
          -- diff_b
          "\\+\\+\\+ b/(\\S+)",
          -- docker
          "sha256:([0-9a-f]{64})",

          -- ed25519 long ID
          "(?:((?:ed|cv)25519|(?:rsa|dsa|elg)\\d+)/(?:0[xX])?)(\\h+)", --[[ MUST BE before 'path' ]]

          -- PGP key fingerprint
          "Key fingerprint = ((?:\\h| ){50})",
          -- PGP key fingerprint
          "\\:(\\h{40})\\:",
          -- PGP keygrip
          "Keygrip = (\\h{40})",
          -- PGP keygrip
          "\\h{40}",

          -- path
          "(?:[.\\w\\-@~]+)?(?:/+[.\\w\\-@]+)+", -- [[ MUST BE before 'mnemonic names' regex ]]

          -- color
          "#[0-9a-fA-F]{6}",

          -- mnemonic names e.g. OCI containers / zellij sessions
          "(?:[.\\w\\-@~]+)(?:-|_)(?:[.\\w\\-@~]+)", -- MUST BE before 'uuid' regex

          -- uuid
          "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",

          -- ipfs
          "Qm[0-9a-zA-Z]{44}",
          -- sha
          "[0-9a-f]{7,40}",
          -- ip
          "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}",
          -- ipv6
          "[A-f0-9:]+:+[A-f0-9:]+[%\\w\\d]+",
          -- address
          "0x[0-9a-fA-F]+",
          -- number
          "[0-9]{4,}",
          -- SHA fingerprint
          "(?:SHA(1|128|256|512)):(\\S+)",

          -- [0-9A-Fa-f]
          "[\\h:]+:+[\\h:]+[%\\w\\d]+",

          util.build_link_regex({
            "https",
            "http",
            "git",
            "ssh",
            "ftp",
            "file",
          }),

          -- vless has a lot of garbage that cannot be captured with \\S+
          "vless://.*",

          -- email
          "<(\\S+)>",
        },

        -- disable all keybindings first
        disable_default_key_bindings = true,

        keys = {
          { key = "s", mods = "CTRL|SHIFT", action = act.QuickSelect },
          { key = "p", mods = "ALT", action = disabled },
          { key = "p", mods = "CTRL|SHIFT", action = disabled },
          { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },
          { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
          { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
          { key = 'L', mods = 'CTRL|SHIFT', action = act.ShowDebugOverlay },
        },
      }
    '';
  };
}
