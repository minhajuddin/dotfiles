This is a repo to track my dot files

1. To set it up on your computer run the following
  
  ~~~~bash
  git clone git://github.com/minhajuddin/dotfiles.git
  cd dotfiles
  ./setup
  ~~~~
2. Install the Bitstream Powerline font from https://gist.github.com/1695735/


## Xmonad setup
~~~~bash
#clone the dotfiles git repo in ~/repos/
git clone git://github.com/minhajuddin/dotfiles.git
#setup symlinks
cd ~/repos/dotfiles && ruby setup
#setup xsession
ln -s /home/minhajuddin/.xmonad/focus.desktop /usr/share/xsessions/focus.desktop
#tweak ~/.xmonad/focus.start install the remaining dependencies and create a local ~/.xmonad/$(hostname).start if needed
~~~~

![Xmonad Screenshot](http://i.imgur.com/8ibsI.png)