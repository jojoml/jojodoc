## Install oh my zsh

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
( cd $ZSH_CUSTOM/plugins && git clone https://github.com/chrissicool/zsh-256color )
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

Then change line in ~/.zshrc to
```
plugins=(git zsh-autosuggestions zsh-256color)
```
