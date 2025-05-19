local M = {}

function M.ismac()
  if vim.fn.has("mac") == 1 then
    return true
  end
  return false
end

return M
