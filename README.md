# firmware-chroot-docker  

This is a script to extract a firmware file (.zip, .bin, .tar) and create a dockerfile to mount it in.
This will allow you to mount firmware in a docker container for running the built in webserver (router firmware for example), exploration within local files, and blasting it with automated testing (linpeas, etc)

Requires:  
binwalk, ubi_reader, docker

The Dockerfile section needs to be updated to work properly, and I'll be updating it to handle weird extraction formats.

### script steps:
Unzip tar, zip, etc of firmware file with binwalk   
Find directories containing root (/etc/ /usr/)  
Create a mountable area for docker and create dockerfile  
