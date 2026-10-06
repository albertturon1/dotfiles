local servers = {
  rust_analyzer = {},
  tsgo = {
    settings = {
      typescript = {
        updateImportsOnFileMove = { enabled = 'always' },
        suggest = { completeFunctionCalls = true },
        preferences = {
          importModuleSpecifier = 'shortest',
          importModuleSpecifierEnding = 'minimal',
          includePackageJsonAutoImports = 'on',
        },
        inlayHints = {
          parameterNames = { enabled = 'literals', suppressWhenArgumentMatchesName = true },
          parameterTypes = { enabled = true },
          variableTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          enumMemberValues = { enabled = true },
        },
      },
      javascript = {
        updateImportsOnFileMove = { enabled = 'always' },
        preferences = {
          importModuleSpecifier = 'shortest',
          importModuleSpecifierEnding = 'minimal',
          includePackageJsonAutoImports = 'on',
        },
      },
    },
  },
  html = { filetypes = { 'html', 'twig', 'hbs' } },
  cssls = {},
  tailwindcss = {},
}

-- Mason installs binaries; native Neovim LSP owns configuration and activation.
require('mason-tool-installer').setup {
  ensure_installed = {
    'stylua',
    'lua_ls',
    'rust_analyzer',
    'tsgo',
    'html',
    'cssls',
    'tailwindcss',
  },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
end
vim.lsp.enable(vim.tbl_keys(servers))
