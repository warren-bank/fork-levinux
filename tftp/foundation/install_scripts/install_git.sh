#!/bin/sh

clear
selection=
until [ "$selection" = "0" ]; do
echo -e "\e[1;33mGit Installer Script\e[00m"
echo ""
echo -en "\e[1;32mEnter \e[1;37m1\e[1;32m to Exit or \e[1;37m2\e[1;32m to install Git:\e[00m "
read selection
    case $selection in
        1 ) clear
            exit
            ;;
        2 ) clear
            echo -e "\e[1;37mInstalling Git...\e[0;37m"
            echo "export GIT_SSL_NO_VERIFY=true" >> '/home/tc/.ashrc'
            tce-load -wi git
            echo ""
            echo -e "\e[1;37mGit is now installed.\e[0;37m"
            echo ""
            exit
            ;;
    esac
done
exit 0
