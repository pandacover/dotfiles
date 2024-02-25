local opt = vim.opt

local editor_options = {
  --	completeopt = { 'menunone', 'noselect' },
  conceallevel = 0,      -- `` is visible in markdown files,
  hlsearch = true,       -- highlights matching search,
  ignorecase = true,     -- ignore case in search patterns,
  showtabline = 0,       -- always show tabs
  smartcase = true,      -- smart case
  smartindent = true,    -- smart indent
  splitbelow = true,     -- force horizontal splits to go below
  splitright = true,     -- force vertical splits to go right
  undofile = true,       -- enable persistent undo
  expandtab = true,      -- converts tabs to spaces
  shiftwidth = 2,        -- number of spaces for each indent
  tabstop = 2,           -- insert 2 spaces for tab
  cursorline = true,     -- highlight cursor line
  number = true,         -- set numbered lines
  relativenumber = true, -- set relative numbered lines
  numberwidth = 2,       -- set number column width 2 (default 4)
  signcolumn = 'yes',    -- show sign column, otherwise it would shift text each time
  wrap = false,          -- wrap lines
  scrolloff = 8,         -- scroll offset 8 rows
  sidescrolloff = 8,     -- side scroll offset 8 rows
}

local gui_options = {
  cmdheight = 0,             -- more space for cmdline messages
  hidden = true,             -- required to keep multiple buffers open
  pumheight = 10,            -- pop up menu height
  termguicolors = true,      -- set term gui colors
  guifont = 'monospace:h17', -- set gui font
}

local sys_options = {
  clipboard = 'unnamedplus', -- share system clipboard
  backup = false,            -- creates a backup file
  timeoutlen = 400,          -- timeout for mapped sequence (100 ms)
  updatetime = 300,          -- faster completion (default ~4000ms)
  writebackup = false,       -- cannot edit and/or save a file being edited and/or edited while editing, by other program,
  swapfile = false,          -- creates a swapfile
}

local override_opt = function(options)
  for key, value in pairs(options) do
    opt[key] = value
  end
end

override_opt(editor_options)
override_opt(gui_options)
override_opt(sys_options)
