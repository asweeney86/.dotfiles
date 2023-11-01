return {
  "nvimdev/dashboard-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function(_, opts)
    opts.config.header = {
      "",
      "                 _                 ",
      "                | |                ",
      "   ___ __ _ _ __| |__   ___  _ __  ",
      " / __/ _` | '__| '_ \\ / _ \\| '_ \\",
      " | (_| (_| | |  | |_) | (_) | | | |",
      "  \\___\\__,_|_|  |_.__/ \\___/|_| |_|",
      "                                   ",
      "",
    }
  end,
  --config = function()
  --  require("alpha").setup(require("alpha.themes.startify").config)
  --end,
}
