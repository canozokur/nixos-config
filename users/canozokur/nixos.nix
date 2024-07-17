{ ... }:
{
  users.users.canozokur = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    createHome = true;
  };
}
