#!/usr/bin/env bash

SCRIPT="$(realpath "$0")"
SCRIPT_NAME="$(basename "$SCRIPT")"

if [[ $(id -u) != 0 ]]; then
	echo >&2 "Please run as root"
	exit 1
fi

if [[ $# != 2 ]]; then
	echo >&2 "Usage:"
	echo >&2 "  ${SCRIPT_NAME} <path-to-keyfiles-dir> <path-to-initrd>"
	echo >&2 ""
	echo >&2 "Example:"
	echo >&2 "  ${SCRIPT_NAME} ./crypto_keyfiles /mnt/boot/initrd.keys.gz"
	exit 1
fi

keyfiles_dir="$1"
initrd_path="$2"
initrd_dir="$(dirname "$initrd_path")"
if [[ ! -d $initrd_dir ]]; then
	echo >&2 "ERROR: Directory \"${initrd_dir}\" does not exist"
	exit 1
fi
initrd_dir="$(dirname "$(realpath "$initrd_path")")"


cd "$keyfiles_dir" || (
	echo >&2 "ERROR: Path \"${keyfiles_dir}\" is not a directory"
	exit 1
)


declare -a keyfiles
mapfile -t keyfiles < <(find ./*.bin -print0 | sort -z)

for f in "${keyfiles[@]}"; do
	echo " - ${f}"
done

echo "Changing keyfile modes to 000"
chmod 000 "${keyfiles[@]}"

echo "Generating initrd:"
echo -n "${keyfiles[@]}" \
	| cpio -o -H newc -R +0:+0 --reproducible --null \
	| gzip -9 > "$initrd_path" || exit $?

echo "Changing mode of new initrd to 000"
chmod 000 "$initrd_path" || exit $?

echo "OK"

