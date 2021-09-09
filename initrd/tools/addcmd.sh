# Add commands with the dependencies required
# to the current directory as root.

addto_wd() {
  WORK_DIR=$(pwd)
  root=${1%/*}
  file=${1##*/}

  if [[ ! -d $WORK_DIR$1 ]]; then
    if [[ ! -d $WORK_DIR$root ]]; then
      mkdir -p $WORK_DIR$root
    fi
    cp $1 $WORK_DIR$1
  fi
}

for arg in $@; do
  if [[ $arg =~ "/" ]]; then  # is path
    path=$arg
  else  # is command
    path=$(which $arg)
  fi
  echo $path
  addto_wd $path
  # ldd $path

  for line in $(ldd $path); do
    if [[ ${line:0:1} == '/' ]]; then
      echo $line
      addto_wd $line
    fi
  done
done
