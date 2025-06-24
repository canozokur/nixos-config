{ pkgs, ... }:
{
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile = {
          name = "laptop";
          outputs = [
            { criteria = "Sharp Corporation 0x14D0 Unknown"; status = "enable"; }
          ];
        };
      }
      {
        profile = {
          name = "home_dual";
          outputs = [
            { criteria = "Sharp Corporation 0x14D0 Unknown"; status = "disable"; }
            {
              criteria = "ASUSTek COMPUTER INC VG27B LALMQS275717";
              status = "enable";
              mode = "2560x1440@144Hz";
              transform = "270";
              position = "0,0";
            }
            {
              criteria = "ASUSTek COMPUTER INC PG279QE K7LMQS096556";
              status = "enable";
              mode = "2560x1440@60Hz";
              position = "1440,0";
            }
          ];
          exec = [
            "${pkgs.sway}/bin/swaymsg workspace 1, workspace 1 output '\"ASUSTek COMPUTER INC PG279QE K7LMQS096556\"'"
            "${pkgs.sway}/bin/swaymsg workspace 2, workspace 2 output '\"ASUSTek COMPUTER INC PG279QE K7LMQS096556\"'"
            "${pkgs.sway}/bin/swaymsg workspace 3, workspace 3 output '\"ASUSTek COMPUTER INC PG279QE K7LMQS096556\"'"
            "${pkgs.sway}/bin/swaymsg workspace 4, workspace 4 output '\"ASUSTek COMPUTER INC PG279QE K7LMQS096556\"'"
            "${pkgs.sway}/bin/swaymsg workspace 5, workspace 5 output '\"ASUSTek COMPUTER INC PG279QE K7LMQS096556\"'"
            "${pkgs.sway}/bin/swaymsg workspace 6, workspace 6 output '\"ASUSTek COMPUTER INC VG27B LALMQS275717\"'"
            "${pkgs.sway}/bin/swaymsg workspace 7, workspace 7 output '\"ASUSTek COMPUTER INC VG27B LALMQS275717\"'"
            "${pkgs.sway}/bin/swaymsg workspace 8, workspace 8 output '\"ASUSTek COMPUTER INC VG27B LALMQS275717\"'"
            "${pkgs.sway}/bin/swaymsg workspace 9, workspace 9 output '\"ASUSTek COMPUTER INC VG27B LALMQS275717\"'"
            "${pkgs.sway}/bin/swaymsg workspace 1, move workspace to '\"ASUSTek COMPUTER INC PG279QE K7LMQS096556\"'"
            "${pkgs.sway}/bin/swaymsg workspace 2, move workspace to '\"ASUSTek COMPUTER INC PG279QE K7LMQS096556\"'"
            "${pkgs.sway}/bin/swaymsg workspace 6, move workspace to '\"ASUSTek COMPUTER INC VG27B LALMQS275717\"'"
          ];
        };
      }
      {
        profile = {
          name = "home_single";
          outputs = [
            { criteria = "Sharp Corporation 0x14D0 Unknown"; status = "disable"; }
            {
              criteria = "ASUSTek COMPUTER INC PG279QE K7LMQS096556";
              status = "enable";
              mode = "2560x1440@60Hz";
            }
          ];
        };
      }
    ];
  };
}
