local function setup_snyk()
  if vim.g.snyk_setup_done then
    return
  end

  vim.g.snyk_setup_done = true

  local lspconfig = require 'lspconfig'
  local configs = require 'lspconfig.configs'

  if not configs.snyk then
    local log_path = vim.fn.stdpath 'cache' .. '/snyk-ls.log'
    local init_options = {
      activateSnykCode = 'true',
    }

    if vim.env.SNYK_TOKEN and vim.env.SNYK_TOKEN ~= '' then
      init_options.token = vim.env.SNYK_TOKEN
    else
      vim.schedule(function()
        vim.notify('Snyk LSP: set SNYK_TOKEN env var for auth', vim.log.levels.WARN)
      end)
    end

    configs.snyk = {
      default_config = {
        cmd = { 'snyk', 'language-server', '-f', log_path },
        root_dir = function(fname)
          return lspconfig.util.find_git_ancestor(fname) or vim.loop.os_homedir()
        end,
        init_options = init_options,
      },
    }
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp, cmp = pcall(require, 'cmp_nvim_lsp')
  if ok_cmp then
    capabilities = vim.tbl_deep_extend('force', capabilities, cmp.default_capabilities())
  end

  lspconfig.snyk.setup {
    capabilities = capabilities,
  }
end

local function enable_snyk()
  vim.g.snyk_enabled = true
  setup_snyk()

  local lspconfig = require 'lspconfig'
  local manager = lspconfig.snyk.manager
  if manager and manager.try_add_wrapper then
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        manager.try_add_wrapper(bufnr)
      end
    end
  else
    vim.notify('Snyk LSP enabled (restart Neovim to attach)', vim.log.levels.INFO)
    return
  end

  vim.notify('Snyk LSP enabled', vim.log.levels.INFO)
end

local function disable_snyk()
  vim.g.snyk_enabled = false
  for _, client in ipairs(vim.lsp.get_clients { name = 'snyk' }) do
    client.stop()
  end
  vim.notify('Snyk LSP disabled', vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('SnykToggle', function()
  if vim.g.snyk_enabled == false then
    enable_snyk()
  else
    disable_snyk()
  end
end, { desc = 'Toggle Snyk LSP' })

return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      if vim.g.snyk_enabled == false then
        return
      end
      setup_snyk()
    end,
  },
}
