# List infomation about all kernel modules
# with its filename, description and depends.

lsmod | while read line; do
  # echo $line
  if [[ "${line:0:6}" != "Module" ]]; then
    echo $line
    module=${line%% *}
    # echo $module
    echo "  "$(modinfo $module | grep filename)
    echo "  "$(modinfo $module | grep description)
    echo
  fi
done
