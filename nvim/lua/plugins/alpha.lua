return {
  "glepnir/dashboard-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function(_, opts)
    opts.config.header = {
      "",
      "  _____         __           ",
      " / ___/__ _____/ /  ___  ___ ",
      "/ /__/ _ `/ __/ _ / _ / _  ",
      "___/_,_/_/ /_.__/___/_//_/ ",
      "                              ",
      "",
    }
  end,
  --config = function()
  --  require("alpha").setup(require("alpha.themes.startify").config)
  --end,
}
