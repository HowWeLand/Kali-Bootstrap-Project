 1. Identify drives    lsblk
 2. Export Shell variables for safe drive handling export ROOTDRIVE=/dev/nvme0n1 export HOMEDRIVE=/dev/sda export BOOTDRIVE=/dev/sdd
 3. echo $ROOTDRIVE && echo $HOMEDRIVE && echo $BOOTDRIVE
 4. parted 
 5. made keyfile 4kb 0600 perms
 6. LUKS2 with backed up headers
 7. Tested if luks nuke password works on live initramfs
 8. Nope  
 9. Partitioning 
 10. debootstrap
 11. Cryptsetup Hell
 12. Fuck it OpenRC
 13. Just fucking works
 14. Better to start from the beginning tho
 15. need orphan-scripts package
 16. need to look into utrans and utrans rc
 17. also check gentoo ebuilds for service files I can steal, err repurpose under open source licenses