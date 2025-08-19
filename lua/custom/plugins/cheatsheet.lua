-- Custom cheatsheet functionality
return {
  -- This creates a "virtual" plugin that just sets up keymaps
  {
    "cheatsheet",
    dir = vim.fn.stdpath("config"), -- Use config directory as plugin source
    name = "cheatsheet",
    config = function()
      -- Path to the cheatsheet file
      local cheatsheet_path = vim.fn.stdpath 'config' .. '/vim_cheatsheet.md'

      -- Quick open cheatsheet in a split
      local function open_cheatsheet()
        vim.cmd('vsplit ' .. cheatsheet_path)
      end

      -- Quick open cheatsheet in current buffer
      local function edit_cheatsheet()
        vim.cmd('edit ' .. cheatsheet_path)
      end

      -- Search through cheatsheet with Telescope
      local function search_cheatsheet()
        require('telescope.builtin').live_grep {
          search_dirs = { cheatsheet_path },
          prompt_title = 'Search Cheatsheet',
        }
      end

      -- Setup keymaps
      vim.keymap.set('n', '<leader>cc', open_cheatsheet, { desc = '[C]heatsheet [C]open' })
      vim.keymap.set('n', '<leader>ce', edit_cheatsheet, { desc = '[C]heatsheet [E]dit' })
      vim.keymap.set('n', '<leader>cs', search_cheatsheet, { desc = '[C]heatsheet [S]earch' })
    end,
  },
}
