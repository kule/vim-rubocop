# Vim Rubocop

Vim & Neovim plugin to run [Rubocop](https://github.com/rubocop-hq/rubocop)
and display the results in a quickfix window. Most of this is same as the
[Vim Rubocop](https://github.com/deepredsky/vim-rubocop) plugin with added
Neovim support and slightly changed command names. Credit to deepredsky & mgmy.

## Usage

```
:Rubocop " Runs rubocop on the current buffer
:RubocopAll " Runs rubocop on the whole project
:RubocopAll --no-display-cop-names" Run rubocop with custom options
:RubocopFix " Fix rubocop issues for current file. This will not be async.
```

By default it will look at Gemfile and use `bundle exec rubocop --format emacs`
if rubocop is specified in the Gemfile, otherwise it will fallback to using
`rubocop --format emacs`. This can be overridden

```
let g:rubocop_cmd = "bundle exec rubocop --no-display-cop-names"
```

NOTE that emacs formatter is required for this plugin to populate quickfix list

