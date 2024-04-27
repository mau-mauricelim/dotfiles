-- Config with onedark.nvim colors
local status_ok, palette = pcall(require, 'onedark.palette')
if status_ok then
  local colors = palette[vim.g.onedark_config.style]
  return colors
end