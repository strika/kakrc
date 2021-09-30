source "%val{config}/plugins/plug.kak/rc/plug.kak"

plug "andreyorst/plug.kak" noload

plug "godlygeek/tabular"

plug "andreyorst/fzf.kak" config %{
    map global normal <c-p> ': fzf-mode<ret>'
} defer "fzf-file" %{
    set-option global fzf_file_command "find . \( -path './.*' -o -path './build*' \) -prune -false -o -type f -print"
}

plug "andreyorst/smarttab.kak" defer smarttab %{
    # When `backspace' is pressed, 2 spaces are deleted at once.
    set-option global softtabstop 2
    set-option global indentwidth 2
} config %{
    # These languages will use `expandtab' behavior.
    hook global WinSetOption filetype=(rust|markdown|kak|lisp|scheme|janet|sh|ruby) expandtab
}

plug "eraserhd/parinfer-rust" do %{
    cargo install --force --path .
} config %{
    hook global WinSetOption filetype=(clojure|lisp|scheme|racket|janet) %{
        parinfer-enable-window -smart
    }
}

plug "kkga/ui.kak" config %{
    map global user -docstring "UI mode" u ": enter-user-mode ui<ret>"
    hook global WinCreate .* %{
        ui-matching-toggle
        ui-search-toggle
    }
}

# Highlighters
add-highlighter global/ number-lines -relative
add-highlighter global/ column 80 default,black

# Easier navigation for Colemak keyboard layout.
map global normal <backspace> h
map global normal <c-n> j
map global normal <c-e> k
map global normal <tab> l

# Plan management utilities
map global user t "<a-h>;f[lcX<esc>" -docstring "Complete task"
map global user T "<a-h>;f[lc <esc>" -docstring "Uncomplete task"

# Remove trailing whitespace.
hook global BufWritePre .* %{ try %{ execute-keys -draft \%s\h+$<ret>d } }

# Lint
hook global BufWritePost .+\.(rb|js|es6) %{
    lint
}

# JavaScript
hook global BufCreate .+\.(es6) %{
    set-option buffer filetype javascript
}
hook global WinSetOption filetype=javascript %{
    set-option window lintcmd 'run() { cat "$1" | eslint -f unix --stdin --stdin-filename "$kak_buffile";} && run '
}

# Ruby
hook global WinSetOption filetype=ruby %{
    set-option window lintcmd 'rubocop --config .rubocop.yml'
}

# HTML and ERB
hook global WinSetOption filetype=(html|eruby) %{
    set-option buffer formatcmd "run(){ tidy -q --indent yes --indent-spaces 2 --wrap 1000 2>/dev/null || true; } && run"
}
