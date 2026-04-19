-- lazy.nvim specs — only for plugins that vim-plug can't manage well.
-- blink.cmp needs version-pinned pre-built Rust binaries, which requires lazy.nvim's
-- release tag resolution. Everything else is installed via vim-plug (plugins.vim).

return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = { "accept", "fallback" },
      },
      sources = {
        default = { "lsp", "path", "buffer" },
        per_filetype = {
          markdown = { "obsidian", "obsidian_new", "obsidian_tags", "lsp", "path", "buffer" },
        },
      },
    },
  },
}
