{ ... }:
{
  programs.obsidian = {
    enable = true;
    vaults = {
      "personal" = {
        enable = true;
        target = "Documents/obsidian/personal";
        settings = {
          corePlugins = [
            "backlink"
            "bookmarks"
            "canvas"
            "command-palette"
            "daily-notes"
            "editor-status"
            "file-explorer"
            "file-recovery"
            "global-search"
            "graph"
            "note-composer"
            "outgoing-link"
            "outline"
            "page-preview"
            "switcher"
            "slides"
            "sync"
            "tag-pane"
            "templates"
            "word-count"
          ];
          communityPlugins = [
          ];
        };
      };
    };
  };
}
