# My Dotfiles

run the following if you want ALL of my packages(it is a lot, this may take a LONG time)
```bash
cd ~
git clone "https://github.com/JadenMajid/dotfiles.git" ~/.config
sudo pacman -S $(cat packages.txt)
git clone https://aur.archlinux.org/yay-bin.git ~
cd ~/yay-bin
sudo pacman -S base-devel
makepkg -si
cd ~/.config
yay -S $(cat aurpackages.txt)
```
