local sorters = require('telescope.sorters')

return function(opts)
  opts = opts or {}
  local fzy = opts.fzy_mod or require "telescope.algos.fzy"
  local OFFSET = -fzy.get_score_floor()

  return sorters.Sorter:new {
    discard = true,

    scoring_function = function(_, prompt, line, entry)
      -- Check for actual matches before running the scoring alogrithm.
      if not fzy.has_match(prompt, line) then
        return -1
      end

      local fzy_score = fzy.score(prompt, line)

      -- The fzy score is -inf for empty queries and overlong strings.  Since
      -- this function converts all scores into the range (0, 1), we can
      -- convert these to 1 as a suitable "worst score" value.
      if fzy_score == fzy.get_score_min() then
        return 1
      end

      -- Prioritise commands over history
      if entry.type == "command" then
        return 1 / ((fzy_score + OFFSET) * 1.15)
      end

      -- Poor non-empty matches can also have negative values. Offset the score
      -- so that all values are positive, then invert to match the
      -- telescope.Sorter "smaller is better" convention. Note that for exact
      -- matches, fzy returns +inf, which when inverted becomes 0.
      return 1 / (fzy_score + OFFSET)
    end,

    -- The fzy.positions function, which returns an array of string indices, is
    -- compatible with telescope's conventions. It's moderately wasteful to
    -- call call fzy.score(x,y) followed by fzy.positions(x,y): both call the
    -- fzy.compute function, which does all the work. But, this doesn't affect
    -- perceived performance.
    highlighter = function(_, prompt, display)
      return fzy.positions(prompt, display)
    end,
  }
end
