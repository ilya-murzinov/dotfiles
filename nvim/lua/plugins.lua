-- Nvim-only plugins (not shared with vim)
-- These load via lazy.nvim after vimrc is sourced

return {
  -- vim-be-good: nvim-only plugin for practicing vim movements
  {
    "ThePrimeagen/vim-be-good",
    cmd = "VimBeGood", -- Load only when :VimBeGood is called
  },
}
