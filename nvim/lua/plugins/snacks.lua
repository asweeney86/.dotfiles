return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[]],
        },
      },
      -- image rendering requires kitty/wezterm/ghostty; disable on headless Linux
      image = { enabled = false },
    },
  },
}
