return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
        "lua", "c", "cpp", "python", "bash"
  			-- "vim", "lua", "vimdoc",
  			--   "html", "css"
  		},
  	},
  },

  {
    "rcarriga/nvim-notify",
    event = "VeryLazy", -- Load only when needed
    config = function()
      local notify = require("notify")
      vim.notify = notify

      notify.setup({
        stages = "static",  -- No animations (less processing)
        timeout = 1500,     -- Short duration
        background_colour = "None", -- No extra rendering
        render = "minimal", -- No icons, compact text only
        minimum_width = 1,
        top_down = false,
        fps = 1,
      })
    end
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*", -- Palaging gamitin ang latest version
    event = "VeryLazy", -- Load lang kapag kailangan
    opts = {
      size = 20, -- Terminal height (horizontal) o width (vertical)
      open_mapping = [[<C-\>]], -- Toggle shortcut (Ctrl + \)
      hide_numbers = true, -- Huwag ipakita ang line numbers
      shade_terminals = false, -- Walang background shading (mas lightweight)
      direction = "float", -- Default: Floating terminal
      float_opts = {
        border = "curved", -- Border style (single, double, curved, etc.)
      },
    }
  }
}
