local eq = assert.are.same
local api = vim.api

describe('utils', function()
  local utils = require('lualine.utils.utils')

  it('can save and restore highlights', function()
    local hl1 = {'hl1', '#122233', '#445566', 'italic', true}
    utils.save_highlight(hl1[1], hl1)
    -- highlight loaded in loaded_highlights table
    eq(utils.loaded_highlights[hl1[1]], hl1)
    -- highlight exists works properly
    eq(utils.highlight_exists('hl1'), true)
    eq(utils.highlight_exists('hl2'), false)
    -- highlights can be restored
    -- hl doesn't exist
    assert.has_error(function() api.nvim_get_hl_by_name('hl1', true) end,
                     'Invalid highlight name: hl1')
    utils.reload_highlights()
    -- Now hl1 is created
    eq(api.nvim_get_hl_by_name('hl1', true), {
      foreground = tonumber(hl1[2]:sub(2, #hl1[2]), 16), -- convert rgb -> int
      background = tonumber(hl1[3]:sub(2, #hl1[3]), 16), -- convert rgb -> int
      italic = true
    })
    -- highlights can be cleared
    utils.clear_highlights()
    eq(utils.highlight_exists('hl1'), false)
    -- highlight group has been cleared
    eq(api.nvim_get_hl_by_name('hl1', true), {[true] = 6})
  end)

  it('can retrive highlight groups', function()
    local hl2 = {
      guifg = '#aabbcc',
      guibg = '#889977',
      ctermfg = 34,
      ctermbg = 89,
      reverse = true
    }
    -- handles non existing hl groups
    eq(utils.extract_highlight_colors('hl2'), nil)
    -- create highlight
    vim.cmd(string.format(
                'hi hl2 guifg=%s guibg=%s ctermfg=%d ctermbg=%d gui=reverse',
                hl2.guifg, hl2.guibg, hl2.ctermfg, hl2.ctermbg))
    -- Can retrive entire highlight table
    eq(utils.extract_highlight_colors('hl2'), hl2)
    -- Can retrive specific parts of highlight
    eq(utils.extract_highlight_colors('hl2', 'guifg'), hl2.guifg)
    -- clear hl2
    vim.cmd 'hi clear hl2'
  end)

  it('can shrink list with holes', function()
    local list_with_holes = {
      '2', '4', '6', nil, '43', nil, '2', '', 'a', '', 'b', ' '
    }
    local list_without_holes = {'2', '4', '6', '43', '2', 'a', 'b', ' '}
    eq(utils.list_shrink(list_with_holes), list_without_holes)
  end)
end)