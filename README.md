Create Initrd for Crypto Keyfiles
---------------------------------

    # dd if=/dev/urandom of=./crypto_keyfiles/my_keyfile_01.bin bs=1024 count=4
    
    # cryptsetup luksAddKey /dev/sdXY ./crypto_keyfiles/my_keyfile_01.bin

    # ./scripts/make_initrd_for_keys.sh crypto_keyfiles/ /mnt/boot/initrd.keys.gz
