local function gh(repo) return 'https://github.com/' .. repo end

vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('custom-markdown-preview-build', { clear = true }),
  callback = function(event)
    if event.data.kind ~= 'install' or event.data.spec.name ~= 'markdown-preview.nvim' then return end
    vim.system({ 'sh', '-c', 'cd app && npm install' }, { cwd = event.data.path }, function(result)
      if result.code ~= 0 then vim.schedule(function() vim.notify(result.stderr, vim.log.levels.ERROR) end) end
    end)
  end,
})

vim.pack.add {
  gh 'stevearc/oil.nvim',
  gh 'akinsho/bufferline.nvim',
  gh 'nickjvandyke/opencode.nvim',
  gh 'folke/snacks.nvim',
  gh 'nvim-lualine/lualine.nvim',
  gh 'f-person/git-blame.nvim',
  gh 'iamcco/markdown-preview.nvim',
  gh 'MeanderingProgrammer/render-markdown.nvim',
  gh 'kdheepak/lazygit.nvim',
  gh 'nvim-telescope/telescope-live-grep-args.nvim',
  gh 'savq/melange-nvim',
  gh 'cormacrelf/dark-notify',
}

require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()

require('oil').setup {
  view_options = { show_hidden = true },
  keymaps = {
    ['<C-p>'] = false,
    ['<C-;>'] = 'actions.preview',
  },
}

require('bufferline').setup {
  options = {
    style_preset = { require('bufferline').style_preset.no_italic },
    diagnostics = 'nvim_lsp',
    diagnostics_update_on_event = true,
    close_command = require('custom.buffers').close,
    right_mouse_command = require('custom.buffers').close,
    indicator = { style = 'icon', icon = '▎' },
    diagnostics_indicator = function(_, _, diagnostics)
      local errors = diagnostics.error or 0
      local warnings = diagnostics.warning or 0
      local parts = {}
      if errors > 0 then parts[#parts + 1] = ' ' .. errors end
      if warnings > 0 then parts[#parts + 1] = ' ' .. warnings end
      return #parts == 0 and '' or ' ' .. table.concat(parts, ' ')
    end,
    offsets = { { filetype = 'oil', text = 'Explorer', text_align = 'left' } },
    separator_style = 'slant',
    always_show_bufferline = true,
  },
}

vim.g.opencode_opts = {}
local opencode = require 'opencode'
vim.keymap.set({ 'n', 'x' }, '<leader>oa', function() opencode.ask('@this: ', { submit = true }) end, { desc = 'OpenCode: ask' })
vim.keymap.set({ 'n', 'x' }, '<leader>on', function()
  vim.ui.input({ prompt = 'Note: ' }, function(input)
    if input and input ~= '' then opencode.prompt(input, { submit = true }) end
  end)
end, { desc = 'OpenCode: note' })
vim.keymap.set({ 'n', 'x' }, '<leader>ox', opencode.select, { desc = 'OpenCode: select' })
vim.keymap.set('n', '<leader>os', function() opencode.command 'prompt.submit' end, { desc = 'OpenCode: submit' })
vim.keymap.set('n', '<leader>oc', function() opencode.command 'prompt.clear' end, { desc = 'OpenCode: clear' })
vim.keymap.set({ 'n', 'x' }, 'go', function() return opencode.operator '@this ' end, { desc = 'OpenCode: operator range', expr = true })
vim.keymap.set('n', 'goo', function() return opencode.operator '@this ' .. '_' end, { desc = 'OpenCode: operator line', expr = true })
vim.keymap.set('n', '<S-C-u>', function() opencode.command 'session.half.page.up' end, { desc = 'OpenCode: scroll up' })
vim.keymap.set('n', '<S-C-d>', function() opencode.command 'session.half.page.down' end, { desc = 'OpenCode: scroll down' })

require('lualine').setup {
  sections = {
    lualine_z = { function() return opencode.statusline() end },
  },
}

require('gitblame').setup {
  enabled = false,
  message_template = '<summary> • <author> • <date> • <<sha>>',
  date_format = '%m.%d.%Y %H:%M:%S',
  virtual_text_column = 1,
}

require('render-markdown').setup {}
vim.g.lazygit_floating_window_scaling_factor = 1
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<CR>', { desc = 'LazyGit' })

local lga_actions = require 'telescope-live-grep-args.actions'
require('telescope').setup {
  defaults = {
    layout_strategy = 'flex',
    sorting_strategy = 'ascending',
    layout_config = {
      horizontal = { prompt_position = 'top', height = { padding = 0 }, width = { padding = 0 }, preview_width = 0.5 },
      vertical = { prompt_position = 'top', height = { padding = 0 }, width = { padding = 0 }, preview_height = 0.55, mirror = true },
      flex = { flip_columns = 150 },
    },
    mappings = {
      i = { ['<c-enter>'] = 'to_fuzzy_refine', ['<c-d>'] = require('telescope.actions').delete_buffer },
      n = { dd = require('telescope.actions').delete_buffer, ['<c-d>'] = require('telescope.actions').delete_buffer },
    },
  },
  pickers = {
    find_files = { find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/*' } },
  },
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
    live_grep_args = {
      auto_quoting = true,
      mappings = { i = { ['<C-k>'] = lga_actions.quote_prompt() } },
    },
  },
}
require('telescope').load_extension 'live_grep_args'
local telescope = require 'telescope.builtin'
vim.keymap.set('n', '<C-p>', telescope.find_files, { desc = 'Search files' })
vim.keymap.set(
  'n',
  '<leader>sg',
  function() require('telescope').extensions.live_grep_args.live_grep_args { additional_args = { '--fixed-strings' } } end,
  { desc = 'Search by grep' }
)
vim.keymap.set('n', '<leader><leader>', function() telescope.buffers { sort_mru = true, sort_lastused = true } end, { desc = 'Find buffers' })

require('dark_notify').run {
  onchange = function(mode)
    vim.o.background = mode == 'dark' and 'dark' or 'light'
    vim.cmd.colorscheme 'melange'
  end,
}
vim.cmd.colorscheme 'melange'
