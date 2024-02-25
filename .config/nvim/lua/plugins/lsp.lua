return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'j-hui/fidget.nvim',
  },

  config = function()
    local cmp = require('cmp')
    local cmp_lsp = require('cmp_nvim_lsp')
    local capabilities = vim.tbl_deep_extend(
      'force',
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities())

    require('fidget').setup({})
    require('mason').setup()
    require('mason-lspconfig').setup({
      ensure_installed = {
        'lua_ls',
        'rust_analyzer',
        'tsserver',
      },
      handlers = {
        function(server_name) -- default handler (optional)
          require('lspconfig')[server_name].setup {
            capabilities = capabilities
          }
        end,

        ['lua_ls'] = function()
          local lspconfig = require('lspconfig')
          lspconfig.lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = {
                  globals = { 'vim', 'it', 'describe', 'before_each', 'after_each' },
                }
              }
            }
          }
        end,
      }
    })

    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- For luasnip users.
      }, {
        { name = 'buffer' },
      })
    })

    vim.diagnostic.config({
      -- update_in_insert = true,
      float = {
        focusable = false,
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
      },
    })

    -- Formatting
    -- START COPYPASTA https://github.com/neovim/neovim/commit/5b04e46d23b65413d934d812d61d8720b815eb1c
    local util = require 'vim.lsp.util'
    --- Formats a buffer using the attached (and optionally filtered) language
    --- server clients.
    ---
    --- @param options table|nil Optional table which holds the following optional fields:
    ---     - formatting_options (table|nil):
    ---         Can be used to specify FormattingOptions. Some unspecified options will be
    ---         automatically derived from the current Neovim options.
    ---         @see https://microsoft.github.io/language-server-protocol/specification#textDocument_formatting
    ---     - timeout_ms (integer|nil, default 1000):
    ---         Time in milliseconds to block for formatting requests. Formatting requests are current
    ---         synchronous to prevent editing of the buffer.
    ---     - bufnr (number|nil):
    ---         Restrict formatting to the clients attached to the given buffer, defaults to the current
    ---         buffer (0).
    ---     - filter (function|nil):
    ---         Predicate to filter clients used for formatting. Receives the list of clients attached
    ---         to bufnr as the argument and must return the list of clients on which to request
    ---         formatting. Example:
    ---
    ---         <pre>
    ---         -- Never request typescript-language-server for formatting
    ---         vim.lsp.buf.format {
    ---           filter = function(clients)
    ---             return vim.tbl_filter(
    ---               function(client) return client.name ~= "tsserver" end,
    ---               clients
    ---             )
    ---           end
    ---         }
    ---         </pre>
    ---
    ---     - id (number|nil):
    ---         Restrict formatting to the client with ID (client.id) matching this field.
    ---     - name (string|nil):
    ---         Restrict formatting to the client with name (client.name) matching this field.
    vim.lsp.buf.format = function(options)
      options = options or {}
      local bufnr = options.bufnr or vim.api.nvim_get_current_buf()
      local clients = vim.lsp.buf_get_clients(bufnr)

      if options.filter then
        clients = options.filter(clients)
      elseif options.id then
        clients = vim.tbl_filter(
          function(client) return client.id == options.id end,
          clients
        )
      elseif options.name then
        clients = vim.tbl_filter(
          function(client) return client.name == options.name end,
          clients
        )
      end

      clients = vim.tbl_filter(
        function(client) return client.supports_method 'textDocument/formatting' end,
        clients
      )

      if #clients == 0 then
        vim.notify '[LSP] Format request failed, no matching language servers.'
      end

      local timeout_ms = options.timeout_ms or 1000
      for _, client in pairs(clients) do
        local params = util.make_formatting_params(options.formatting_options)
        local result, err = client.request_sync('textDocument/formatting', params, timeout_ms, bufnr)
        if result and result.result then
          util.apply_text_edits(result.result, bufnr, client.offset_encoding)
        elseif err then
          vim.notify(string.format('[LSP][%s] %s', client.name, err), vim.log.levels.WARN)
        end
      end
    end
    -- END COPYPASTA


    vim.api.nvim_create_augroup('LspFormatting', { clear = true })
    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = '*',
      group = 'LspFormatting',
      callback = function()
        vim.lsp.buf.format {
          timeout_ms = 2000,
          filter = function(clients)
            return vim.tbl_filter(function(client)
              return pcall(function(_client)
                return _client.config.settings.autoFixOnSave or false
              end, client) or false
            end, clients)
          end
        }
      end
    })

    -- disable inline diagnostic
    -- vim.diagnostic.config({virtual_text = false})

    local registry = require('mason-registry')
    registry.refresh()

    registry.update()
  end
}
