{ pkgs, ... }:
{
  plugins.treesitter.nixvimInjections = true;
  plugins.treesitter.settings.auto_install = false;

  # plugins.treesitter.folding = true;
  plugins.treesitter.settings.indent.enable = false;
  plugins.treesitter.settings.highlight.enable = true;
  # plugins.treesitter.nixvimInjections = true;
  # plugins.treesitter.nixGrammars = true;
  plugins.treesitter.grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
    asm
    bash
    blade
    c
    cmake
    comment
    css
    dhall
    diff
    dockerfile
    dot
    fish
    git_config
    git_rebase
    gitattributes
    gitcommit
    gitignore
    go
    gomod
    gosum
    gotmpl
    gpg
    graphql
    haskell
    haskell_persistent
    hcl
    helm
    html
    http
    javascript
    jq
    jsdoc
    json
    latex
    lua
    luadoc
    luap
    luau
    make
    markdown
    markdown_inline
    mermaid
    nix
    # norg
    ocaml
    ocaml_interface
    ocamllex
    passwd
    po
    prisma
    proto
    pymanifest
    python
    query
    qmljs
    regex
    rescript
    ron
    rust
    scheme
    sql
    ssh_config
    templ
    terraform
    textproto
    tmux
    todotxt
    toml
    tsx
    typescript
    typst
    udev
    vhs
    vim
    vimdoc
    xml
    yaml
  ];
}
