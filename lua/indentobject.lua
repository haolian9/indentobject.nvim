-- design choices
-- * not work on top level
-- * ignore indent=0 when searching next/prev line
-- * ignore blank lines in the top and bottom of the range

local cthulhu = require("cthulhu")
local vsel = require("infra.vsel")
local jelly = require("infra.jellyfish")("indentobject", vim.log.levels.DEBUG)
local jumplist = require("infra.jumplist")

local api = vim.api

return function()
  local winid = api.nvim_get_current_win()
  local bufnr = api.nvim_win_get_buf(winid)
  local curow = api.nvim_win_get_cursor(winid)[1]
  local nsp = vim.fn.indent(curow)
  if nsp == 0 then return jelly.err("refuse to work on top indent level") end

  local maxrow = api.nvim_buf_line_count(bufnr)

  local toprow
  for i = curow, 1, -1 do
    local insp = vim.fn.indent(i)
    if insp == 0 then
      if not cthulhu.nvim.is_empty_line(bufnr, i - 1) then break end
      -- skip blank line
    elseif insp < nsp then
      break
    else
      toprow = i
    end
  end

  local botrow
  for i = curow, maxrow do
    local insp = vim.fn.indent(i)
    if insp == 0 then
      if not cthulhu.nvim.is_empty_line(bufnr, i - 1) then break end
      -- skip blank line
    elseif insp < nsp then
      break
    else
      botrow = i
    end
  end

  jelly.debug("curow=%d, nsp=%d, rowrange=%d-%d", curow, nsp, toprow, botrow)
  jumplist.push_here()
  vsel.select_lines(toprow - 1, botrow - 1 + 1)
end
