{ ... }:
{
  programs.bluetuith = {
    enable = true;
    settings = {
      keybindings = {
        Help = "?";
        NavigateUp = "k";
        NavigateDown = "j";
        NavigateRight = "l";
        NavigateLeft = "h";
        Quit = "q";
        FilebrowserToggleHidden = ".";
        DeviceSendFiles = "f";
      };
    };
  };
}
