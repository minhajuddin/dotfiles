#copy files to a remote computer's temp directory
o(){
  gnome-open "$@" &>/tmp/generic.log
}
cpr(){
  scp $2 $1:/tmp
}
cpl(){
  scp $2 minhajuddin@192.168.1.$1:/tmp
}
ssl(){
  ssh minhajuddin@192.168.1.$1
}

tz(){
  tar cf - $1 | gzip > $(basename $1).tar.gz
}


bak(){
  cp $1 $1.$(date +%Y%m%d%H%M%S)
}


rem(){
  (sleep $((60 * $1 )) && notify-send --urgency=low -i 'terminal' $2)&
}

__show_files(){
  cat <(find ~/repos  -maxdepth 1  -type d) <(find ~/repos/core  -maxdepth 1  -type d) <(find ~/repos/os  -maxdepth 1  -type d) <(find ~/repos/core/omar  -maxdepth 1  -type d)
}

#change to repository directory
cr(){
  cd $(__show_files | grep $1)
  echo "in $(pwd)"
}

#ex     : Extract files from any archive
ex(){
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2) tar xjf $1
        ;;
      *.tar.gz) tar xzf $1
        ;;
      *.bz2) bunzip2 $1
        ;;
      *.rar) rar x $1
        ;;
      *.gz) gunzip $1
        ;;
      *.tar) tar xf $1
        ;;
      *.tbz2) tar xjf $1
        ;;
      *.tgz) tar xzf $1
        ;;
      *.zip) unzip $1
        ;;
      *.Z) uncompress $1
        ;;
      *.7z) 7z x $1
        ;;
      *) echo "'$1' cannot be extracted via extract()"
        ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


#cd to the directory of arg
cdd(){
  cd $(dirname "$@")
}

# make a directory and cd to it
mkcd()
{
  mkdir "$1" && cd "$1"
}

mtd() {
  mkcd /tmp/`date +%y%m%d-%H%M%S-%N`;
  pwd;
}

mtcd() {
  cd $(mtd);
  echo "in $(pwd)"
}

function cdup() {
ups=""
for i in $(seq 1 $1)
do
  ups=$ups"../"
done
cd $ups
}


function webshot(){
curl 'http://wti.heroku.com/convert' -G --data-urlencode "site_url=$1" -o "$(echo $1 | sed -e 's/[^a-zA-Z]//g' | sed -e 's/^http//g').jpg"
}

function vo(){
gvim --remote-silent $(type -P $1)
}

function vio(){
vim $(type -P $1)
}

function pyg(){
tmp_file="/tmp/$(basename $1).html"
cp $1 $tmp_file
vim $tmp_file
pygmentize -f html -l $2 $tmp_file
}

function ccr(){
if [[ $# -eq 0 ]]
then
  return
fi

file=$1

cc $file -o "$file.out"
"./$file.out"
}


function exit_if_not_in_sync(){
  repos=("dotfiles" "linktub"  "timberexpress"  "school_one")
  ret=0
  for repo in ${repos[@]}
  do
    cd "/home/minhajuddin/repos/$repo"
    if [ $(git log master -1 --format='%h') = $(git log origin/master -1 --format='%h') ]
    then 
      echo "$repo in sync"
    else 
      echo "$repo not in sync"
      ret=1
    fi
  done
}

function ghalt(){
  echo "===================="
  echo "===================="
  echo "===================="
  echo "FINISH: PRINTING HOURS SINCE LAST LOG!!!!!!!! AND ACTUALLY DON'T SHUTDOWN TILL THE LOG FOR LAST 5 MINS IS DONE"
  echo "===================="
  echo "===================="
  echo "===================="
  if [ "$1" = 'force' ]
  then
    sudo /usr/lib/indicator-session/gtk-logout-helper --shutdown
  fi
  /home/minhajuddin/.scripts/sync-repos
  sudo /usr/lib/indicator-session/gtk-logout-helper --shutdown
}


gla()
{
  echo "$(date "+%Y-%m-%d %H:%M"): $(tail -1 ~/.timelog.txt | sed -e 's/^[0-9 :-]*//g')" >> ~/.timelog.txt
}
