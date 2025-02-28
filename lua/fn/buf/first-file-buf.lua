return function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name ~= "" and buf_name ~= "[No Name]" then
      return buf
    end
  end
  return nil  -- No file buffers found
end
