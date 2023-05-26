#!/bin/bash

# Requires
    # binwalk - available with your package manager
    # ubi_reader
    # pip install --user ubi_reader

WORKING_DIRECTORY="./"
mkdir -p output
mkdir -p output/extracted
mkdir -p extracted

ls "$WORKING_DIRECTORY"

# Is binwalk even needed? If we purely do the "ADD" with the dockerfile, we may be able to mount it that way

# need to put fucking case statements here
for file in *.zip; do
    unzip "$file" -d ./extracted
done

# do firmware blobs use fucking elf?
for file in *.hex; do
    continue
done

# fucking tar
for file in *.tar; do
    tar xvf "$file" ./extracted
done

# binary
for file in *.bin; do
    binwalk "$file" ./extracted
done

binwalk -Me ./*

# Traverse the extracted directory
for dir in $(find . -type d); do
    if [[ $dir == *"/usr"* || $dir == *"/var"* || $dir == *"/etc"* ]]; then
        mv "$(dirname "$dir")" $WORKING_DIRECTORY/root
        break
    fi
done

# Create Dockerfile
cat > Dockerfile <<EOL
# Source
# https://www.youtube.com/watch?v=ALn0hUxNszI
# We include this line so we can reference it later
FROM multiarch/debian-debootstrap:mips-buster-slim as qemu

# Actual Steps
FROM scratch
ADD ./root /
COPY --from=qemu /usr/bin/qemu-mips-static /usr/bin
CMD ["/usr/bin/qemu-mips-static", "bin/busybox"]
ENV Arch=mips
EOL

echo "Dockerfile created."
echo "Information about the Docker container (e.g., Dockerfile template) here"

rm -r output
rm -r extracted
rm -r *.extracted

arch=$(lscpu | grep Architecture | awk '{print $2}')

case $arch in
    x86_64)
        # Code to execute when architecture is x86_64
        echo "x86_64 architecture detected"

        # Additional check for mips
        if lscpu | grep -q mips; then
            # Code to execute when mips is detected
            echo "mips architecture detected"
        fi

        # Additional check for arm
        if lscpu | grep -q arm; then
            # Code to execute when arm is detected
            echo "arm architecture detected"
        fi
        ;;
    *)
        # Code to execute for other architectures
        echo "Other architecture detected"
        ;;
esac

# docker build -t test .
# docker run -it test
