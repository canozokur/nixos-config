{ pkgs, ... }:
let
  nvim-hardline = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-hardline";
    src = pkgs.fetchFromGitHub {
      owner = "ojroques";
      repo = "nvim-hardline";
      rev = "9b85ebfba065091715676fb440c16a37c465b9a5";
      hash = "sha256-BY5uo5Fo9bAg0cy1GZLMglcc4lVt22q15PKIRIJgqd8=";
    };
  };
in
{
  home.stateVersion = "24.05";
  home.packages = with pkgs; [
    fzf
    tree
    jq
    htop
    ripgrep
    watch
  ];

  programs.git = {
    enable = true;
    userEmail = "13416785+canozokur@users.noreply.github.com";
    userName = "canozokur";
    extraConfig = {
      pull = { ff = "only"; };
      init = { defaultbranch = "main"; };
      push = { autosetupremote = true; };
      url."git@github.com:".insteadOf = "https://github.com/";
      core = {
        filemode = true;
        bare = false;
        logallrefupdates = true;
      };
    };
    delta = {
      enable = true;
      options = {
        features = "side-by-side line-numbers decorations";
        whitespace-error-style = "22 reverse";
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          file-decoration-style = "none";
        };
      };
    }; 
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = [
      pkgs.fd # telescope wants it
    ];

    plugins = with pkgs.vimPlugins; [
      cmp-nvim-lsp
      nvim-lspconfig
      nvim-cmp
      luasnip
      nvim-hardline
      plenary-nvim
      harpoon2
      indent-blankline-nvim
      lazy-lsp-nvim
      lsp-zero-nvim
      nightfox-nvim
      telescope-nvim
      nvim-treesitter.withAllGrammars
      undotree
    ];

    extraLuaConfig = (import ./vim-config.nix) {};
  };
}
