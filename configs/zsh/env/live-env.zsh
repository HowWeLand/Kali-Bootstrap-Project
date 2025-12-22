# Always change to current drive configuration. Could use UUID for consistency but 
# expect everyone to be adults and label their stuff.  Check before you run  
# I personally tile my terminals or multiplex in tty/ssh
# and stack this with the output from lsblk
# This mostly to allow me to rapidly mount and chroot into the bootstrap environment using one script.
export ROOTDRIVE=/dev/nvme0n1
export HOMEDRIVE=/dev/sda
export BOOTDRIVE=/dev/sdc1
mkdir -p /tmp/bootkey
# These will never change because that is what I name root and home partitions after the are unlocked always
export CRYPTROOT=/dev/mapper/cryptroot
export CRYPTHOME=/dev/mapper/crypthome
sudo mount  $BOOTDRIVE /tmp/bootkey
if [[ ! -e /dev/mapper/cryptroot ]]; then 
	sudo cryptsetup open ${ROOTDRIVE}p3 cryptroot --key-file /tmp/bootkey/keyfile
fi
if [[ ! -e /dev/mapper/crypthome ]]; then 
	sudo cryptsetup open ${HOMEDRIVE}1 crypthome --key-file /tmp/bootkey/keyfile
fi
sudo mount -v -o subvol=@ $CRYPTROOT /mnt
sudo mount -v /dev/disk/by-partlabel/boot /mnt/boot
sudo mount -v /dev/disk/by-partlabel/ESP /mnt/boot/efi
sudo mount -v -o subvol=@var@cache $CRYPTROOT /mnt/var/cache                    
sudo mount -v -o subvol=@var@log $CRYPTROOT /mnt/var/log                                                   
sudo mount -v -o subvol=@var@tmp $CRYPTROOT /mnt/var/tmp
sudo mount -v -o subvol=@opt $CRYPTROOT /mnt/opt
sudo mount -v -o subvol=@srv $CRYPTROOT /mnt/srv
sudo mount -v -o subvol=@usr@local $CRYPTROOT /mnt/usr/local
sudo mount -v -o subvol=@home $CRYPTHOME /mnt/home
sudo mount -v -o subvol=@var@lib@containers $CRYPTHOME /mnt/var/lib/containers
sudo mount -v -o subvol=@var@lib@libvirt@images $CRYPTHOME /mnt/var/lib/libvirt/images
sudo arch-chroot /mnt /bin/bash
