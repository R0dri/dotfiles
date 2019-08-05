# ╭─────────────╥──────────────────╮
# │ Author:     ║ File:            │
# │ Andrey Orst ║ languages.kak    │
# ╞═════════════╩══════════════════╡
# │ Custom language settings for   │
# │ different filetypes that       │
# │ change how Kakoune works.      │
# ╞════════════════════════════════╡
# │ Rest of .dotfiles:             │
# │ GitHub.com/andreyorst/dotfiles │
# ╰────────────────────────────────╯

# C/Cpp
# ‾‾‾‾‾
hook global WinSetOption filetype=(c|cpp) %{
    set-option buffer formatcmd 'clang-format'
    set-option buffer matching_pairs '{' '}' '[' ']' '(' ')'
}

hook global ModuleLoaded c-family %{ try %{ evaluate-commands %sh{
    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

    # taken from rc/filetype/c-family.kak
    c_keywords='asm break case continue default do else for goto if return
                sizeof switch while offsetof alignas alignof'

    # Highlight functions ignoring C specific keywords
    printf "%s\n" "add-highlighter shared/c/code/my_functions     regex (\w*?)\b($(join '${c_keywords}' '|'))?(\h+)?(?=\() 1:function"

    # taken from rc/filetype/c-family.kak
    cpp_keywords='alignas alignof and and_eq asm bitand bitor break case catch
                  compl const_cast continue decltype delete do dynamic_cast
                  else export for goto if new not not_eq operator or or_eq
                  reinterpret_cast return sizeof static_assert static_cast switch
                  throw try typedef typeid using while xor xor_eq'

    # Highlight functions ignoring C++ specific keywords
    printf "%s\n" "add-highlighter shared/cpp/code/functions        regex (\w*?)\b($(join '${cpp_keywords}' '|'))?(\h+)?(?=\() 1:function"
    # Namespace highlighting
    printf "%s\n" "add-highlighter shared/cpp/code/namespace  regex [a-zA-Z](\w+)?(\h+)?(?=::) 0:module"
    # Types and common highlightings. Same for C and C++
    for filetype in c cpp; do
        printf "%s\n" "add-highlighter shared/$filetype/code/my_field     regex ((?<!\.\.)(?<=\.)|(?<=->))[a-zA-Z](\w+)?\b(?![>\"\(]) 0:meta
                       add-highlighter shared/$filetype/code/my_method    regex ((?<!\.\.)(?<=\.)|(?<=->))[a-zA-Z](\w+)?(\h+)?(?=\() 0:function
                       add-highlighter shared/$filetype/code/my_return    regex \breturn\b 0:meta
                       add-highlighter shared/$filetype/code/my_types_1   regex \b(v|u|vu)\w+(8|16|32|64)\b 0:type
                       add-highlighter shared/$filetype/code/my_types_2   regex \b(v|u|vu)?(_|__)?(s|u)(8|16|32|64)\b 0:type
                       add-highlighter shared/$filetype/code/my_types_3   regex \b(v|u|vu)(_|__)?(int|short|char|long)\b 0:type
                       add-highlighter shared/$filetype/code/my_types_4   regex struct\h+(\w+) 1:type
                       add-highlighter shared/$filetype/code/struct_type  regex \b\w+_t\b 0:type
                       add-highlighter shared/$filetype/code/type_cast    regex \((?:volatile\h*)?([^(]\w+\h*[^()]*)(?:\*\h*)\)\h*(?:\(|\w+) 1:type
                       add-highlighter shared/$filetype/code/func_pointer regex (\w+)\h*\(\*\h*(\w+)\)\([^)]*\) 1:type 2:function"
    done
}}}

# Rust
# ‾‾‾‾
hook global WinSetOption filetype=rust %{
    set-option buffer formatcmd 'rustfmt'
    set-option buffer matching_pairs '{' '}' '[' ']' '(' ')'
}

# Makefile
# ‾‾‾‾‾‾‾‾
hook global BufCreate .*\.mk$ %{
    set-option buffer filetype makefile
}

# Kakscript
# ‾‾‾‾‾‾‾‾‾
hook global WinSetOption filetype=kak %{ hook global NormalIdle .* %{
    evaluate-commands -save-regs 'a' %{ try %{
        execute-keys -draft <a-i>w"ay
        evaluate-commands %sh{ (
            color="${kak_reg_a}"
            inverted_color=$(echo "${color}" | perl -pe 'tr/0123456789abcdefABCDEF/fedcba9876543210543210/')
            printf "%s\n" "evaluate-commands -client $kak_client %{ try %{
                               echo -markup %{{rgb:${inverted_color},rgb:${color}+b}   #${color}   }
                           }}" | kak -p $kak_session
        ) >/dev/null 2>&1 </dev/null & }
    }}
}}

# Assemply
# ‾‾‾‾‾‾‾‾
hook global WinSetOption filetype=gas %{
    set-option window comment_line '#'
    # a c-like line comment highlighter for compatibility reasons
}

hook global ModuleLoaded gas %{ try %{
    add-highlighter shared/gas/c_line_comment region // (?<!\\\\)(?=\n) fill comment
}}
