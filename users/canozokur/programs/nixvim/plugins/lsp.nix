{ lib, config, ... }:
{
  plugins.luasnip.enable = true;

  plugins.lsp = {
    enable = true;
    servers = {
      pyright.enable = true;
      ruff.enable = true;
      nixd.enable = true;
      helm_ls.enable = true;
      clangd.enable = true;
      eslint.enable = true;
      ts_ls.enable = true;
      yamlls.enable = true;
      gopls.enable = true;
      lua_ls = {
        enable = true;
        settings = {
          Lua = {
            diagnostics = {
              globals = [ "vim" ];
            };
          };
        };
      };
    };

    keymaps = {
      diagnostic = {
        "<leader>gn" = "goto_next";
        "<leader>vd" = "open_float";
        "<leader>fe" = "setqflist";
      };

      lspBuf = {
        "gd" = "definition";
        "<leader>ws" = "workspace_symbol";
        "<leader>rr" = "references";
        "<leader>rn" = "rename";
        "<C-h>" = "signature_help";
      } // lib.optionalAttrs (!config.plugins.actions-preview.enable) {
        "<leader>ca" = "code_action";
      };

      extra = [
        {
          mode = "n";
          key = "K";
          options.desc = "Lsp hover (gopls: with referenced types)";
          action.__raw = ''
            function()
              local client = vim.lsp.get_clients({ bufnr = 0, name = "gopls" })[1]
              if not client then
                return vim.lsp.buf.hover()
              end

              local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
              local function text(hover)
                return hover and hover.contents and vim.trim(hover.contents.value or "") or ""
              end

              client:request("textDocument/hover", params, function(_, main)
                local sections = { text(main) }
                local function show()
                  local body = table.concat(vim.tbl_filter(function(s) return s ~= "" end, sections), "\n\n---\n\n")
                  if body == "" then
                    return vim.notify("No information available", vim.log.levels.INFO)
                  end
                  vim.lsp.util.open_floating_preview(vim.split(body, "\n"), "markdown", { focus_id = "gopls_deep_hover" })
                end

                -- gopls' typeDefinition rejects composite types like map[K]*V, so read the
                -- declaration's type expression with tree-sitter and hover each named type in it.
                client:request("textDocument/definition", params, function(err, locs)
                  if err or not locs then
                    return show()
                  end
                  local loc = (locs.uri or locs.targetUri) and locs or locs[1]
                  if not loc then
                    return show()
                  end

                  local uri = loc.uri or loc.targetUri
                  local pos = (loc.range or loc.targetSelectionRange).start
                  local buf = vim.uri_to_bufnr(uri)
                  vim.fn.bufload(buf)
                  local ok, parser = pcall(vim.treesitter.get_parser, buf, "go")
                  if not ok or not parser then
                    return show()
                  end

                  local function line_at(row)
                    return vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
                  end
                  local col = vim.str_byteindex(line_at(pos.line), client.offset_encoding, pos.character, false)
                  local node = parser:parse()[1]:root():named_descendant_for_range(pos.line, col, pos.line, col)
                  local decls = {
                    field_declaration = true,
                    var_spec = true,
                    const_spec = true,
                    parameter_declaration = true,
                    variadic_parameter_declaration = true,
                  }
                  while node and not decls[node:type()] do
                    node = node:parent()
                  end
                  local type_node = node and node:field("type")[1]
                  if not type_node then
                    return show()
                  end

                  local predeclared = {}
                  for _, name in ipairs({
                    "any", "bool", "byte", "comparable", "complex64", "complex128", "error",
                    "float32", "float64", "int", "int8", "int16", "int32", "int64", "rune",
                    "string", "uint", "uint8", "uint16", "uint32", "uint64", "uintptr",
                  }) do
                    predeclared[name] = true
                  end

                  local seen, targets = {}, {}
                  local query = vim.treesitter.query.parse("go", "(type_identifier) @type")
                  for _, id in query:iter_captures(type_node, buf) do
                    local name = vim.treesitter.get_node_text(id, buf)
                    if not predeclared[name] and not seen[name] then
                      seen[name] = true
                      local row, byte = id:start()
                      table.insert(targets, {
                        textDocument = { uri = uri },
                        position = { line = row, character = vim.str_utfindex(line_at(row), client.offset_encoding, byte, false) },
                      })
                    end
                  end

                  -- Slots keep the popup in source order regardless of response order.
                  local results, pending = {}, #targets
                  if pending == 0 then
                    return show()
                  end
                  for i, target in ipairs(targets) do
                    client:request("textDocument/hover", target, function(_, hover)
                      results[i] = text(hover)
                      pending = pending - 1
                      if pending == 0 then
                        for j = 1, #targets do
                          if results[j] ~= sections[1] then
                            table.insert(sections, results[j])
                          end
                        end
                        show()
                      end
                    end, 0)
                  end
                end, 0)
              end, 0)
            end
          '';
        }
      ];
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "gr";
      action = "<cmd>Telescope lsp_references<cr>";
      options.desc = "Telescope LSP References";
    }
    {
      mode = "n";
      key = "gi";
      action = "<cmd>Telescope lsp_implementations<cr>";
      options.desc = "Telescope LSP Implementations";
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "==";
      action = "<cmd>lua vim.lsp.buf.format({async = true})<cr>";
      options.desc = "Format buffer (LSP)";
    }
  ];
}
