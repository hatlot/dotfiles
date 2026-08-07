" 文字コードの設定
set encoding=utf-8
set fileencodings=utf-8,cp932,sjis,euc-jp
set fileformats=unix,dos,mac
" 見た目の設定
syntax on           " 構文ハイライト（色付け）を有効にする
set number          " 行番号を表示する
set cursorline      " カーソルがある行にアンダーラインを引く
set title           " ターミナルのタブにファイル名を表示する

" 検索の設定
set ignorecase      " 検索時に大文字・小文字を区別しない
set smartcase       " 検索に大文字が含まれていたら区別する
set incsearch       " 文字を入力するたびに検索を行う（インクリメンタルサーチ）
set hlsearch        " 検索結果をハイライト（色付き）で表示する

" インデント（空白）の設定
set autoindent      " 改行時に前の行のインデントを維持する
set expandtab       " Tabキーを押した時に「空白文字」に変換する
set tabstop=4       " Tab文字の幅をスペース4つ分にする
set shiftwidth=4    " 自動インデントの幅をスペース4つ分にする

" その他の便利設定
set clipboard=unnamedplus " OSのクリップボード（Windows側のコピペ）と連携する
set showmatch       " カッコを入力した時、対応するカッコを一瞬ハイライトする
