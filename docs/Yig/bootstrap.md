# Yig - bootstrap

This system requires manual bootstrap.

## Base system

1. Download and flash Armbian to microSD XC
   1. https://www.armbian.com/orange-pi-5-plus/
   2. full ref: https://docs.armbian.com/User-Guide_Getting-Started/#how-to-boot
   3. may boot without screen
   4. go with bootstrap over network (root password)
2. Execute `armbian-config`:
   1. System -> Firmware -> run all updates including firmware, reboot
   2. ensure middle HDMI port outputs 4K and NVMe disk is visible
3. Set hostname: `hostnamectl set-hostname yig.home.dds`
4. Disable zswap so M.2 port can be used as normal storage: set 2x `false` in `/etc/default/armbian-zram-config`

ncdu
cryptsetup
jq

## ZeroTier

```bash
curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/main/doc/contact%40zerotier.com.gpg' | gpg --import && \  
if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi

zerotier-cli info # get node id
zerotier-cli join $net_id
zerotier-cli listnetworks
```

## Extra storage

### Encrypted NVMe

1. Install `/etc/crypttab` from previous builds (`data UUID=... /etc/luks-keys/data_key luks`)
2. Install `/etc/luks-keys/data_key` from previous builds
3. Append `/dev/mapper/data /data btrfs defaults,nosuid 0 0` to `/etc/fstab`
4. Reboot and validate that `/data/` appears with data

### Backups over network

1. Deploy `/etc/systemd/system/mnt-backups.mount` with following:

```
[Unit]
Description=backups mount

[Mount]
What=//####/yig/backups
Where=/mnt/backups
Type=cifs
Options=rw,vers=3,noauto,x-systemd.automount,_netdev,file_mode=0600,dir_mode=0700,dom=####,username=####,password=####
DirectoryMode=0700

[Install]
WantedBy=multi-user.target
```

2. Deploy `/etc/systemd/system/mnt-backups.automount` with following:

```
[Unit]
Description=backup automount

[Automount]
Where=/mnt/backups

[Install]
WantedBy=multi-user.target
```

3. Call `systemctl enable mnt-backups.mount`
4. Reboot and validate listing of `/mnt/backups`

## Core software

### Kopia

1. Install using https://kopia.io/docs/installation/#linux-installation-using-apt-debian-ubuntu
2. Initialize system repository:

```bash
mkdir /etc/kopia/
kopia repository create filesystem --path=/mnt/backups/kopia-system/ --config-file=/etc/kopia/kopia-system.config

export KOPIA_CONFIG_PATH=/etc/kopia/kopia-system.config
kopia policy set --global --ignore-identical-snapshots true
```

3. Deploy `/usr/local/bin/kopia_snapshot` as executable with following:

```
#!/bin/bash
export KOPIA_CONFIG_PATH=/etc/kopia/kopia-system.config

/usr/bin/kopia snapshot create /boot
/usr/bin/kopia snapshot create /etc
/usr/bin/kopia snapshot create /home
/usr/bin/kopia snapshot create /root
/usr/bin/kopia snapshot create /srv
/usr/bin/kopia snapshot create /usr/local
/usr/bin/kopia snapshot create /var/lib
/usr/bin/kopia snapshot create /var/spool
```

4. Append `3 33 * * * /usr/local/bin/kopia_snapshot` to crontab

### Other dependecies

```bash
apt install open-iscsi
```