#!/usr/bin/env bash
set -euo pipefail

# check if root
if [[ $EUID -ne 0 ]]; then
	echo "Vous devez éxecuter ce script en tant que root !"
	exit 1
fi

if [ $(basename "`pwd`") != "custom-rpi-os" ]; then
	echo "Merci de lancer le script dans son répertoire"
	exit 1
fi

if [ ! -d src ]; then
        mkdir src
fi

# Vérification des sources
if [ ! -f src/busybox-1.33.0.tar.bz2 ]; then
	wget "https://busybox.net/downloads/busybox-1.33.0.tar.bz2" -O src/busybox-1.33.0.tar.bz2
fi

if [ ! -f src/tools.zip ]; then
	wget "https://github.com/raspberrypi/tools/archive/master.zip" -O src/tools.zip
fi

if [ -d build ]; then
	read -p "Supprimer build ? [y-n] " build
	if [ $build == "y" ]; then
		rm -rf build
	fi
fi

mkdir -p build

if [ ! -d data ]; then
	mkdir data
fi

read -p "Entrez l'identifiant du périphérique à rendre bootable (/dev/sdX) (juste le sdX) " device
export device=/dev/$device
echo "device : "$device



# démontage de toutes les partitions montée
if grep $device -q /etc/mtab; then
	grep $device /etc/mtab | awk '{print $2}' | xargs -I '{}' umount '{}'
fi

declare -a partitions=()

read -p "Formater le périphérique ? [y-n] " format
if [ $format == "y" ]; then
	# zap du périphérique
	echo "Vidage de la clef"
	sgdisk --zap-all $device
	dd if=/dev/zero of=$device bs=512 count=4096

	# scan des nouvelles partitions
	partprobe

	wipefs --all --force $device
	if [ -f data/format.sfdisk ]; then
		read -p "Créer une nouvelle configuration ? [y-n] " config
		if [ $config == "y" ]; then
			fdisk $device
			sfdisk -d $device > data/format.sfdisk
		else
			sfdisk $device < data/format.sfdisk
		fi
	else
		fdisk $device
		sfdisk -d $device > data/format.sfdisk
	fi

	partprobe

	# pause
	sleep 3

	partitions=(`fdisk -l | grep $device | awk '{if(NR>1)print $1}'`)
	mkfs.vfat -F32 -n boot ${partitions[0]}
	mkfs.ext4 -L rootfs ${partitions[1]}
fi

if [ ${#partitions[@]} -eq 0 ]; then
	partitions=(`fdisk -l | grep $device | awk '{if(NR>1)print $1}'`)
fi

echo "montage des partitions"
export boot=/mnt/boot
export rootfs=/mnt/rootfs

mkdir -p $boot $rootfs

mount ${partitions[0]} $boot
mount ${partitions[1]} $rootfs

# copie part boot
read -p "Copier partition boot ? (y/n) " cpboot
if [ $cpboot == "y" ]; then
	unzip required/boot -d build
	cp -r build/boot/* $boot
fi

read -p "Copier cmdline.txt ? (y/n) " cmdline
if [ $cmdline == "y" ]; then
	cp data/cmdline.txt $boot
fi

read -p "Copier config.txt ? (y/n) " config
if [ $config == "y" ]; then
	cp data/config.txt $boot/config.txt
fi

PATH_CC=$(pwd)"/build/tools-master/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin"
PREFIX_CC=$PATH_CC"/arm-linux-gnueabihf-"

# extraction des outils
if [ ! -d "build/tools-master" ]; then
	echo "extraction des tools"

	unzip src/tools -d build
fi

# création des dossiers non créés par busybox
if [ ! -d "build/busybox-1.33.0" ]; then
	echo "extraction de l'archive busybox"

	tar xC build -f src/busybox-1.33.0.tar.bz2

	echo "compilation busybox"

	pushd build/busybox-1.33.0/
		make menuconfig
		make CROSS_COMPILE=$PREFIX_CC -j9
	popd
fi

echo "installation de busybox sur la clef"

pushd build/busybox-1.33.0
	make CROSS_COMPILE=$PREFIX_CC CONFIG_PREFIX=$rootfs install
popd

echo "Création /dev busybox"
mkdir -p $rootfs/dev; 
pushd $rootfs/dev; 
	/sbin/MAKEDEV generic console
popd
mkdir -p $rootfs/etc/init.d $rootfs/proc $rootfs/sys $rootfs/root/run $rootfs/root/proc $rootfs/root/sys $rootfs/run $rootfs/lib $rootfs/lib64


# echo "copie des librairies"
# copie des libs de lib
# copie des libs de lib64
# ./$(PREFIX_CC)"ldd" $rootfs/bin/busybox | grep '/lib/' | awk '{print $3}' | xargs -I '{}' cp -v '{}' $rootfs/lib
# ./$(PREFIX_CC)"ldd" $rootfs/bin/busybox | grep "/lib64/" | awk '{print $1}' | xargs -I '{}' cp -v '{}' $rootfs/lib64

read -p "Copier les librairies croisées ? (y/n) " librairies
if [ $librairies == "y" ]; then
	cp -r $($PATH_CC/arm-linux-gnueabihf-gcc -print-sysroot)/lib/arm-linux-gnueabihf/* $rootfs/lib
fi

echo "copie du script inittab"
cp data/inittab $rootfs/etc/inittab

echo "création du scrip sh rcS"

cp data/rcS $rootfs/etc/init.d/rcS
chmod +x $rootfs/etc/init.d/rcS

echo "Mise en place keymap"
cp data/azerty.kmap $rootfs/etc/french.kmap
