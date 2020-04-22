Create Initrd for Crypto Keyfiles
---------------------------------

    # dd if=/dev/urandom of=./crypto_keyfiles/my_keyfile_01.bin bs=1024 count=4
    # cryptsetup luksAddKey /dev/sdXY ./crypto_keyfiles/my_keyfile_01.bin
    # find ./crypto_keyfiles/*.bin -print0 | sort -z | cpio -o -H newc -R +0:+0 --reproducible --null | gzip -9 > /mnt/boot/initrd.keys.gz
    # chmod 000 /mnt/boot/initrd.keys.gz