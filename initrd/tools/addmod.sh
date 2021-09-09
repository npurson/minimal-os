# Add kernel modules with dependencies
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

addmod() {
  fileline=$(modinfo $1 | grep filename)
  path=${fileline##* }
  if [[ ! -e $(pwd)$path ]]; then
    echo $1": "$path
    addto_wd $path
  fi
}

addmod_withdeps() {
  depsline=$(modinfo $1 | grep depends)
  depends=${depsline##* }
  for dep in ${depends//,/ }; do
    addmod_withdeps $dep
  done

  addmod $1
}

for mod in $@; do
  addmod_withdeps $mod
done
