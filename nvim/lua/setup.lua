-- Configuration for vim-plug-installed lua plugins.
-- Called from init.lua after vimrc (and vim-plug) has been sourced.
-- Each block is guarded with pcall so a missing plugin never crashes startup.
--

-- Darken diff highlights so the cursor (#f5e0dc) remains visible against them
local function apply_diff_highlights()
  vim.api.nvim_set_hl(0, "DiffChange", { bg = "#3d3800" })
  vim.api.nvim_set_hl(0, "DiffText",   { bg = "#524d00", bold = true })
end
apply_diff_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = apply_diff_highlights,
})

local function setup(name, fn)
  local ok, mod = pcall(require, name)
  if ok then fn(mod) end
end

-- which-key
setup("which-key", function(wk)
  wk.setup({
    delay = 300,
    preset = false,
    triggers = {
      { '"', mode = { "n", "v" } },
      { "'", mode = { "n", "v", "o" } },
      { "`", mode = { "n", "v", "o" } },
    },
  })
  wk.add({
    { "<leader>?", function() wk.show({ global = true }) end, desc = "All keybindings" },
  })
end)

-- telescope
setup("telescope", function(ts)
  ts.setup({})
  local b = require("telescope.builtin")
  vim.keymap.set("n", "<leader>ff", b.find_files,  { desc = "Find files" })
  vim.keymap.set("n", "<leader>fg", b.git_files,   { desc = "Git files" })
  vim.keymap.set("n", "<leader>fr", b.oldfiles,    { desc = "Recent files" })
  vim.keymap.set("n", "<leader>fb", b.buffers,     { desc = "Buffers" })
  vim.keymap.set("n", "<leader>sg", b.live_grep,   { desc = "Live grep" })
  vim.keymap.set("n", "<leader>sw", b.grep_string, { desc = "Grep word" })
end)

-- diffview
setup("diffview", function(dv)
  local actions = require("diffview.actions")
  dv.setup({
    view = {
      default = {
        layout = "diff2_horizontal",
      },
    },
    file_panel = {
      win_config = {
        position = "top",
        height = 12,
      },
    },
    keymaps = {
      diff1 = {
        { "n", "n",   actions.next_conflict,         { desc = "Next change" } },
        { "n", "N",   actions.prev_conflict,         { desc = "Prev change" } },
        { "n", "L",  actions.select_next_entry,     { desc = "Next file" } },
        { "n", "H",  actions.select_prev_entry,     { desc = "Prev file" } },
        { "n", "J",  actions.select_next_entry,     { desc = "Next file" } },
        { "n", "K",  actions.select_prev_entry,     { desc = "Prev file" } },
      },
      diff2 = {
        { "n", "n",  function() vim.cmd("norm! ]c") end, { desc = "Next change" } },
        { "n", "N",  function() vim.cmd("norm! [c") end, { desc = "Prev change" } },
        { "n", "L",  actions.select_next_entry,     { desc = "Next file" } },
        { "n", "H",  actions.select_prev_entry,     { desc = "Prev file" } },
        { "n", "J",  actions.select_next_entry,     { desc = "Next file" } },
        { "n", "K",  actions.select_prev_entry,     { desc = "Prev file" } },
      },
      diff3 = {
        { "n", "n",  function() vim.cmd("norm! ]c") end, { desc = "Next change" } },
        { "n", "N",  function() vim.cmd("norm! [c") end, { desc = "Prev change" } },
        { "n", "L",  actions.select_next_entry,     { desc = "Next file" } },
        { "n", "H",  actions.select_prev_entry,     { desc = "Prev file" } },
        { "n", "J",  actions.select_next_entry,     { desc = "Next file" } },
        { "n", "K",  actions.select_prev_entry,     { desc = "Prev file" } },
      },
      diff4 = {
        { "n", "n",  function() vim.cmd("norm! ]c") end, { desc = "Next change" } },
        { "n", "N",  function() vim.cmd("norm! [c") end, { desc = "Prev change" } },
        { "n", "L",  actions.select_next_entry,     { desc = "Next file" } },
        { "n", "H",  actions.select_prev_entry,     { desc = "Prev file" } },
        { "n", "J",  actions.select_next_entry,     { desc = "Next file" } },
        { "n", "K",  actions.select_prev_entry,     { desc = "Prev file" } },
      },
      file_panel = {
        { "n", "L",  actions.select_next_entry,     { desc = "Next file" } },
        { "n", "H",  actions.select_prev_entry,     { desc = "Prev file" } },
        { "n", "J",  actions.select_next_entry,     { desc = "Next file" } },
        { "n", "K",  actions.select_prev_entry,     { desc = "Prev file" } },
      },
      file_history_panel = {
        { "n", "L",  actions.select_next_entry,     { desc = "Next entry" } },
        { "n", "H",  actions.select_prev_entry,     { desc = "Prev entry" } },
      },
    },
  })
  vim.keymap.set("n", "<leader>gcd", "<cmd>DiffviewOpen origin/master<cr>", { desc = "Current diff vs master" })
  vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>",      { desc = "File git history" })
  vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>",              { desc = "Close diffview" })
end)

