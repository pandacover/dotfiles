vim.g.mapleader = ' '

vim.keymap.set('n', '<leader>pv', '<cmd>Ex<cr>')
vim.keymap.set('n', '<leader>lz', '<cmd>Lazy<cr>')

-- buffer
vim.keymap.set('n', ',h', '<cmd>v<cr>')
vim.keymap.set('n', ',v', '<cmd>vs<cr>')
vim.keymap.set('n', ',n', '<c-w>w')
vim.keymap.set('n', ',N', '<c-w>W')
vim.keymap.set('n', ',b', '<cmd>bnext<cr>')
vim.keymap.set('n', ',B', '<cmd>bprev<cr>')

-- motions
vim.keymap.set('n', '<c-k>', '<c-u>zz')
vim.keymap.set('n', '<c-j>', '<c-d>zz')
