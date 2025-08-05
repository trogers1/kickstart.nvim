> Legend: 
> `<Leader>` is 'Space'
> `<c-o>` is 'Ctrl-o'
> `<m-q>` === `<alt-q>` because 'm' is 'meta', which is 'left alt'
> `<CR>` is 'Return|Enter'

- `ci<thing like quote>` changed inside <thing>. This will cut all contents within a string, for example.
- `f<char>` brings me to the next instance of that character on the same line (e.g. "find <char>"). Capital `F` for backward.
- `gd` when highlighting a function is "go to definition" for a function of `gf` on a file path to go to the file
    - `Ctrl-6` to return to the previous buffer (where you jumped from, potentially not a different buffer)
- `<num>G` is how you go to a specific line number
- `<Leader>-x` closes the current buffer (file)
- `yy` `P` yanks the whole line and PUTs it above the current line
- `Shift-Down` OR `Ctrl-d` scrolls down by a half page. `Ctrl-u` scrolls a half screen up.
- `:bd` will delete the current buffer
- `q<anything>` from the Normal mode to start recording a Macro. Then end recording by returning to Normal mode and pressing `q`. Play your macro with `@<whatever you used>`.
- LSP rename === rename everywhere. E.g. global find-replace. `<Leader>-ra`
- `Shift-K` to show popup, inferred type definition.
- `<Leader>-fm` to use LSP format function on current buffer
- `%` goes to the matching paren/bracket/brace
- `CTRL+w, c`: Closes a window but keeps the buffer
- NvimTree (https://docs.rockylinux.org/books/nvchad/nvchad_ui/nvimtree/)
  - `a` add file or directory
  - `r` rename
  - `d` delete
  - `x` cut
  - `c` copy
  - `p` paste
  - `R` (refresh) to perform a reread of the files contained in the project
- `<Leader>-ra` LSP rename (rename the variable throughout a file)
- `ge` opens a popup with the error
- Telescope (find_files, live_grep)
  - `ff` find file with a filename that matches your search term (EXCLUDES dotfiles, hidden files, gitignore)
  - `fa` find file with a filename that matches your search term (INCLUDING hidden files, dotfiles, etc.)
  - `fw` find file with contents that match your search term (INCLUDING hidden files, dotfiles, etc.)
- `z=` when highlighting miss-spelled word will show alternatives to change to
- `Shift-j` joins the next line to the current line (removing the line break)
- `:LspInfo` get's info from the current LSP (maybe typescript, if you're struggling with something)
  - For further debugging: `:LspLog`
- `Lazy` to check on installations
- `:LspInfo` to debug LSP issues
- `:checkhealth` to check the status of a lot of the plugins (most of the neovim ecosystem). Very useful.
- `<c-q>` to add my search results to a new 'Quick Fix List' to 'pin' them to return to. 
- `<alt-q>` will add a new thing to your 'Quick Fix List'
  - `<tab>`: Marks a file/search result. Do this to several telescope results, then `<alt-q>` 
- `<c-[hjkl]`: move between windows the same way you move you cursor, but while holding Ctrl.
- Telescope:
  - `c-CR` to enter 'fuzzy refine' mode to further refine your search
  - `<Leader-SR>` is Search Resume, to resume your last search