-- nvim-treesitter
setup("nvim-treesitter.configs", function(ts)
  ts.setup({
    ensure_installed = {
      "java", "lua", "python", "javascript", "typescript",
      "json", "yaml", "toml", "markdown", "markdown_inline",
      "bash", "vim", "vimdoc",
    },
    highlight = { enable = true },
    indent = { enable = true },
  })
end)

-- oil.nvim
setup("oil", function(oil)
  oil.setup({
    default_file_explorer = true,
    view_options = { show_hidden = true },
  })
  vim.keymap.set("n", "-",          "<cmd>Oil<cr>", { desc = "Open parent directory" })
  vim.keymap.set("n", "<leader>oo", "<cmd>Oil<cr>", { desc = "Open parent directory" })
end)

-- pq (SQL scratch buffer via Postico favorites)
setup("pq", function(pq) pq.setup() end)

-- obsidian.nvim
setup("obsidian", function(obsidian)
  vim.opt.conceallevel = 2

  obsidian.setup({
    legacy_commands = false,
    workspaces = {
      {
        path = function()
          local p = vim.env.OBSIDIAN_VAULT
          assert(p and p ~= "", "OBSIDIAN_VAULT is empty")
          return vim.fs.normalize(p)
        end,
      },
    },
    completion = {
      blink = true,
      nvim_cmp = false,
    },
    note_id_func = function(title)
      return title ~= nil and title:gsub(" ", "-"):lower() or tostring(os.time())
    end,
    note_frontmatter = { tags = vim.NIL },
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
    },
    daily_notes = {
      folder = "daily",
      date_format = "YYYY-MM-DD",
    },
  })

  vim.keymap.set("n", "<leader>on", "<cmd>Obsidian new<cr>",          { desc = "New note" })
  vim.keymap.set("n", "<leader>of", "<cmd>Obsidian quick_switch<cr>", { desc = "Find note" })
  vim.keymap.set("n", "<leader>os", "<cmd>Obsidian search<cr>",       { desc = "Search notes" })
  vim.keymap.set("n", "<leader>od", "<cmd>Obsidian today<cr>",        { desc = "Daily note" })
  vim.keymap.set("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>",    { desc = "Backlinks" })
  vim.keymap.set("n", "<leader>ot", "<cmd>Obsidian tags<cr>",         { desc = "Tags" })
  vim.keymap.set("n", "<leader>ol", "<cmd>Obsidian follow_link<cr>",  { desc = "Follow link" })
  vim.keymap.set("n", "<leader>oi", "<cmd>Obsidian template<cr>",     { desc = "Insert template" })
end)
