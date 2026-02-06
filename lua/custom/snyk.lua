local M = {}

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
  vim.defer_fn(function()
    vim.fn.system "pkill -f 'snyk'"
  end, 100)
  vim.notify('Snyk LSP disabled', vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('SnykToggle', function()
  if vim.g.snyk_enabled == false then
    enable_snyk()
  else
    disable_snyk()
  end
end, { desc = 'Toggle Snyk LSP' })

local function prompt_snyk_choice()
  if #vim.api.nvim_list_uis() == 0 then
    vim.g.snyk_enabled = false
    return
  end

  local lines = {
    'Enable Snyk LSP?',
    '',
    'Yes, enable Snyk',
    'No, keep disabled (default)',
    '',
    'Use arrows to select, Enter to confirm',
  }

  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, #line)
  end

  local ui = vim.api.nvim_list_uis()[1]
  width = math.min(math.max(width, 40), math.max(ui.width - 4, 40))
  local height = #lines
  local row = math.max(ui.height - height - 2, 0)
  local col = math.max(math.floor((ui.width - width) / 2), 0)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    focusable = true,
    zindex = 50,
  })

  vim.api.nvim_win_set_option(win, 'cursorline', true)
  vim.api.nvim_win_set_option(win, 'wrap', false)

  vim.g.snyk_prompt_active = true
  local group = vim.api.nvim_create_augroup('SnykPromptFocus', { clear = true })
  vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter', 'WinLeave', 'BufLeave', 'FocusGained' }, {
    group = group,
    callback = function()
      if vim.g.snyk_prompt_active and vim.api.nvim_win_is_valid(win) then
        if vim.api.nvim_get_current_win() ~= win then
          vim.api.nvim_set_current_win(win)
        end
      end
    end,
  })

  local choice_index = 2
  local option_rows = { 3, 4 }

  local function update_cursor()
    vim.api.nvim_win_set_cursor(win, { option_rows[choice_index], 0 })
  end

  update_cursor()

  vim.schedule(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_set_current_win(win)
    end
  end)

  local function choose(enable)
    vim.g.snyk_prompt_active = false
    pcall(vim.api.nvim_del_augroup_by_id, group)
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if enable then
      setup_snyk()
      vim.g.snyk_enabled = true
      vim.notify('Snyk LSP enabled', vim.log.levels.INFO)
    else
      vim.g.snyk_enabled = false
      vim.notify('Snyk LSP disabled (use :SnykToggle to enable)', vim.log.levels.INFO)
    end
  end

  local function map(lhs, fn)
    vim.keymap.set('n', lhs, fn, { buffer = buf, nowait = true, silent = true })
  end

  local function toggle_choice()
    choice_index = choice_index == 1 and 2 or 1
    update_cursor()
  end

  map('<Up>', toggle_choice)
  map('<Down>', toggle_choice)
  map('<Left>', toggle_choice)
  map('<Right>', toggle_choice)
  map('k', toggle_choice)
  map('j', toggle_choice)
  map('<CR>', function()
    choose(choice_index == 1)
  end)
  map('y', function()
    choose(true)
  end)
  map('Y', function()
    choose(true)
  end)
  map('n', function()
    choose(false)
  end)
  map('N', function()
    choose(false)
  end)
  map('<Esc>', function()
    choose(false)
  end)
end

function M.setup()
  if vim.g.snyk_enabled == false then
    return
  end

  prompt_snyk_choice()
end

return M
