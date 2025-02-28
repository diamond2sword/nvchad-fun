return function(buf)
  local win_list = vim.api.nvim_list_wins()
  for _, win in ipairs(win_list) do
    local win_buf = vim.api.nvim_win_get_buf(win)
    if win_buf == buf then
      return win
    end
  end
  return nil
end
