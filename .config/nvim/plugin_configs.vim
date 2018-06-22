" Airline
	set laststatus=2

	" Bottom row
		if !exists('g:airline_symbols')
			let g:airline_symbols = {}
		endif
		let g:airline_symbols.linenr = '≣'
		let g:airline#extensions#keymap#enabled = 0
		let g:airline_detect_spelllang = 0
		set noshowmode

	" Tabs
		let g:airline#extensions#tabline#enabled = 1
		let g:airline#extensions#tabline#fnamemod = ':t'
		let g:airline#extensions#tabline#left_sep = ''
		let g:airline#extensions#tabline#left_alt_sep = ''

	" Theme
		let g:airline_powerline_fonts = 1

" DelimitMate
	let delimitMate_expand_cr = 1
	let delimitMate_expand_space = 0
	let delimitMate_nesting_quotes = ['`']

" Denite.nvim
	call denite#custom#option('_', 'highlight_mode_normal', 'CursorLine')
	call denite#custom#option('_', 'highlight_mode_insert', 'CursorLine')
	call denite#custom#option('_', 'highlight_matched_range', 'None')
	call denite#custom#option('_', 'highlight_matched_char', 'DiffDelete')
	call denite#custom#var('file/rec', 'command',
				\ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])

" Deoplete.nvim
	set completeopt-=preview
	let g:deoplete#enable_at_startup = 1

" LanguageClient-neovim
	let g:LanguageClient_serverCommands = {
				\ 'rust': ['rustup', 'run', 'nightly', 'rls'],
				\ 'c':    ['cquery', '--log-file=/tmp/cq.log'],
				\ 'cpp':  ['cquery', '--log-file=/tmp/cqcpp.log'],
				\ }

	let g:LanguageClient_settingsPath = $HOME . '/.config/nvim/settings.json'
	let g:LanguageClient_loadSettings = 1

	let g:cquery_c_options = '-Wall --std=c99'
	let g:cquery_cpp_options = '-Wall --std=c++11'

	let g:cquery_includes = ''

	function! FindProjectRootByFile(filename)
		let l:path = getcwd()
		while l:path != ''
			if filereadable(l:path.'/'.a:filename)
				return l:path
			else
				let l:path = substitute(l:path, '\v(.*)\/.*', '\1', 'g')
			endif
		endwhile
		return -1
	endfunction

	let s:prj_root = FindProjectRootByFile('testkit.settings')
	if s:prj_root != -1
		let g:cquery_includes  = "-I".s:prj_root."/include\n"
		let g:cquery_includes .= "-I".s:prj_root."/testpacks/SPW_TESTS/spw_lib_src\n"
		let g:cquery_includes .= "-I".s:prj_root."/testpacks/CAN/can_lib_src\n"
		let g:cquery_includes .= "-I".s:prj_root."/testpacks/MKIO/mkio_lib_src\n"
		let g:cquery_includes .= system('echo -n "-I'.s:prj_root.'/platforms/$(cat '.s:prj_root.'/testkit.settings | grep "?=" |  sed -E "s/.*= //")/include\n"')

		call execute('!echo "\%c -Weverything '.g:cquery_c_options.'" > '.s:prj_root.'/.cquery')
		call execute('!echo "" >> '.s:prj_root.'/.cquery')
		call execute('!echo "\# Includes" >> '.s:prj_root.'/.cquery')
		call execute('!echo "'.join(split(g:cquery_includes, '\n'), '\n').'" >> '.s:prj_root.'/.cquery')
	endif

	if match(execute("!echo $(pwd)"), "testms") != -1
		let g:cquery_includes = system('echo -n "
					\-I$(pwd)/include\n
					\-I$(pwd)/include/cp2\n
					\-I$(pwd)/include/hdrtest\n
					\-I$(pwd)/../../include\n
					\"')
	endif

	if filereadable("./testkit.settings") || filereadable("startf.S")
	endif

	let g:LanguageClient_diagnosticsDisplay = {
				\	1: {
				\		"name": "Error",
				\		"signText": "⬥ ",
				\		"signTexthl": "ErrorSign",
				\	},
				\	2: {
				\		"name": "Warning",
				\		"signText": "⬥ ",
				\		"signTexthl": "WarningSign",
				\	},
				\	3: {
				\		"name": "Information",
				\		"signText": "⬥ ",
				\		"signTexthl": "InfoSign",
				\	},
				\	4: {
				\		"name": "Hint",
				\		"signText": "⬥ ",
				\		"signTexthl": "InfoSign",
				\	},
				\}

" NERDTree
	autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Tagbar
	let g:tagbar_sort = 0
	let g:tagbar_compact = 1
	if match(execute("!echo $PATH"), "termux") == -1
		autocmd FileType c,cpp nested :TagbarOpen
	endif

" SimpleSnippets.vim
	let g:SimpleSnippets_dont_remap_tab = 1

	let g:SimpleSnippetsExpandOrJumpTrigger = "<Tab>"
	let g:SimpleSnippetsJumpBackwardTrigger = "<S-Tab>"
	let g:SimpleSnippetsJumpToLastTrigger = "<C-j>"

	function! ExpandOrClosePopup()
		if SimpleSnippets#isExpandableOrJumpable()
			return "\<Esc>:call SimpleSnippets#expandOrJump()\<Cr>"
		else
			let close_popup = deoplete#close_popup()
			return close_popup
		endif
	endfunction

	inoremap <silent><expr><CR> pumvisible() ?
				\"<C-R>=ExpandOrClosePopup()<CR>" :
				\delimitMate#WithinEmptyPair() ?
				\"\<C-R>=delimitMate#ExpandReturn()\<CR>" : "\<Cr>"
	inoremap <silent><expr><Tab> pumvisible() ? "\<c-n>" :
				\SimpleSnippets#isExpandableOrJumpable() ?
				\"\<Esc>:call SimpleSnippets#expandOrJump()\<Cr>" : "\<Tab>"
	snoremap <silent><expr><Tab> SimpleSnippets#isExpandableOrJumpable() ?
				\"\<Esc>:call SimpleSnippets#expandOrJump()\<Cr>" : "\<Tab>"
	nnoremap <silent><expr><Tab> SimpleSnippets#isExpandableOrJumpable() ?
				\"\<Esc>:call SimpleSnippets#expandOrJump()\<Cr>" : "\<Tab>"
	inoremap <silent><expr><S-Tab> pumvisible() ? "\<c-p>" :
				\SimpleSnippets#isJumpable() ?
				\"\<esc>:call SimpleSnippets#jumpBackwards()\<Cr>" :
				\"\<S-Tab>"
	snoremap <silent><expr><S-Tab> SimpleSnippets#isJumpable() ?
				\"\<Esc>:call SimpleSnippets#jumpBackwards()\<Cr>" :
				\"\<S-Tab>"
	nnoremap <silent><expr><S-Tab> SimpleSnippets#isJumpable() ?
				\"\<Esc>:call SimpleSnippets#jumpBackwards()\<Cr>" :
				\"\<S-Tab>"
	inoremap <silent><expr><S-j> SimpleSnippets#isJumpable() ?
				\"\<Esc>:call SimpleSnippets#jumpToLastPlaceholder()\<Cr>" :
				\"J"
	snoremap <silent><expr><S-j> SimpleSnippets#isJumpable() ?
				\"\<Esc>:call SimpleSnippets#jumpToLastPlaceholder()\<Cr>" :
				\"J"
	nnoremap <silent><expr><S-j> SimpleSnippets#isJumpable() ?
				\"\<Esc>:call SimpleSnippets#jumpToLastPlaceholder()\<Cr>" :
				\"\<S-j>"
