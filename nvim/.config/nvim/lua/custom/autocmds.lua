vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Restore cursor position from the previous editing session',
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      vim.api.nvim_win_set_cursor(0, mark)
      vim.schedule(function() vim.cmd 'normal! zz' end)
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', { pattern = 'help', command = 'wincmd L' })
vim.api.nvim_create_autocmd('VimResized', { command = 'wincmd =' })
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('custom-no-auto-comment', { clear = true }),
  callback = function() vim.opt_local.formatoptions:remove { 'c', 'r', 'o' } end,
})
vim.api.nvim_create_autocmd('BufRead', {
  group = vim.api.nvim_create_augroup('custom-dotenv-filetype', { clear = true }),
  pattern = { '.env', '.env.*' },
  callback = function() vim.bo.filetype = 'dosini' end,
})
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('custom-active-cursorline', { clear = true }),
  callback = function() vim.opt_local.cursorline = true end,
})
vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
  group = 'custom-active-cursorline',
  callback = function() vim.opt_local.cursorline = false end,
})

vim.o.autoread = true
vim.api.nvim_create_autocmd({ 'CursorHold', 'FocusGained', 'BufEnter' }, {
  callback = function()
    if vim.bo.buftype == '' then vim.cmd.checktime() end
  end,
})
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  group = vim.api.nvim_create_augroup('custom-autoread-notification', { clear = true }),
  callback = function()
    if vim.bo.modified then vim.notify('File changed on disk while this buffer has unsaved changes. Use :DiffOrig to review it.', vim.log.levels.WARN) end
  end,
})

vim.api.nvim_create_user_command('DiffOrig', function()
  vim.cmd 'vert new | set buftype=nofile | read ++edit # | 0d_'
  vim.cmd 'diffthis | wincmd p | diffthis'
end, {})
