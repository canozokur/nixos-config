{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          "browser.startup.homepage" = "about:newtab";
          "browser.search.defaultenginename" = "Kagi";
          "browser.search.order.1" = "Kagi";
        };
        search = {
          force = true;
          default = "Kagi";
          order = [ "kagi" "google" ];
          engines = {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "channel"; value = "unstable"; }
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
              icon = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
            };
            "Kagi" = {
              urls = [{ template = "https://kagi.com/search?q={searchTerms}"; }];
              icon = "https://kagi.com/asset/9ade212/kagi_assets/logos/blue_1.svg?v=0679f32d13823ea4193af65d0d67c6e78f17e0da";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@k" ];
            };
            "bing".metaData.hidden = true;
            "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
          };
        };
        # stylesheet to disable tab close buttons
        # don't forget to open about:config and enable toolkit.legacyUserProfileCustomizations.stylesheets
        userChrome = ''
          @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");
          .tab-close-button { display: none !important; }
        '';
      };
    };
  };
}
