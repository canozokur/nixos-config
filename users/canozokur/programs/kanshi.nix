{ ... }:
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
