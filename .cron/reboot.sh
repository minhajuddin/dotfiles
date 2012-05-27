#!/bin/bash
#script which is executed everytime computer starts

#make sure that there is a downlaods folder with the current timestamp
DOWNLOAD_DIR=~/media/downloads/$(date "+%Y%m")
if [[ ! -d $DOWNLOAD_DIR ]]
then
  mkdir -p $DOWNLOAD_DIR
  rm ~/media/downloads/current
  ln -ns $DOWNLOAD_DIR ~/media/downloads/current
fi

#git gc repos
REPO_DIRS=$(cat <<EOS
$HOME/repos
$HOME/repos/core
$HOME/repos/omar
EOS
)

for repo_dir in $REPO_DIRS
do
  echo "checking for git repos in $repo_dir"
  for repo in $(ls $repo_dir)
  do
    cd $repo_dir/$repo
    if [[ -d .git ]]
    then
      echo "garbage collecting $repo"
      git gc
      sleep 30
    fi
  done
done

echo 'backing up repos'
rsync -a --delete /home/minhajuddin/repos /home/minhajuddin/media/bak &> /home/minhajuddin/tmp/repobak.log

echo 'updating os'
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y
