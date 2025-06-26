{ ... }:
# old config
# undervolt -v --turbo 1 -p1 35 10 -p2 35 10
{
  services.undervolt = {
    enable = true;
    coreOffset = -50;
    verbose = true;
  };
}
