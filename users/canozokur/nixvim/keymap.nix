{ ... }:
{
  programs.nixvim.globals.mapleader = " ";
  programs.nixvim.keymaps = [
    {
      key = "<leader>pv";
      action = ":Ex<cr>";
      mode = "n";
    }
    {
      key = "J";
      action = ":m '>+1<CR>gv=gv";
      mode = "v";
    }
    {
      key = "K";
      action = ":m '<-2<CR>gv=gv";
      mode = "v";
    }
    {
      key = "J";
      action = "mzJ`z";
      mode = "n";
    }
    {
      key = "<C-d>";
      action = "<C-d>zz";
      mode = "n";
    }
    {
      key = "<C-u>";
      action = "<C-u>zz";
      mode = "n";
    }
    {
      key = "n";
      action = "nzzzv";
      mode = "n";
    }
    {
      key = "N";
      action = "Nzzzv";
      mode = "n";
    }
    {
      key = "<leader>lspr";
      action = "<cmd>LspRestart<cr>";
      mode = "n";
    }
    {
      key = "<leader>p";
      action = ''[["_dP]]'';
      mode = "x";
    }
    {
      key = "<leader>y";
      action = ''[["+y]]'';
      mode = [ "n" "v" ];
    }
    {
      key = "<leader>Y";
      action = ''[["+Y]]'';
      mode = "n";
    }
    {
      key = "<leader>d";
      action = ''[["_d]]'';
      mode = [ "n" "v" ];
    }
    {
      key = "Q";
      action = "<nop>";
      mode = "n";
    }
    {
      key = "==";
      action = "vim.lsp.buf.format";
      mode = "n";
    }
    {
      key = "<C-j>";
      action = "<cmd>cnext<cr>zz";
      mode = "n";
    }
    {
      key = "<C-k>";
      action = "<cmd>cprev<cr>zz";
      mode = "n";
    }
    {
      key = "<leader>k";
      action = "<cmd>lnext<cr>zz";
      mode = "n";
    }
    {
      key = "<leader>j";
      action = "<cmd>lprev<cr>zz";
      mode = "n";
    }
    {
      key = "<leader>s";
      action = "[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]";
      mode = "n";
    }
    {
      key = "<leader>x";
      action = "<cmd>!chmod +x %<CR>";
      mode = "n";
      options = { silent = true; };
    }
    {
      key = "<leader>ee";
      action = "oif err != nil {<CR>}<Esc>Oreturn err<Esc>";
      mode = "n";
    }
    {
      key = "<leader>spv";
      action = "<cmd>vsplit<CR><C-W>w";
      mode = "n"; 
    }
    {
      key = "<leader>sph";
      action = "<cmd>split<CR><C-W>w";
      mode = "n"; 
    }
    {
      key = "<leader>spc";
      action = "<C-W>q";
      mode = "n"; 
    }
    {
      key = "<leader>spn";
      action = "<C-W>w";
      mode = "n"; 
    }
    {
      key = "<leader>spN";
      action = "<C-W>W";
      mode = "n"; 
    }
    {
      key = "<leader><ESC>";
      action = "<C-\\><C-n>";
      mode = "t"; 
      options = { noremap = true; };
    }
    {
      key = "jl";
      action = "<ESC>";
      mode = "i";
      options = { noremap = true; };
    }
  ];
}
