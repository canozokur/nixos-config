{
  inputs,
  lib,
  helpers,
  config,
  ...
}:
let
  allHosts = inputs.self.nixosConfigurations;

  localHosts = helpers.getHostsWith allHosts [
    "networks"
    "internalIP"
  ];
  localDns = lib.mapAttrsToList (n: h: "${h.config._meta.networks.internalIP} ${n}.lan") localHosts;

  customDnsHosts = helpers.getHostsWith allHosts "dnsConfigurations";
  customDnsEntries = lib.flatten (
    lib.mapAttrsToList (
      _: host:
      let
        configs = host.config._meta.dnsConfigurations;
      in
      map (entry: "${entry.ip} ${entry.domain}") configs
    ) customDnsHosts
  );

  piholeHosts = helpers.getHostsWith allHosts [
    "services"
    "dnsServer"
  ];
  dnsServersList = lib.mapAttrsToList (n: h: "${h.config._meta.networks.internalIP}") piholeHosts;
  dnsServers = builtins.concatStringsSep "," dnsServersList;
in
{
  services.pihole-web = {
    enable = true;
    hostName = "pihole.pco.pink";
    ports = [
      "1080r"
      "1443s"
    ];
  };
  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
    openFirewallDHCP = true;
    openFirewallWebserver = true;
    queryLogDeleter.enable = true; # deletes logs weekly by default
    settings = {
      dns = {
        upstreams = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        hosts = localDns ++ customDnsEntries;
      };
      dhcp = {
        active = lib.mkIf config._meta.services.dhcpServer true;
        start = "192.168.1.50";
        end = "192.168.1.252"; # reserve 253 for internal connections, 254 for external and 255 for broadcast (just in case)
        router = "192.168.1.1";
        netmask = "255.255.255.0";
        leaseTime = "24h";
        rapidCommit = true;
        hosts = [
          "14:cb:19:17:d7:4e,192.168.1.2,laserjet,24h"
          "d8:bb:c1:63:da:ff,192.168.1.129,truenas,24h"
          "74:e6:b8:08:37:2d,192.168.1.148,lgwebostv,24h"
        ];
      };
      misc.dnsmasq_lines = [
        "dhcp-option=option:dns-server,${dnsServers}"
      ]
      ++ lib.optionals config.services.consul.enable [ "server=/consul/127.0.0.1#8600" ];
    };
    lists = [
      {
        url = "https://reddestdream.github.io/Projects/MinimalHosts/etc/MinimalHostsBlocker/minimalhosts";
      }
      { url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/KADhosts/hosts"; }
      { url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.Spam/hosts"; }
      { url = "https://v.firebog.net/hosts/static/w3kbl.txt"; }
      { url = "https://www.joewein.net/dl/bl/dom-bl-base.txt"; }
      {
        url = "https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt";
      }
      { url = "https://someonewhocares.org/hosts/zero/hosts"; }
      { url = "https://raw.githubusercontent.com/Dawsey21/Lists/master/main-blacklist.txt"; }
      { url = "https://raw.githubusercontent.com/vokins/yhosts/master/hosts"; }
      { url = "http://winhelp2002.mvps.org/hosts.txt"; }
      { url = "https://adaway.org/hosts.txt"; }
      { url = "https://v.firebog.net/hosts/AdguardDNS.txt"; }
      { url = "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"; }
      { url = "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"; }
      { url = "https://v.firebog.net/hosts/Easylist.txt"; }
      { url = "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts;showintro=0"; }
      { url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/UncheckyAds/hosts"; }
      { url = "https://v.firebog.net/hosts/Easyprivacy.txt"; }
      { url = "https://v.firebog.net/hosts/Prigent-Ads.txt"; }
      { url = "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt"; }
      { url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.2o7Net/hosts"; }
      { url = "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"; }
      { url = "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/android-tracking.txt"; }
      { url = "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/SmartTV.txt"; }
      { url = "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"; }
      {
        url = "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt";
      }
      { url = "https://v.firebog.net/hosts/Prigent-Malware.txt"; }
      { url = "https://phishing.army/download/phishing_army_blocklist_extended.txt"; }
      { url = "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"; }
      { url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.Risk/hosts"; }
      { url = "https://raw.githubusercontent.com/HorusTeknoloji/TR-PhishingList/master/url-lists.txt"; }
      { url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt"; }
      # allow lists (type = allow)
      {
        url = "https://raw.githubusercontent.com/GoodnessJSON/PiHole-Whitelist/master/lists/whitelist.txt";
        type = "allow";
      }
    ];
  };
}
