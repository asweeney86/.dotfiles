return {

  -- change trouble config
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = true,
      },

      -- options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          --prefix = "●",
          -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
          -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
          prefix = "icons",
        },
        severity_sort = true,
      },

      ---@type lspconfig.options
      servers = {
        omnisharp = {
          enable_roslyn_analyzers = true,
        },
        clangd = {
          keys = {
            { "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          -- Neovim 0.11+ native LSP calls root_dir(bufnr, on_dir) and needs on_dir(root) to be called;
          -- the old lspconfig `function(fname) return root end` form never attaches the server.
          root_dir = function(bufnr, on_dir)
            local util = require("lspconfig.util")
            local fname = vim.api.nvim_buf_get_name(bufnr)
            -- using a root .clang-format or .clang-tidy file messes up projects, so remove them
            local root = util.root_pattern("compile_commands.json", "compile_flags.txt", "configure.ac", ".git")(fname)
              or util.find_git_ancestor(fname)
            if root then
              on_dir(root)
            end
          end,
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          -- A project may ship scripts/clangd to run clangd where its dependencies live (ads-cpp keeps
          -- gRPC/Seastar/protobuf headers inside a container image); otherwise use the local clangd.
          cmd = function(dispatchers, config)
            local root = config.root_dir or vim.fn.getcwd()
            local argv = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders",
              "--fallback-style=llvm",
            }
            local wrapper = root .. "/scripts/clangd"
            if vim.uv.fs_stat(wrapper) then
              argv[1] = wrapper
            end
            return vim.lsp.rpc.start(argv, dispatchers, { cwd = root })
          end,
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        clangd = function(_, opts)
          local clangd_ext_opts = LazyVim.opts("clangd_extensions.nvim")
          require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))
          return false
        end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
  },

  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
        -- stylua: ignore
        keys = {
            { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
            { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
            { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
            { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
        },
  },

  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "c_sharp",
        "css",
        "cmake",
        "cpp",
        "diff",
        "dockerfile",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "graphql",
        "hcl",
        "html",
        "javascript",
        "java",
        "kotlin",
        "json",
        "json5",
        "jsonc",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "proto",
        "python",
        "query",
        "regex",
        "ron",
        "ruby",
        "rust",
        "sql",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
      -- indent = { enable = true },
    },
  },

  -- disable LuaSnip's default <tab>/<s-tab> mappings
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },

}
