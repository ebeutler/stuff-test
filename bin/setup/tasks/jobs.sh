#!/bin/bash

echo -e "\nSetup Jobs ..."
[ $EUID -ne 0 ] \
  && echo 'skipped, requires root' \
  && exit 1
! command -v systemctl >/dev/null \
  && ! systemctl status &>/dev/null \
  && echo 'skipped, systemd unavailable' \
  && exit 1

unitDir=/opt/msladek/stuff/etc/systemd
etcHostDir=/opt/msladek/stuffp/etc/$(hostname)

# make the file immutable by other users, sets sticky bit on parent dir
function claim() {
  for file in $1; do
    [ -n "$file" ] && [ -f "$file" ] \
      && chown "$USER" "$(dirname "$file")" && chmod 1775 "$(dirname "$file")" \
      && chown "$USER" "$file" && chmod 644 "$file" \
      && { [[ $file != *.sh ]] || chmod +x "$file"; }
  done
}

function installFile() {
  claim "$1" && ln -sf "$1" "$2"
}

function installUnit() {
  for unit in $1; do
    claim "$(grep "^ExecStart=.*\.sh" "$unit" | cut -c11- | cut -d' ' -f1 | uniq)"
    installFile "$unit" /etc/systemd/system/
  done
}

function installTimedService() {
  [ -d "$(dirname "$1")" ] \
    && installUnit "${1}*.service" \
    && installUnit "${1}*.timer" \
    && systemctl daemon-reload
}

function installEnableTimedService() {
  installTimedService "$1" \
    && for timer in ${1}*.timer; do \
        systemctl enable "$(basename "$timer")"; \
       done \
    && echo "done" || { echo "failed" && false; }
}

echo "... notify status"
installUnit $unitDir/notify-status@.service

echo "... hosts file update"
installEnableTimedService $unitDir/hosts-update \
  && rm -f /etc/cron.weekly/hosts-update

echo "... filesytem trim"
installEnableTimedService $unitDir/fstrim \
  && rm -f /etc/cron.weekly/fstrim

echo "... OS sync"
if [ -w /mnt/backup/os ]; then
  installEnableTimedService $unitDir/os-rsync \
    && rm -f /etc/cron.weekly/os-rsync
else
  echo "skipped, /mnt/backup/os not linked"
fi

echo "... smart attribute dump"
if [ -w /mnt/backup/smart ]; then
  installEnableTimedService $unitDir/smart-dump
else
  echo "skipped, /mnt/backup/smart not linked"
fi

echo "... database dump"
if [ -w /mnt/backup/mysql ] && [ -f /etc/mysql/debian.cnf ]; then
  installEnableTimedService $unitDir/mysql-dump
else
  echo "skipped, /mnt/backup/mysql not linked"
fi

if ! command -v zpool > /dev/null || [ "$(zpool list -H | wc -l)" -eq 0 ]; then
  echo "skipped zfs setup, no pools available"
else
  echo "... zfs health check"
  installEnableTimedService $unitDir/zfs-health \
    && rm -f /etc/cron.hourly/zfs-health

  echo "... zfs keystatus"
  installTimedService $unitDir/zfs-keystatus
  for dataset in $(zfs get encryptionroot -H -ovalue -tfilesystem | uniq); do
    zfs list -H -o name | grep -qF -- "${dataset}" \
      && echo "${dataset}" \
      && systemctl enable "zfs-keystatus@${dataset/\//_}.timer"
  done

  echo "... sanoid"
  if command -v sanoid > /dev/null; then
    mkdir -p /etc/sanoid
    [ ! -f /etc/sanoid/sanoid.defaults.conf ] \
      && ln -s /usr/share/sanoid/sanoid.defaults.conf /etc/sanoid/sanoid.defaults.conf
    installFile "$etcHostDir/sanoid.conf" /etc/sanoid/sanoid.conf \
      && systemctl enable sanoid.timer \
      && rm -f /etc/cron.d/sanoid
  else
    echo "skipped, sanoid not available"
  fi

  echo "... syncoid"
  if command -v syncoid > /dev/null; then
    installEnableTimedService "$etcHostDir/systemd/syncoid"
  else
    echo "skipped, syncoid not available"
  fi
fi
