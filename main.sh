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

for file in *.zip; do
    unzip "$file" -d ./extracted
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

# docker build -t test .
