return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
    },
    opts = function(_, opts)
      -- Biome when the project has a biome config, otherwise Prettier (from the
      -- lazyvim.plugins.extras.formatting.prettier extra, which also covers more filetypes).
      local biome_fts =
        { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc", "css" }
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(biome_fts) do
        opts.formatters_by_ft[ft] = { "biome", "prettier", stop_after_first = true }
      end

      opts.formatters_by_ft.lua = { "stylua" }
      opts.formatters_by_ft.sh = { "shfmt" }
      opts.formatters_by_ft.python = { "ruff_organize_imports", "ruff_format" }
      opts.formatters_by_ft.sql = { "sqlfmt" }

      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        injected = { options = { ignore_errors = true } },
        biome = {
          condition = function(_, ctx)
            return vim.fs.find({ "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }, {
              path = ctx.filename,
              upward = true,
            })[1] ~= nil
          end,
        },
      })
      -- Extras each append "prettier"; drop duplicates so it only runs once.
      for ft, list in pairs(opts.formatters_by_ft) do
        local seen, out = {}, {}
        for k, v in pairs(list) do
          if type(k) ~= "number" then
            out[k] = v
          elseif not seen[v] then
            seen[v] = true
            out[#out + 1] = v
          end
        end
        opts.formatters_by_ft[ft] = out
      end
      return opts
    end,
  },
}
