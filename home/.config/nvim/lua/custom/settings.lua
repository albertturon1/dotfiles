vim.o.termguicolors = true
vim.opt.fillchars:append { eob = ' ' }
vim.g.have_nerd_font = true
vim.o.relativenumber = true

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = false,
  virtual_lines = true,
  jump = { float = true },
}
