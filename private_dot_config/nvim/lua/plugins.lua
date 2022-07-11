local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local compile_path = install_path .. "/plugin/packer_compiled.lua"
local packer_bootstrap = nil

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim",
    install_path })
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

return require("packer").startup({
  function(use)
    use "wbthomason/packer.nvim" -- Packer can manage itself

    -- Needed to load these first
    use "lewis6991/impatient.nvim"
    use "nvim-lua/plenary.nvim"

    -- Theme
    use "folke/tokyonight.nvim"

    -- Treesitter
    use { 'nvim-treesitter/nvim-treesitter', config = "require('plugins.treesitter')" }

    -- CMP (autocompletion) + plugins
    use { "hrsh7th/nvim-cmp", config = "require('plugins.cmp')"  } -- The completion plugin
    use "hrsh7th/cmp-buffer" -- buffer completions
    use "hrsh7th/cmp-path" -- path completions
    use "hrsh7th/cmp-cmdline" -- cmdline completions
    use "saadparwaiz1/cmp_luasnip" -- snippet completions
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-nvim-lua"
    use { "David-Kunz/cmp-npm", requires = "nvim-lua/plenary.nvim"}

    -- LSP
    use "neovim/nvim-lspconfig" -- enable LSP
    use "williamboman/nvim-lsp-installer" -- simple to use language server installer

    -- LSP addons
    use "onsails/lspkind-nvim"
    use { 'jose-elias-alvarez/typescript.nvim' }

    -- Navigation
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use { 'nvim-telescope/telescope.nvim',
      config = "require('plugins.telescope')",
      requires = {
        { 'nvim-lua/popup.nvim' },
        { 'nvim-lua/plenary.nvim' },
        { 'nvim-telescope/telescope-fzf-native.nvim' }
      }
    }
    use { 'cljoly/telescope-repo.nvim' }
    use { 'nvim-pack/nvim-spectre' }
    use {'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons', config = "require('plugins.bufferline')"}
    use { 'kyazdani42/nvim-tree.lua', config = "require('plugins.tree')" }

    -- Snippets & Language & Syntax
    use { 'windwp/nvim-autopairs', config = "require('plugins.autopairs')" }
    use { 'p00f/nvim-ts-rainbow' }
    use { 'lukas-reineke/indent-blankline.nvim', config = "require('plugins.indent')" }
    use { 'NvChad/nvim-colorizer.lua', config = "require('plugins.colorizer')" }

    -- snippets
    use "L3MON4D3/LuaSnip" --snippet engine
    use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

    -- MISC
    use "antoinemadec/FixCursorHold.nvim"
    use { 'folke/todo-comments.nvim', config = "require('plugins.todo-comments')" }
    use { 'numToStr/Comment.nvim', config = "require('plugins.comment')" }
    use { 'JoosepAlviste/nvim-ts-context-commentstring', after = 'nvim-treesitter' }

    if packer_bootstrap then
      require("packer").sync()
    end
  end,
  config = {
    compile_path = compile_path,
    display = {
      open_fn = function()
        return require("packer.util").float({ border = "rounded" })
      end
    }
  }
})
