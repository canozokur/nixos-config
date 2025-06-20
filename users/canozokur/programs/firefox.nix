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
          "browser.aboutConfig.showWarning" = false;
          "browser.firefox-view.feature-tour" = { "message" = "FIREFOX_VIEW_FEATURE_TOUR"; "screen" = ""; "complete" = true; };
          "browser.toolbars.bookmarks.visibility" = "never";
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
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
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
            };
            "Kagi" = {
              urls = [{ template = "https://kagi.com/search?q={searchTerms}"; }];
              icon = "https://kagi.com/asset/9ade212/kagi_assets/logos/blue_1.svg?v=0679f32d13823ea4193af65d0d67c6e78f17e0da";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@k" ];
            };
            "Home Manager Options" = {
              urls = [{ template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master"; }];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@hmo" ];
            };
            "Noogle" = {
              urls = [{ template = "https://noogle.dev/q?term={searchTerms}"; }];
              icon = "https://noogle.dev/favicon.ico";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@ng" ];
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
