return {
  {
    'opencode',
    dir = vim.fn.stdpath 'config',
    name = 'opencode',
    config = function()
      local opencode = require 'custom.opencode'

      opencode.setup()

      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add({
          { '<leader>o', group = 'Opencode', mode = { 'n', 'v' } },
        })
      end

      vim.keymap.set({ 'n', 'v' }, '<leader>ocp', function()
        if opencode.is_opencode_buffer(vim.api.nvim_get_current_buf()) then
          opencode.run_followup 'plan'
        else
          opencode.run 'plan'
        end
      end, { desc = 'Opencode prompt (plan)' })

      vim.keymap.set({ 'n', 'v' }, '<leader>ocb', function()
        if opencode.is_opencode_buffer(vim.api.nvim_get_current_buf()) then
          opencode.run_followup 'build'
        else
          opencode.run 'build'
        end
      end, { desc = 'Opencode prompt (build)' })

      vim.keymap.set('n', '<leader>oca', function()
        opencode.apply_last_diff()
      end, { desc = 'Opencode apply last diff' })
    end,
  },
}
