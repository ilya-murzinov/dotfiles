-- Configuration for vim-plug-installed lua plugins.
-- Called from init.lua after vimrc (and vim-plug) has been sourced.
-- Each block is guarded with pcall so a missing plugin never crashes startup.

local function setup(name, fn)
  local ok, mod = pcall(require, name)
  if ok then fn(mod) end
end

-- which-key
setup("which-key", function(wk)
  wk.setup({ delay = 300 })
  wk.add({
    { "<leader>?", function() wk.show({ global = true }) end, desc = "All keybindings" },
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>j", group = "java" },
    { "<leader>s", group = "search" },
    { "<leader>p", group = "file explorer" },
    { "<leader>t", group = "tab" },
    { "<leader>m", group = "markdown/markdown-preview/mouse" },
    { "<leader>o", group = "obsidian" },
  })
end)

-- fzf-lua
setup("fzf-lua", function(fzf) fzf.setup({}) end)

-- diffview
setup("diffview", function(dv)
  dv.setup({})
  vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen origin/master<cr>", { desc = "Diff vs master" })
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

-- mason
setup("mason", function(m) m.setup() end)
setup("mason-lspconfig", function(ml) ml.setup({ ensure_installed = { "jdtls" } }) end)

-- LSP keymaps (applied to every buffer where an LSP attaches)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = buf, desc = desc })
    end
    map("gd",         vim.lsp.buf.definition,     "Go to definition")
    map("gD",         vim.lsp.buf.declaration,    "Go to declaration")
    map("gr",         vim.lsp.buf.references,     "References")
    map("gi",         vim.lsp.buf.implementation, "Go to implementation")
    map("K",          vim.lsp.buf.hover,          "Hover docs")
    map("<leader>rn", vim.lsp.buf.rename,         "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action,    "Code action")
    map("<leader>e",  vim.diagnostic.open_float,  "Show diagnostic")
    map("[d",         vim.diagnostic.goto_prev,   "Previous diagnostic")
    map("]d",         vim.diagnostic.goto_next,   "Next diagnostic")
  end,
})

-- nvim-jdtls: start Java LSP on every Java buffer
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local ok_jdtls, jdtls             = pcall(require, "jdtls")
    local ok_setup, jdtls_setup       = pcall(require, "jdtls.setup")
    if not ok_jdtls or not ok_setup then return end

    local home      = vim.env.HOME
    local mason_dir = home .. "/.local/share/nvim/mason/packages/jdtls"
    local os_config = vim.fn.has("mac") == 1 and "mac" or "linux"
    local launcher  = vim.fn.glob(mason_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar")
    local root_dir  = jdtls_setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
    local project   = root_dir and vim.fn.fnamemodify(root_dir, ":t") or "unknown"
    local workspace = home .. "/.local/share/nvim/jdtls-workspace/" .. project

    jdtls.start_or_attach({
      cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.level=ALL",
        "-Xmx4g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-jar", launcher,
        "-configuration", mason_dir .. "/config_" .. os_config,
        "-data", workspace,
      },
      root_dir = root_dir,
      settings = {
        java = {
          eclipse = { downloadSources = true },
          maven = { downloadSources = true },
          implementationsCodeLens = { enabled = true },
          referencesCodeLens = { enabled = true },
          format = { enabled = true },
        },
      },
      init_options = { bundles = {} },
    })

    local buf = vim.api.nvim_get_current_buf()
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = buf, desc = desc })
    end
    map("<leader>jo", jdtls.organize_imports,    "Organize imports")
    map("<leader>jt", jdtls.test_nearest_method, "Test method")
    map("<leader>jT", jdtls.test_class,          "Test class")
    map("<leader>je", jdtls.extract_variable,    "Extract variable")
    map("<leader>jm", jdtls.extract_method,      "Extract method")
  end,
})

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
    picker = { name = "fzf-lua" },
    note_id_func = function(title)
      return title ~= nil and title:gsub(" ", "-"):lower() or tostring(os.time())
    end,
    note_frontmatter = { tags = vim.NIL },
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
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

  local group = vim.api.nvim_create_augroup("obsidian_lsp_ensure", { clear = true })

  local function ensure_obsidian_lsp(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    if vim.bo[bufnr].buftype ~= "" then return end
    local ft = vim.bo[bufnr].filetype
    if ft ~= "markdown" and ft ~= "quarto" then return end
    if #vim.lsp.get_clients({ bufnr = bufnr, name = "obsidian-ls" }) > 0 then return end
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == "" then return end
    local ok, api = pcall(require, "obsidian.api")
    if not ok or not api.find_workspace(path) then return end
    require("obsidian.lsp").start(bufnr)
  end

  local function schedule_ensure(bufnr)
    vim.schedule(function() ensure_obsidian_lsp(bufnr) end)
    vim.defer_fn(function() ensure_obsidian_lsp(bufnr) end, 120)
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "markdown", "quarto" },
    callback = function(args) schedule_ensure(args.buf) end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    group = group,
    callback = function(args)
      local ft = vim.bo[args.buf].filetype
      if ft == "markdown" or ft == "quarto" then
        schedule_ensure(args.buf)
      end
    end,
  })
end)
