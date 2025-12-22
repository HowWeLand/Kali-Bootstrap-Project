  * Can't actually do full drive encryption in uefi
  * usb2 to slow for boot key
  * intially named crypthome home fixed for consistency with cryptroot
  * cryptsetup-nuke-password does not work from live 
  * USB 2.0 Not worth using, too slow.  
  * with nvme partition number starts with p
  * cdebootstrap failed
  * debootstrap needs kali-archive-keyring add
  * toram + persistence no beuno
  * let snapper create @.snapshots directory
  * should have installed snapper at the beginning after bootstrap
  * should also have included btrfs-progs
  * Systemd failure, egg on face switch up
  * OpenRC conversion required mupltiple apt download and dpkg --force-all foo_wildcard.deb bar_wildcard.deb sessions
  * Fuck the openrc gitrepo is useful as fuck, wish I would have checked it first