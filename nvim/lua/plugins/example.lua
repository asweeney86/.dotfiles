-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
-- if true then return {} end

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
local java_filetypes = { "java", "jsp" }
return {
  { import = "lazyvim.plugins.extras.lang.clangd" },
  { import = "lazyvim.plugins.extras.lang.rust" },
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(_, item)
            local icons = require("lazyvim.config").icons.kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
            return item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        sorting = defaults.sorting,
      }
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "Saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        config = true,
      },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, {
        { name = "crates" },
      }))
    end,
  },

  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = true,
  },

  -- change trouble config
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- add symbols-outline
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    config = true,
  },

  -- override nvim-cmp and add cmp-emoji
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "emoji" } }))
    end,
  },

  -- change some telescope options and a keymap to browse plugin files
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },
    },
    -- change some options
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },

  -- add telescope-fzf-native
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
  },
  -- add tsserver and setup with typescript.nvim instead of lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").lsp.on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
    },
    ---@class PluginLspOpts
    opts = {
      formatOnSave = true,

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
        -- tsserver will be automatically installed with mason and loaded with lspconfig
        jdtls = {},
        tsserver = {},
        pyright = {},
        solargraph = {},
        terraformls = {},
        dockerls = {},
        lua_ls = {},
        denols = {},
        omnisharp = {
          enable_roslyn_analyzers = true,
        },
        docker_compose_language_service = {},
        rust_analyzer = {
          keys = {
            { "K", "<cmd>RustHoverActions<cr>", desc = "Hover Actions (Rust)" },
            { "<leader>cR", "<cmd>RustCodeAction<cr>", desc = "Code Action (Rust)" },
            { "<leader>dr", "<cmd>RustDebuggables<cr>", desc = "Run Debuggables (Rust)" },
          },
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              checkOnSave = true,
              -- Add clippy lints for Rust.
              --checkOnSave = {
              --  allFeatures = true,
              --  command = "clippy",
              --  extraArgs = { "--no-deps" },
              --},
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          },
        },
        taplo = {
          keys = {
            {
              "K",
              function()
                if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                  require("crates").show_popup()
                else
                  vim.lsp.buf.hover()
                end
              end,
              desc = "Show Crate Documentation",
            },
          },
        },
        clangd = {
          keys = {
            { "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
          },
          root_dir = function(fname)
            -- using a root .clang-format or .clang-tidy file messes up projects, so remove them
            return require("lspconfig.util").root_pattern(
              "compile_commands.json",
              "compile_flags.txt",
              "configure.ac",
              ".git"
            )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
              fname
            ) or require("lspconfig.util").find_git_ancestor(fname)
          end,
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
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
        jdtls = function()
          return true -- avoid duplicate servers
        end,
        -- example to setup with typescript.nvim
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts })
          return true
        end,

        clangd = function(_, opts)
          local clangd_ext_opts = require("lazyvim.util").opts("clangd_extensions.nvim")
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
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
  },

  -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
  -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
  { import = "lazyvim.plugins.extras.lang.typescript" },

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  { import = "lazyvim.plugins.extras.lang.json" },

  { import = "lazyvim.plugins.extras.lang.docker" },

  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "c_sharp",
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

  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
        "solargraph",
        "prettierd",
      },
    },
  },

  -- Use <tab> for completion and snippets (supertab)
  -- first: disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },

  -- then: setup supertab in cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },

  -- Ruby setup
  { import = "lazyvim.plugins.extras.lang.ruby" },

  -- Terraform
  { import = "lazyvim.plugins.extras.lang.terraform" },

  { import = "lazyvim.plugins.extras.coding.copilot" },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = {
      options = {
        theme = "catppuccin",
      },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = "copilot.lua",
    opts = {},
    config = function(_, opts)
      local copilot_cmp = require("copilot_cmp")
      copilot_cmp.setup(opts)
      -- attach cmp source whenever copilot attaches
      -- fixes lazy-loading issues with the copilot cmp source
      require("lazyvim.util").lsp.on_attach(function(client)
        if client.name == "copilot" then
          copilot_cmp._on_insert_enter({})
        end
      end)
    end,
  },

  --    { import = "lazyvim.plugins.extras.formatting.prettier" },
  { import = "lazyvim.plugins.extras.lang.tailwind" },

  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "folke/which-key.nvim" },
    ft = java_filetypes,
    opts = function()
      local config = {
        cmd = { vim.fn.exepath("jdtls") },
        root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]),
      }
      return {
        require("jdtls").start_or_attach(config),
      }
    end,
    --    opts = function()
    --      return {
    --        -- How to find the root dir for a given filename. The default comes from
    --        -- lspconfig which provides a function specifically for java projects.
    --        root_dir = require("lspconfig.server_configurations.jdtls").default_config.root_dir,
    --
    --        -- How to find the project name for a given root dir.
    --        project_name = function(root_dir)
    --          return root_dir and vim.fs.basename(root_dir)
    --        end,
    --
    --        -- Where are the config and workspace dirs for a project?
    --        jdtls_config_dir = function(project_name)
    --          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
    --        end,
    --        jdtls_workspace_dir = function(project_name)
    --          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
    --        end,
    --
    --        -- How to run jdtls. This can be overridden to a full java command-line
    --        -- if the Python wrapper script doesn't suffice.
    --        cmd = { vim.fn.exepath("jdtls") },
    --        full_cmd = function(opts)
    --          local fname = vim.api.nvim_buf_get_name(0)
    --          local root_dir = opts.root_dir(fname)
    --          local project_name = opts.project_name(root_dir)
    --          local cmd = vim.deepcopy(opts.cmd)
    --          if project_name then
    --            vim.list_extend(cmd, {
    --              "-configuration",
    --              opts.jdtls_config_dir(project_name),
    --              "-data",
    --              opts.jdtls_workspace_dir(project_name),
    --            })
    --          end
    --          return cmd
    --        end,
    --
    --        -- These depend on nvim-dap, but can additionally be disabled by setting false here.
    --        dap = { hotcodereplace = "auto", config_overrides = {} },
    --        test = true,
    --      }
    --    end,
    -- config = function(_, Opts)
    --   local Util = require("lazy.core.util")

    --   local opts = Opts("nvim-jdtls") or {}

    --   -- Find the extra bundles that should be passed on the jdtls command-line
    --   -- if nvim-dap is enabled with java debug/test.
    --   local mason_registry = require("mason-registry")
    --   local bundles = {} ---@type string[]
    --   if opts.dap and Util.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
    --     local java_dbg_pkg = mason_registry.get_package("java-debug-adapter")
    --     local java_dbg_path = java_dbg_pkg:get_install_path()
    --     local jar_patterns = {
    --       java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
    --     }
    --     -- java-test also depends on java-debug-adapter.
    --     if opts.test and mason_registry.is_installed("java-test") then
    --       local java_test_pkg = mason_registry.get_package("java-test")
    --       local java_test_path = java_test_pkg:get_install_path()
    --       vim.list_extend(jar_patterns, {
    --         java_test_path .. "/extension/server/*.jar",
    --       })
    --     end
    --     for _, jar_pattern in ipairs(jar_patterns) do
    --       for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
    --         table.insert(bundles, bundle)
    --       end
    --     end
    --   end

    --   local function attach_jdtls()
    --     local fname = vim.api.nvim_buf_get_name(0)

    --     -- Configuration can be augmented and overridden by opts.jdtls
    --     local config = extend_or_override({
    --       cmd = opts.full_cmd(opts),
    --       root_dir = opts.root_dir(fname),
    --       init_options = {
    --         bundles = bundles,
    --       },
    --       -- enable CMP capabilities
    --       capabilities = require("cmp_nvim_lsp").default_capabilities(),
    --     }, opts.jdtls)

    --     -- Existing server will be reused if the root_dir matches.
    --     require("jdtls").start_or_attach(config)
    --     -- not need to require("jdtls.setup").add_commands(), start automatically adds commands
    --   end

    --   -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
    --   -- depending on filetype, so this autocmd doesn't run for the first file.
    --   -- For that, we call directly below.
    --   vim.api.nvim_create_autocmd("FileType", {
    --     pattern = java_filetypes,
    --     callback = attach_jdtls,
    --   })

    --   -- Setup keymap and dap after the lsp is fully attached.
    --   -- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
    --   -- https://neovim.io/doc/user/lsp.html#LspAttach
    --   vim.api.nvim_create_autocmd("LspAttach", {
    --     callback = function(args)
    --       local client = vim.lsp.get_client_by_id(args.data.client_id)
    --       if client and client.name == "jdtls" then
    --         local wk = require("which-key")
    --         wk.register({
    --           ["<leader>cx"] = { name = "+extract" },
    --           ["<leader>cxv"] = { require("jdtls").extract_variable_all, "Extract Variable" },
    --           ["<leader>cxc"] = { require("jdtls").extract_constant, "Extract Constant" },
    --           ["gs"] = { require("jdtls").super_implementation, "Goto Super" },
    --           ["gS"] = { require("jdtls.tests").goto_subjects, "Goto Subjects" },
    --           ["<leader>co"] = { require("jdtls").organize_imports, "Organize Imports" },
    --         }, { mode = "n", buffer = args.buf })
    --         wk.register({
    --           ["<leader>c"] = { name = "+code" },
    --           ["<leader>cx"] = { name = "+extract" },
    --           ["<leader>cxm"] = {
    --             [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
    --             "Extract Method",
    --           },
    --           ["<leader>cxv"] = {
    --             [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
    --             "Extract Variable",
    --           },
    --           ["<leader>cxc"] = {
    --             [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
    --             "Extract Constant",
    --           },
    --         }, { mode = "v", buffer = args.buf })

    --         if opts.dap and Util.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
    --           -- custom init for Java debugger
    --           require("jdtls").setup_dap(opts.dap)
    --           require("jdtls.dap").setup_dap_main_class_configs()

    --           -- Java Test require Java debugger to work
    --           if opts.test and mason_registry.is_installed("java-test") then
    --             -- custom keymaps for Java test runner (not yet compatible with neotest)
    --             wk.register({
    --               ["<leader>t"] = { name = "+test" },
    --               ["<leader>tt"] = { require("jdtls.dap").test_class, "Run All Test" },
    --               ["<leader>tr"] = { require("jdtls.dap").test_nearest_method, "Run Nearest Test" },
    --               ["<leader>tT"] = { require("jdtls.dap").pick_test, "Run Test" },
    --             }, { mode = "n", buffer = args.buf })
    --           end
    --         end

    --         -- User can set additional keymaps in opts.on_attach
    --         if opts.on_attach then
    --           opts.on_attach(args)
    --         end
    --       end
    --     end,
    --   })

    --   -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
    --   attach_jdtls()
    -- end,
  },
}
