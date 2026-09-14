{
  name = "nzbget";
  port = 6789;
  backendAddr = "192.168.1.129";
  extraConfig = ''
    client_max_body_size 0; # disable max upload size for nzbs
  '';
}
