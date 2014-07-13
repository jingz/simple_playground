" File:          simple_playground.vim
" Author:        Sarunyoo Chobpanich
" Version:       0.1.0
" Description:   simple_playground.vim insert the script's output in the
"                current file in comment format after you write/save the file.
"                It works in case one script line produce one output line.
"                *loop print is not working now
"
"                Aim to reduce time of learning new script or programming language.

function! SweepPlayground(prefix_cment)
    " clear old output
    execute "mark s"
    execute "%s/\\s\\+" . escape(a:prefix_cment, "/") . ".*//ge"
    " execute "echo " . substitute('%s', "\s\+#=>.*", '', 'g')
    execute "'s"
endfunction

function! MakePlayground(lang, print_pattern, cment_pattern)

    " Sweep Playground
    execute "mark s"
    execute "%s/\\s\\+" . escape(a:cment_pattern, "/") . ".*//ge"
    " execute "echo " . substitute('%s', "\s\+#=>.*", '', 'g')
    execute "'s"

    let l:cmdexecute = a:lang . " " . shellescape(expand('%'))
    let l:outputs = split(system(l:cmdexecute), "\n")

    let l:cur = 1
    execute "mark s"
    execute "normal! G"

    " collect line numbers of printing output
    let l:nl_print = search(a:print_pattern)
    let l:last_col = col("$")
    let l:collection_num_line = []
    let l:eol_column = []
    while l:nl_print > 0
        " echo l:nl_print
        let l:collection_num_line += [l:nl_print]
        let l:eol_column += [l:last_col]

        " search next print
        let l:new_nl_print = search(a:print_pattern)
        let l:last_col = col("$")

        if l:nl_print < l:new_nl_print
            let l:nl_print = l:new_nl_print
        else
            "reach to the last matche
            let l:nl_print = 0
        endif
    endwhile

    " echo l:collection_num_line

    let l:index = 0
    for nline in l:collection_num_line
        execute "normal! " . nline . "G$"
        while col("$") < max(l:eol_column)
            execute "normal! A "
        endwhile
        set nowrap
        execute "normal! A  " . a:cment_pattern . " " . l:outputs[l:index]
        let l:index = l:index + 1
    endfor

    execute "normal! 's"

    " for output in l:outputs
    "     execute "normal! " . l:cur . "Go" . output
    "     let l:cur = l:cur + 3
    " endfor
endfunction

fun! BuildPlayground(command, comment, print_pattern)
    let b:cmd = a:command
    let b:cmt = a:comment
    let b:prt = a:print_pattern
    augroup playground
        autocmd!
        autocmd! BufWritePre <buffer> call SweepPlayground(b:cmt)
        autocmd! BufWritePost <buffer> call MakePlayground(b:cmd, b:prt, b:cmt)
        echom "The Playground has been built"
    augroup END
endfun

fun! DestroyPlayground()
    autocmd! playground
    echom "The Playground has been destroyed!"
endfun
