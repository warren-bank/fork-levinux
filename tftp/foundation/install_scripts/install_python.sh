#!/bin/sh

clear
selection=
until [ "$selection" = "0" ]; do
echo -e "\e[1;33mPython 3.5 Installer Script\e[00m"
echo ""
echo -en "\e[1;32mEnter \e[1;37m1\e[1;32m to Exit or \e[1;37m2\e[1;32m to install Python 3.5:\e[00m "
read selection
    case $selection in
        1 ) clear
            exit
            ;;
        2 ) clear
            echo -e "\e[1;34m"
            echo "---------------------------------------------------"
            echo "         ____        _   _                 "
            echo "        |  _ \ _   _| |_| |__   ___  _ __  "
            echo "        | |_) | | | | __| '_ \ / _ \| '_ \ "
            echo "        |  __/| |_| | |_| | | | (_) | | | |"
            echo "        |_|    \__, |\__|_| |_|\___/|_| |_|"
            echo "               |___/                       "
            echo ""
            echo -e "\e[1;36mPlease have patience while Python 3.5 is installed.\e[00;34m"
            echo "---------------------------------------------------"
            echo -e "\e[00m"
            echo ""

            echo -e "\e[1;37mInstalling Python 3.5...\e[0;37m"
            # tce-load -wi python > /dev/null
            tce-load -wi python3.5-dev
            sudo ln "/usr/local/bin/python3.5" "/usr/local/bin/python"

            echo -e "\e[1;37mInstalling Python Setuptools...\e[0;37m"
            cd '/home/tc'
            # [note] wget is included in TCL distro, but returns: 421 Misdirected Request
            ./install_scripts/install_curl.sh
            curl -o 'ez_setup.py' 'https://bootstrap.pypa.io/ez_setup.py'
            sudo python ez_setup.py > /dev/null 2>&1

            echo -e "\e[1;37mUsing Setuptools to update pip...\e[0;37m"
            sudo easy_install pip > /dev/null 2>&1

            echo -e "\e[1;37mMaking Python extensions persistent...\e[0;37m"
            echo "usr/local/bin/easy_install"             >> '/opt/.filetool.lst'
            echo "usr/local/bin/pip"                      >> '/opt/.filetool.lst'
            echo "usr/local/bin/python"                   >> '/opt/.filetool.lst'
            echo "usr/local/lib/python3.5/site-packages/" >> '/opt/.filetool.lst'
            sudo filetool.sh -b

            echo ""
            echo -e "\e[1;37mPython 3.5 is now installed.\e[0;37m"
            echo ""
            exit
            ;;
    esac
done
exit 0
