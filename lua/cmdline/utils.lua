local M = {}

-- Utility function to merge results and deduplicate from history
-- @param table1 table: first table
-- @param table2 table: second table
M.merge_results = function(table1, table2)
  for _, v in ipairs(table2) do
    table.insert(table1, v)
  end

  local seen = {}
  for index, item in ipairs(table1) do
    if seen[item.cmd] then
      table.remove(table1, index)
    else
      seen[item.cmd] = true
    end
  end
  return table1
end

return M
