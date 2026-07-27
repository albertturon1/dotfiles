local M = {}

local closed_file_history = {}

local function is_listed_file_buffer(bufnr)
  return bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == '' and vim.api.nvim_buf_get_name(bufnr) ~= ''
end

local function reopenable_path(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= '' then return nil end

  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == '' or vim.fn.filereadable(path) ~= 1 then return nil end

  return vim.fn.fnamemodify(path, ':p')
end

local function fallback_buffer(bufnr)
  local alternate = vim.fn.bufnr '#'
  if is_listed_file_buffer(alternate) and alternate ~= bufnr then return alternate end

  local listed = vim.fn.getbufinfo { buflisted = 1 }
  table.sort(listed, function(a, b) return (a.lastused or 0) > (b.lastused or 0) end)
  for _, info in ipairs(listed) do
    if info.bufnr ~= bufnr and is_listed_file_buffer(info.bufnr) then return info.bufnr end
  end
end

local function remember(path)
  if not path or path == '' then return end

  for index, item in ipairs(closed_file_history) do
    if item == path then
      table.remove(closed_file_history, index)
      break
    end
  end

  table.insert(closed_file_history, 1, path)
  if #closed_file_history > 20 then table.remove(closed_file_history) end
end

function M.close(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr].buflisted then return end

  local path = reopenable_path(bufnr)
  if bufnr == vim.api.nvim_get_current_buf() then
    local fallback = fallback_buffer(bufnr)
    if fallback then vim.api.nvim_set_current_buf(fallback) end
  end

  local ok, err = pcall(vim.api.nvim_buf_delete, bufnr, {})
  if not ok then
    local message = tostring(err)
    if not message:match 'E89' and not message:match 'No write since last change' then vim.notify(message, vim.log.levels.WARN) end
    return
  end

  remember(path)
end

function M.reopen_last_closed()
  while #closed_file_history > 0 do
    local path = table.remove(closed_file_history, 1)
    if vim.fn.filereadable(path) == 1 then
      vim.cmd.edit(vim.fn.fnameescape(path))
      return
    end
  end

  vim.notify('No recently closed file buffer', vim.log.levels.INFO)
end

return M
