1. use a program to create a custom linux bootable usb key
2. add the software called memtest86 to test the ram as you cannot test ram while booted on a usb key, since linux is loading into the ram when booting from a usb key
3. copy paste the .sh file anywhere on the usb key
4. connect the usb key to a computer you wish to erase data on
5. boot onto the usb key
6. use memtest86 to test the ram
7. install the dependancies using the following command in the terminal  :  

sudo apt update && sudo apt install smartmontools nvme-cli GnuPG openssh-client -y

8.  rendez le script exécutable avec la commande : 

chmod +x nist-wipe.sh

9. exécutez le script en utilisant : 

sudo ./nist-wipe.sh /dev/*répertoire du disque 

par exemple : 

sudo ./nist-wipe.sh /dev/sdb pour votre disque primaire ou 
sudo ./nist-wipe.sh /dev/sdc pour un disque secondaire


