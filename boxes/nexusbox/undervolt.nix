{ ... }:
{
  services.undervolt = {
    enable = true;
    coreOffset = -80;
    temp = 70;
    verbose = true;
  };
}
