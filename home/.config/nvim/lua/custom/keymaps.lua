local buffers = require 'custom.buffers'

vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment under cursor' })
vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement under cursor' })

vim.keymap.set('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>]', '<cmd>bnext<CR>', { desc = 'Buffer next' })
vim.keymap.set('n', '<leader>[', '<cmd>bprevious<CR>', { desc = 'Buffer previous' })
vim.keymap.set('n', '<leader>c', buffers.close, { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>C', buffers.reopen_last_closed, { desc = 'Reopen last closed buffer' })

vim.keymap.set('n', ';', '<CR>')
vim.keymap.set('n', '<leader>w', '<cmd>update<CR>', { desc = '[W]rite' })
vim.keymap.set('n', '<leader>W', '<cmd>wall<CR>', { desc = 'Write [A]ll' })
vim.keymap.set('n', '<leader>x', '<cmd>x<CR>', { desc = 'Save and e[X]it' })
vim.keymap.set('n', '<leader>Q', '<cmd>qa<CR>', { desc = '[Q]uit all' })
vim.keymap.set('n', '<leader>X', function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then vim.api.nvim_buf_delete(buf, {}) end
  end
end, { desc = 'Close all other buffers' })

vim.keymap.set('n', '<leader>e', function()
  if vim.api.nvim_buf_get_name(0):match '^oil://' then
    vim.cmd.bdelete()
  else
    require('oil').open()
  end
end, { desc = 'Explorer toggle' })
vim.keymap.set('n', '<leader>E', function() require('oil').toggle_float() end, { desc = 'Explorer floating window' })
vim.keymap.set('n', '<leader>a', 'ggVG', { desc = 'Select [A]ll' })
vim.keymap.set('n', '<leader>Y', '<cmd>%y+<CR>', { desc = 'Yank whole buffer' })
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
