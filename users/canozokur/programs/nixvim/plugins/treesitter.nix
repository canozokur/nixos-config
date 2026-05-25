{ pkgs, ... }:
{
  plugins = {
    treesitter = {
      enable = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        c
        cpp
        go
        helm
        javascript
        jsdoc
        lua
        luadoc
        nix
        python
        tsx
        typescript
        yaml

        diff
        dockerfile
        gitcommit
        gitignore
        git_config
        git_rebase
        gomod
        gosum
        gowork
        json
        markdown
        markdown_inline
        query
        regex
        toml
        vim
        vimdoc
      ];
      settings = {
        auto_install = false;
        highlight = {
          enable = true;
        };
      };
    };
  };
}
