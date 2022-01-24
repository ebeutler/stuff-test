#!/bin/bash
echo 'importing zfs-tools ...'

echo '... imported showFirstSnap($dataset)'
function showFirstSnap() {
  [ -z "$1" ] && echo 'no dataset provided' && return 1
  snap=$(zfs list -H -t snapshot -o name -s creation $1 | head -n1)
  echo "[$1] ${snap:-none}"
}

echo '... imported showLastSnap($dataset)'
function showLastSnap() {
  [ -z "$1" ] && echo 'no dataset provided' && return 1
  snap=$(zfs list -H -t snapshot -o name -s creation $1 | tail -n1)
  echo "[$1] ${snap:-none}"
}

echo '... imported forEachDataset($command)'
function forEachDataset() {
  [ -z "$1" ] && echo 'no command provided' && return 1
  for dataset in $(zfs list -H -o name); do
    $1 $dataset 
  done
}

echo '... imported renameSnaps($sedReplace $grepFilter)'
## e.g. p53/test@auto_monthly-2022-01-22-1232 -> p53/test@autosnap_2022-01-22_12:32:00_monthly
## $sedReplace: 's/auto_([a-z]*)-([0-9\-]*)-([0-9]{2})([0-9]{2})$/autosnap_\2_\3:\4:00_\1/'
## $grepFilter: 'p53/test@auto_'
function renameSnaps() {
  [ -z "$1" ] && echo 'no sed replace provided' && return 1
  [ -z "$2" ] && echo 'no grep filter provided' && return 1
  for oldname in $(zfs list -H -t snapshot -o name | grep "$2"); do
    newname=$(echo $oldname | sed -E "$1")
    [ -n "$newname" ] && [ "$newname" != "$oldname" ] \
      && echo "$oldname -> $newname" \
      && [ "$doItNow" == "true" ] \
      && sudo zfs rename $oldname $newname
  done
  unset doItNow
}
