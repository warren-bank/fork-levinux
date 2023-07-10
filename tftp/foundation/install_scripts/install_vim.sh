#!/bin/sh

clear
selection=
until [ "$selection" = "0" ]; do
echo -e "\e[1;33mVim Installer Script\e[00m"
echo ""
echo -en "\e[1;32mEnter \e[1;37m1\e[1;32m to Exit or \e[1;37m2\e[1;32m to install Vim:\e[00m "
read selection
    case $selection in
        1 ) clear
            exit
            ;;
        2 ) clear
            echo -e "\e[1;37mInstalling Vim...\e[0;37m"
            tce-load -wi vim
            tftp -g -l /home/tc/.vimrc -r /foundation/extensions/vim/.vimrc 10.0.2.2
            echo "usr/local/share/vim/vim80/syntax/python.vim" >> /opt/.filetool.lst
            sudo filetool.sh -b
            echo ""
            echo -e "\e[1;37mVim is now installed.\e[0;37m"
            echo ""
            exit
            ;;
    esac
done
exit 0
