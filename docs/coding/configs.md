# Tools & Configuration Cheat sheet

## Vim 
### Global Configurations
```
set nocompatible                "去掉有关vi一致性模式，避免以前版本的bug和局限"
set number
set relativenumber              "显示行号"
set guifont=Luxi/Mono/9         "设置字体，字体名称和字号"
filetype on                     "检测文件的类型"    
set history=1000                "记录历史的行数"
set cindent                     "cindent是特别针对 C语言语法自动缩进"
set smartindent                 "依据上面的对齐格式，智能的选择对齐方式，对于类似C语言编写上有用"
set tabstop=4                   "设置tab键为4个空格"
set ai!                         "设置自动缩进"
set vb t_vb=                    "当vim进行编辑时，如果命令错误，会发出警报，该设置去掉警报"
set ruler                       "在编辑过程中，在右下角显示光标位置的状态行"
set incsearch                   "在程序中查询一单词，自动匹配单词的位置；如查询desk单词，当输到/d时，会自动找到第一个d开头的单词，当输入到/de时，会自动找到第一个以ds开头的单词，以此类推，进行查找；当找到要匹配的单词时，别忘记回车"
set backspace=2                 "设置退格键可用"
```

## Tmux 
### Default Configurations
save to ~/.tmux.conf
```python
# remap prefix to Control + a
#set -g prefix C-a
#unbind C-b
#bind C-a send-prefix
# force a reload of the config file
#unbind r
#bind r source-file ~/.tmux.conf
# quick pane cycling
#unbind ^A
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
# window splitting
bind-key v split-window -h
bind-key s split-window -v
# Shift arrow to switch windows
bind -n S-Left previous-window
bind -n S-Right next-window
set-window-option -g aggressive-resize on
```

### Scripts for installing stand alnoe tmux
```
# Script for installing tmux on systems where you don't have root access.
# tmux will be installed in $HOME/local/bin.
# It's assumed that wget and a C/C++ compiler are installed.

# exit on error
set -e

TMUX_VERSION=2.9a
LIBEVENT_VERSION=2.1.8-stable
NCURSES_VERSION=6.1


# create our directories
mkdir -p $HOME/local $HOME/tmux_tmp
cd $HOME/tmux_tmp

# download all the files
wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
wget https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/libevent-${LIBEVENT_VERSION}.tar.gz
wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz

############
# libevent #
############
tar xvzf libevent-${LIBEVENT_VERSION}.tar.gz
cd libevent-${LIBEVENT_VERSION}
./configure --prefix=$HOME/local --disable-shared
make
make install
cd ..

############
# ncurses  #
############
tar xvzf ncurses-${NCURSES_VERSION}.tar.gz
cd ncurses-${NCURSES_VERSION}
./configure --prefix=$HOME/local
make 
make install
cd ..

############
# tmux     #
############
tar xvzf tmux-${TMUX_VERSION}.tar.gz
cd tmux-${TMUX_VERSION}
./configure CFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-L$HOME/local/lib -L$HOME/local/include/ncurses -L$HOME/local/include"
CPPFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-static -L$HOME/local/include -L$HOME/local/include/ncurses -L$HOME/local/lib" make
cp tmux $HOME/local/bin
cd ..

cd $HOME

# cleanup
rm -rf $HOME/tmux_tmp

echo "$HOME/local/bin/tmux is now available. You can optionally add $HOME/local/bin to your PATH."

# for the in order to add to the .bashrc (for /sh/bash) comment-in below line
# echo 'export PATH="$HOME/local/bin:$PATH"' >> $HOME/.bashrc
```

## stand-alone code server installation
https://github.com/cdr/code-server/blob/v3.5.0/doc/install.md#standalone-release

```bash
# Sample of .config/code-server/config.yaml
bind-addr: 0.0.0.0:16666
auth: password
password: 281117
cert: false
```

## Others
For google drive download on commmand line
https://github.com/wkentaro/gdown