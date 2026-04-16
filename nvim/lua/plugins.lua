-- Nvim-only plugins (not shared with vim)
-- These load via lazy.nvim after vimrc is sourced

return {
  -- Which-key: shows available keybindings after pressing leader
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 300,
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = true })
        end,
        desc = "All keybindings",
      },
    },
    config = function(_, opts)
      require("which-key").setup(opts)
      require("which-key").add({
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "search" },
        { "<leader>p", group = "file explorer" },
        { "<leader>t", group = "tab" },
        { "<leader>m", group = "markdown/markdown-preview/mouse" },
        { "<leader>o", group = "obsidian" },
      })
    end,
  },

  -- vim-be-good: nvim-only plugin for practicing vim movements
  {
    "ThePrimeagen/vim-be-good",
    cmd = "VimBeGood", -- Load only when :VimBeGood is called
  },

  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = false,
    priority = 200,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
      { "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch" },
      { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search notes" },
      { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Today's daily note" },
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
      { "<leader>of", "<cmd>Obsidian follow_link<cr>", desc = "Follow link" },
      { "<leader>oT", "<cmd>Obsidian template<cr>", desc = "Insert template" },
    },
    init = function()
      vim.opt.conceallevel = 2
    end,
    config = function()
      require("obsidian").setup({
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
          blink = false,
          nvim_cmp = false,
        },
        picker = {
          name = "fzf-lua",
        },
        note_id_func = function(title)
          return title ~= nil and title:gsub(" ", "-"):lower() or tostring(os.time())
        end,
        note_frontmatter = {
          tags = vim.NIL,
        },
      })

      local group = vim.api.nvim_create_augroup("obsidian_lsp_ensure", { clear = true })

      local function ensure_obsidian_lsp(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        if vim.bo[bufnr].buftype ~= "" then
          return
        end
        local ft = vim.bo[bufnr].filetype
        if ft ~= "markdown" and ft ~= "quarto" then
          return
        end
        if #vim.lsp.get_clients({ bufnr = bufnr, name = "obsidian-ls" }) > 0 then
          return
        end
        local path = vim.api.nvim_buf_get_name(bufnr)
        if path == "" then
          return
        end
        local ok, api = pcall(require, "obsidian.api")
        if not ok or not api.find_workspace(path) then
          return
        end
        require("obsidian.lsp").start(bufnr)
      end

      local function schedule_ensure(bufnr)
        vim.schedule(function()
          ensure_obsidian_lsp(bufnr)
        end)
        vim.defer_fn(function()
          ensure_obsidian_lsp(bufnr)
        end, 120)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "markdown", "quarto" },
        callback = function(args)
          schedule_ensure(args.buf)
        end,
      })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        group = group,
        callback = function(args)
          local buf = args.buf
          local ft = vim.bo[buf].filetype
          if ft ~= "markdown" and ft ~= "quarto" then
            return
          end
          schedule_ensure(buf)
        end,
      })
    end,
  },
  -- fzf-lua: picker backend for obsidian.nvim (and general use)
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({})
    end,
  },
}
