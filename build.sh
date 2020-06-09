#!/bin/bash

# Directories and Files
LIBDIR=./tools/lib/
LIBAFA=libaudiofile.a
LIBAFLA=libaudiofile.la
AUDDIR=./tools/audiofile-0.3.6
MASTER=./sm64pc-master/
MASTER_GIT=./sm64pc-master/.git/
MASTER_OLD=./sm64pc-master.old/baserom.us.z64
NIGHTLY=./sm64pc-nightly/
NIGHTLY_GIT=./sm64pc-nightly/.git/
ROM_CHECK=./baserom.us.z64
NIGHTLY_OLD=./sm64pc-nightly.old/baserom.us.z64
BINARY=./build/us_pc/sm64*
FOLDER_PLACEMENT=C:/sm64pcBuilder
MACHINE_TYPE=`uname -m`
PULL=$(git pull https://github.com/gunvalk/sm64pcBuilder 2> /dev/null)

# Command line options
MASTER_OPTIONS=("Analog Camera" "No Draw Distance" "Texture Fixes" "Remove Extended Options Menu | Remove additional R button menu options" "Clean build | This deletes the build folder")
MASTER_EXTRA=("BETTERCAMERA=1" "NODRAWINGDISTANCE=1" "TEXTURE_FIX=1" "EXT_OPTIONS_MENU=0" "clean")
NIGHTLY_OPTIONS=("Analog Camera" "No Draw Distance" "Texture Fixes" "Allow External Resources" "Remove Extended Options Menu | Remove additional R button menu options" "OpenGL 1.3 Renderer | Unrecommended. Only use if your machine is very old" "Clean build | This deletes the build folder")
NIGHTLY_EXTRA=("BETTERCAMERA=1" "NODRAWINGDISTANCE=1" "TEXTURE_FIX=1" "EXTERNAL_DATA=1" "EXT_OPTIONS_MENU=0" "LEGACY_GL=1" "clean")

# Extra dependency checks
DEPENDENCIES=("make" "git" "zip" "curl" "unrar" "mingw-w64-i686-gcc" "mingw-w64-x86_64-gcc" "mingw-w64-i686-glew" "mingw-w64-x86_64-glew" "mingw-w64-i686-SDL2" "mingw-w64-x86_64-SDL2")

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# Checks for common required executables (make, git) and installs everything if they are missing
if  [[ ! $(command -v make) || ! $(command -v git) ]]; then
	echo -e "\n${RED}Dependencies are missing. Proceeding with the installation... ${RESET}\n" >&2
	pacman -Sy --needed base-devel mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain \
                    git subversion mercurial \
                    mingw-w64-i686-cmake mingw-w64-x86_64-cmake --noconfirm
    pacman -S mingw-w64-i686-glew mingw-w64-x86_64-glew mingw-w64-i686-SDL2 mingw-w64-x86_64-SDL2 mingw-w64-i686-python-xdg mingw-w64-x86_64-python-xdg python3 zip curl --noconfirm
	pacman -Syuu --noconfirm
fi

# Checks for some dependencies again
echo -e "\n${YELLOW}Checking dependencies... ${RESET}\n"
for i in ${DEPENDENCIES[@]}; do
	if [[ ! $(pacman -Q $i 2> /dev/null) ]]; then
		pacman -S $i --noconfirm
	fi
done

echo -e "\n${GREEN}Dependencies are already installed. ${RESET}\n"

# Delete their setup or old shit
if [ -f $HOME/build-setup.sh ]; then
	rm $HOME/build-setup.sh
fi

if [ -f $HOME/build.sh ]; then
	rm $HOME/build.sh
fi

# Update check
if [ "$PULL" = "Already up to date." ]; then
	echo -e "\n${GREEN}build.sh is up to date\n${RESET}"
else
	echo -e "\n${YELLOW}Updating build.sh\n${RESET}"
	git stash push
	git stash drop
	git pull https://github.com/gunvalk/sm64pcBuilder
	echo -e "\n${GREEN}Restarting...${RESET}\n"
	sleep 2
	exec ./build.sh $1
fi
echo -e "\n"

# Update message
echo \
"${YELLOW}==============================${RESET}
${CYAN}SM64PC Builder${RESET}
${YELLOW}------------------------------${RESET}
${GREEN}Updates:${RESET}

${CYAN}-New external Data Format w/ Zips,
-Added Mollymutt's Texture Pack
-Auto Updater

${RESET}${YELLOW}------------------------------${RESET}
${CYAN}build.sh Update 19${RESET}
${YELLOW}==============================${RESET}"

read -n 1 -r -s -p $'\nPRESS ENTER TO CONTINUE...\n'

# Gives options to download from the Github
echo -e "\n${GREEN}Would you like to download or update the latest source files from Github? ${CYAN}(y/n) ${RESET}"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	echo -e "\n${GREEN}THE MASTER HAS NOT BEEN UPDATED IN A WHILE DOWNLOAD THE NIGHTLY!${CYAN}(master/nightly) ${RESET}"
    read answer
	if [ "$answer" != "${answer#[Mm]}" ] ;then
		# Checks for existence of previous .git folder, then creates one if it doesn't exist and moves the old folder
		if [ -d "$MASTER_GIT" ]; then
			cd ./sm64pc-master
			echo -e "\n"
			git stash push
			git stash drop
			git pull https://github.com/sm64pc/sm64pc
			I_Want_Master=true
			cd ../
		else
			if [ -d "$MASTER" ]; then
				mv sm64pc-master sm64pc-master.old
			fi
			echo -e "\n"
			git clone git://github.com/sm64pc/sm64pc sm64pc-master
			I_Want_Master=true
		fi
	else
		if [ -d "$NIGHTLY_GIT" ]; then
			cd ./sm64pc-nightly
			echo -e "\n"
			git stash push
			git stash drop
			git pull https://github.com/sm64pc/sm64pc
			if [ -f ./build.sh ]; then
				rm ./build.sh
			fi
			I_Want_Nightly=true
			cd ../
		else
			if [ -d "$NIGHTLY" ]; then
				echo -e "\n"
				mv sm64pc-nightly sm64pc-nightly.old
				git clone -b nightly git://github.com/sm64pc/sm64pc sm64pc-nightly
				if [ -f ./sm64pc-nightly/build.sh ]; then
					rm ./sm64pc-nightly/build.sh
				fi
				I_Want_Nightly=true
			else
				echo -e "\n"
				git clone -b nightly git://github.com/sm64pc/sm64pc sm64pc-nightly
				if [ -f ./sm64pc-nightly/build.sh ]; then
					rm ./sm64pc-nightly/build.sh
				fi
				I_Want_Nightly=true
			fi
		fi
	fi
else
    echo -e "\n${GREEN}Are you building master or nightly? (master/nightly) ${RESET}"
	read answer
	if [ "$answer" != "${answer#[Mm]}" ] ;then
		I_Want_Master=true
	else
		I_Want_Nightly=true
	fi
fi

# Checks for a pre-existing baserom file in old folder then moves it to the new one
if [ -f "$MASTER_OLD" ]; then
    mv sm64pc-master.old/baserom.us.z64 sm64pc-master/baserom.us.z64
fi

if [ -f "$NIGHTLY_OLD" ]; then
    mv sm64pc-nightly.old/baserom.us.z64 sm64pc-nightly/baserom.us.z64
fi

# Checks for which version the user selected & if baserom exists
if [ "$I_Want_Master" = true ]; then
    cd ./sm64pc-master
    if [ -f "$ROM_CHECK" ]; then
    	echo -e "\n\n${GREEN}Existing baserom found${RESET}\n"
    else
    	echo -e "\n${YELLOW}Place your baserom.us.z64 file in the ${MASTER} folder located\nin c:/sm64pcBuilder${RESET}\n"
		read -n 1 -r -s -p $'\nPRESS ENTER TO CONTINUE...\n'
	fi
fi

if [ "$I_Want_Nightly" = true ]; then
    cd ./sm64pc-nightly
    if [ -f "$ROM_CHECK" ]; then
    	echo -e "\n\n${GREEN}Existing baserom found${RESET}\n"
    else
    	echo -e "\n${YELLOW}Place your baserom.us.z64 file in the ${NIGHTLY} folder located\nin c:/sm64pcBuilder${RESET}\n"
		read -n 1 -r -s -p $'\nPRESS ENTER TO CONTINUE...\n'
	fi
fi

# Checks to see if the libaudio directory and files exist
if [ -d "${LIBDIR}" -a -e "${LIBDIR}${LIBAFA}" -a -e "${LIBDIR}${LIBAFLA}"  ]; then
    echo -e "\n${GREEN}libaudio files exist, going straight to compiling.${RESET}\n"
else 
    echo -e "\n${GREEN}libaudio files not found, starting initialization process.${RESET}\n\n"

    echo -e "${YELLOW} Changing directory to: ${CYAN}${AUDDIR}${RESET}\n\n"
	cd $AUDDIR

    echo -e "${YELLOW} Executing: ${CYAN}autoreconf -i${RESET}\n\n"
	autoreconf -i

	echo -e "\n${YELLOW} Executing: ${CYAN}./configure --disable-docs${RESET}\n\n"

	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
	  PATH=/mingw64/bin:/mingw32/bin:$PATH LIBS=-lstdc++ ./configure --disable-docs
	else
	  PATH=/mingw32/bin:$PATH LIBS=-lstdc++ ./configure --disable-docs
	fi

	echo -e "\n${YELLOW} Executing: ${CYAN}make $1${RESET}\n\n"

	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
	  PATH=/mingw64/bin:/mingw32/bin:$PATH make $1
	else
	  PATH=/mingw32/bin:$PATH make $1
	fi

    echo -e "\n${YELLOW} Making new directory ${CYAN}../lib${RESET}\n\n"
	mkdir ../lib

    echo -e "${YELLOW} Copying libaudio files to ${CYAN}../lib${RESET}\n\n"
	cp libaudiofile/.libs/libaudiofile.a ../lib/
	cp libaudiofile/.libs/libaudiofile.la ../lib/

    echo -e "${YELLOW} Going up one directory.${RESET}\n\n"
	cd ../

	sed -i 's/tabledesign_CFLAGS := -Wno-uninitialized -laudiofile/tabledesign_CFLAGS := -Wno-uninitialized -laudiofile -lstdc++/g' Makefile

	# Checks the computer architecture
	echo -e "${YELLOW} Executing: ${CYAN}make $1${RESET}\n\n"

	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
	  PATH=/mingw64/bin:/mingw32/bin:$PATH make $1
	else
	  PATH=/mingw32/bin:$PATH make $1
	fi

    echo -e "\n${YELLOW} Going up one directory.${RESET}\n"
		cd ../
fi 
# Fix king_bobomb eyes.
	wget https://cdn.discordapp.com/attachments/710283360794181633/718232903066189884/king_bob-omb_eyes.rgba16.png
	mv -f king_bob-omb_eyes.rgba16.png ./actors/king_bobomb/king_bob-omb_eyes.rgba16.png

# Add-ons Menu
while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Add-ons Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a letter to select:

(E)nhancements
(M)odels
(S)ound Packs
(T)exture Packs
(V)arious
(U)ninstall Patches
(C)ontinue

${GREEN}Press C without making a selection to
continue with no patches.${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "e")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Enhancements Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

(1) 60 FPS Patch (WIP)
(2) 60 FPS Patch Uncapped Framerate (WIP)
(3) Download Reshade - Post processing effects
(C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/60fps_interpolation_wip.patch" ]]; then
			git apply ./enhancements/60fps_interpolation_wip.patch  --ignore-whitespace --reject
			echo -e "$\n${GREEN}60 FPS Patch Selected${RESET}\n"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/707763437975109788/715783586460205086/60fps_interpolation_wip.patch
		  	cd ../
	      	git apply ./enhancements/60fps_interpolation_wip.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}60 FPS Patch Selected${RESET}\n"
          fi 
            ;;
    "2")  if [[ -f "./enhancements/60fps_interpolation_wip_nocap.patch" ]]; then
			git apply ./enhancements/60fps_interpolation_wip_nocap.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}60 FPS Patch Uncapped Framerate Selected${RESET}\n"
		  else
		  	cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/707763437975109788/716761081355173969/60fps_interpolation_wip_nocap.patch
		  	cd ../
		  	git apply ./enhancements/60fps_interpolation_wip_nocap.patch --ignore-whitespace --reject
		  	echo -e "$\n${GREEN}60 FPS Patch Uncapped Framerate Selected${RESET}\n"
		  fi
            ;;
    "3")  wget https://reshade.me/downloads/ReShade_Setup_4.6.1.exe
		  echo -e "$\n${GREEN}Reshade Downloaded${RESET}\n"
      		;;
    "c")  break                      
            ;;
    "C")  echo "use lower case c!!"   
            ;; 
     * )  echo "invalid option"     
            ;;
    esac
    sleep 2
done
			;;
    "m")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Models Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

(1) HD Mario | ${RED}Nightly Only, Needs External Resources${CYAN}
(2) Old School HD Mario
(3) HD Bowser
(4) 3D Coin Patch v2
(C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  wget https://cdn.discordapp.com/attachments/710283360794181633/717479061664038992/HD_Mario_Model.rar
		  unrar x -o+ HD_Mario_Model.rar
		  rm HD_Mario_model.rar
		  echo -e "$\n${GREEN}HD Mario Selected${RESET}\n"
            ;;
    "2")  wget https://cdn.discordapp.com/attachments/710283360794181633/719737291613929513/Old_School_HD_Mario_Model.zip
		  unzip -o Old_School_HD_Mario_Model.zip
		  rm Old_School_HD_Mario_Model.zip
		  echo -e "$\n${GREEN}Old School HD Mario Selected${RESET}\n"
            ;;
    "3")  wget https://cdn.discordapp.com/attachments/716459185230970880/718990046442684456/hd_bowser.rar
		  unrar x -o+ hd_bowser.rar
		  rm hd_bowser.rar
		  echo -e "$\n${GREEN}HD Bowser Selected${RESET}\n"
            ;;
    "4")  if [[ -f "./enhancements/3d_coin_v2.patch" ]]; then
			git apply ./enhancements/3d_coin_v2.patch  --ignore-whitespace --reject
			echo -e "$\n${GREEN}3D Coin Patch v2 Selected${RESET}\n"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/716459185230970880/718674249631662120/3d_coin_v2.patch
		  	cd ../
	      	git apply ./enhancements/3d_coin_v2.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}3D Coin Patch v2 Selected${RESET}\n"
          fi 
            ;;
    #"5")  wget https://cdn.discordapp.com/attachments/716459185230970880/718994292311326730/Hi_Poly_MIPS.rar
		  #unrar x -o+ Hi_Poly_MIPS.rar
		  #rm Hi_Poly_MIPS.rar
		  #echo -e "$\n${GREEN}Hi-Poly MIPS Selected${RESET}\n"
            #;;
    #"6")  wget https://cdn.discordapp.com/attachments/716459185230970880/718999316194263060/Mario_Party_Whomp.rar
		  #unrar x -o+ Mario_Party_Whomp.rar
		  #rm Mario_Party_Whomp.rar
		  #echo -e "$\n${GREEN}Mario Party Whomp Selected${RESET}\n"
            #;;
    #"7")  wget https://cdn.discordapp.com/attachments/716459185230970880/719001278184685598/Mario_Party_Piranha_Plant.rar
		  #unrar x -o+ Mario_Party_Piranha_Plant.rar
		  #rm Mario_Party_Piranha_Plant.rar
		  #echo -e "$\n${GREEN}Mario Party Piranha Plant Selected${RESET}\n"
            #;;
    #"8")  wget https://cdn.discordapp.com/attachments/716459185230970880/719004227464331394/Hi_Poly_Penguin_1.4.rar
		  #unrar x -o+ Hi_Poly_Penguin_1.4.rar
		  #rm Hi_Poly_Penguin_1.4.rar
		  #echo -e "$\n${GREEN}Hi-Poly Penguin 1.4 Selected${RESET}\n"
            #;;
    "c")  break                      
            ;;
    "C")  echo "use lower case c!!"   
            ;; 
     * )  echo "invalid option"     
            ;;
    esac
    sleep 2
done
			;;
    "s")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Sound Packs Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

(1) Super Mario Sunshine Mario Voice | ${RED}Nightly Only, Needs External Resources${CYAN}
(C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  #wget https://cdn.discordapp.com/attachments/710283360794181633/718232544457523247/Sunshine_Mario_VO.rar
		  #unrar x -o+ Sunshine_Mario_VO.rar
		  #rm Sunshine_Mario_VO.rar
		  wget https://cdn.discordapp.com/attachments/718584345912148100/719492399411232859/sunshinesounds.zip
		  echo -e "$\n${GREEN}Super Mario Sunshine Mario Voice Selected${RESET}\n"
            ;;
    "c")  break                      
            ;;
    "C")  echo "use lower case c!!"   
            ;; 
     * )  echo "invalid option"     
            ;;
    esac
    sleep 2
done
			;;
    "t")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Texture Packs Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

(1) Hypatia´s Mario Craft 64 | ${RED}Nightly Only, Needs External Resources${RESET}
${CYAN}(2) Mollymutt's Texture Pack | ${RESET}${RED}Nightly Only, Needs External Resources${RESET}${CYAN}
(C)ontinue${RESET}

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  wget https://cdn.discordapp.com/attachments/718584345912148100/718901885657940091/Hypatia_Mario_Craft_Complete.part1.rar
          wget https://cdn.discordapp.com/attachments/718584345912148100/718902211165290536/Hypatia_Mario_Craft_Complete.part2.rar
          wget https://cdn.discordapp.com/attachments/718584345912148100/718902377553592370/Hypatia_Mario_Craft_Complete.part3.rar
          if [ ! -f Hypatia_Mario_Craft_Complete.part3.rar ]; then
          	echo -e "${RED}Your download fucked up"
          else
          	echo -e "$\n${GREEN}Hypatia´s Mario Craft 64 Selected${RESET}\n"
          fi
            ;;
	"2")  wget https://cdn.discordapp.com/attachments/718584345912148100/719639977662611466/mollymutt.zip
          if [ ! -f mollymutt.zip ]; then
          	echo -e "${RED}Your download fucked up"
          else
          	echo -e "$\n${GREEN}Mollymutt's Texture Pack Selected${RESET}\n"
          fi
            ;;
    "c")  break                      
            ;;
    "C")  echo "use lower case c!!"   
            ;; 
     * )  echo "invalid option"     
            ;;
    esac
    sleep 2
done
			;;
    "v")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Various Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

(1) 120 Star Save | ${RED}Nightly Only${RESET}
${CYAN}(C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  wget https://cdn.discordapp.com/attachments/710283360794181633/718232280224628796/sm64_save_file.bin
		  if [ -f $APPDATA/sm64pc/sm64_save_file.bin ]; then
		  	mv -f $APPDATA/sm64pc/sm64_save_file.bin $APPDATA/sm64pc/sm64_save_file.old.bin
		  	mv sm64_save_file.bin $APPDATA/sm64pc/sm64_save_file.bin
		  fi
		  echo -e "$\n${GREEN}120 Star Save Selected${RESET}\n"
            ;;
    "c")  break                      
            ;;
    "C")  echo "use lower case c!!"   
            ;; 
     * )  echo "invalid option"     
            ;;
    esac
    sleep 2
done
			;;
    "u")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Uninstall Patch Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

(1) Uninstall 60 FPS Patch (WIP)                    
(2) Uninstall 60 FPS Patch Uncapped Framerate (WIP)
(3) Uninstall 3D Coin Patch v2                
(C)ontinue

${GREEN}Press C to continue${RESET}
${RESET}${YELLOW}------------------------------${RESET}"

    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/60fps_interpolation_wip.patch" ]]; then
			git apply -R ./enhancements/60fps_interpolation_wip.patch  --ignore-whitespace --reject
			echo -e "$\n${GREEN}60 FPS Patch Removed${RESET}\n"
          fi 
            ;;
    "2")  if [[ -f "./enhancements/60fps_interpolation_wip_nocap.patch" ]]; then
			git apply -R ./enhancements/60fps_interpolation_wip_nocap.patch --ignore-whitespace --reject
			echo -e "$\n${GREEN}60 FPS Patch Uncapped Framerate Removed${RESET}\n"
		  fi
            ;;
    "3")  if [[ -f "./enhancements/3d_coin_v2.patch" ]]; then
			git apply -R ./enhancements/3d_coin_v2.patch  --ignore-whitespace --reject
			echo -e "$\n${GREEN}3D Coin Patch v2 Removed${RESET}\n"
		  fi
		    ;;
    "c")  break                      
            ;;
    "C")  echo "use lower case c!!"   
            ;; 
     * )  echo "invalid option"     
            ;;
    esac
    sleep 2
done
			;;
    "c")  break                      
            ;;
    "C")  echo "use lower case c!!"   
            ;; 
     * )  echo "invalid option"     
            ;;
    esac
    sleep 2
done

# Master flags menu
if [ "$I_Want_Master" = true ]; then 
	menu() {
			printf "\nAvaliable options:\n"
			for i in ${!MASTER_OPTIONS[@]}; do 
					printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${MASTER_OPTIONS[i]}"
			done
			if [[ "$msg" ]]; then echo "$msg"; fi
			printf "${YELLOW}Please do not select \"Clean build\" with any other option.\n"
			printf "${RED}WARNING: Backup your save file before selecting \"Clean build\".\n"
			printf "${CYAN}Press the corresponding number and press enter to select it.\nWhen all desired options are selected, press Enter to continue.\n"
			printf "${YELLOW}Check Remove Extended Options Menu & leave other options unchecked for a Vanilla\nbuild.\n${RESET}"
	}

	prompt="Check an option (again to uncheck, press ENTER):"$'\n'
	while menu && read -rp "$prompt" num && [[ "$num" ]]; do
			[[ "$num" != *[![:digit:]]* ]] &&
			(( num > 0 && num <= ${#MASTER_OPTIONS[@]} )) ||
			{ msg="Invalid option: $num"; continue; }
			((num--)); # msg="${MASTER_OPTIONS[num]} was ${choices[num]:+un}checked"
			[[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
	done

	for i in ${!MASTER_OPTIONS[@]}; do 
			[[ "${choices[i]}" ]] && { CMDL+=" ${MASTER_EXTRA[i]}"; }
	done
fi

# Nightly flags menu
if [ "$I_Want_Nightly" = true ]; then 
	menu() {
			printf "\nAvaliable options:\n"
			for i in ${!NIGHTLY_OPTIONS[@]}; do 
					printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${NIGHTLY_OPTIONS[i]}"
			done
			if [[ "$msg" ]]; then echo "$msg"; fi
			printf "${YELLOW}Please do not select \"Clean build\" with any other option.\n"
			printf "${RED}WARNING: Backup your save file before selecting \"Clean build\".\n"
			printf "${CYAN}Press the corresponding number and press enter to select it.\nWhen all desired options are selected, press Enter to continue.\n"
			printf "${YELLOW}Check Remove Extended Options Menu & leave other options unchecked for a Vanilla\nbuild.\n${RESET}"
	}

	prompt="Check an option (again to uncheck, press ENTER):"$'\n'
	while menu && read -rp "$prompt" num && [[ "$num" ]]; do
			[[ "$num" != *[![:digit:]]* ]] &&
			(( num > 0 && num <= ${#NIGHTLY_OPTIONS[@]} )) ||
			{ msg="Invalid option: $num"; continue; }
			((num--)); # msg="${NIGHTLY_OPTIONS[num]} was ${choices[num]:+un}checked"
			[[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
	done

	for i in ${!NIGHTLY_OPTIONS[@]}; do 
			[[ "${choices[i]}" ]] && { CMDL+=" ${NIGHTLY_EXTRA[i]}"; }
	done
fi

# Checks the computer architecture
if [ "${CMDL}" != " clean" ]; then
	echo -e "\n${YELLOW} Executing: ${CYAN}make ${CMDL} $1${RESET}\n\n"

	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
	  PATH=/mingw64/bin:/mingw32/bin:$PATH make $CMDL $1
	else
	  PATH=/mingw32/bin:$PATH make $CMDL $1
	fi

	if ls $BINARY 1> /dev/null 2>&1; then
		if [ -f ReShade_Setup_4.6.1.exe ]; then
			mv ./ReShade_Setup_4.6.1.exe ./build/us_pc/ReShade_Setup_4.6.1.exe
		fi
		
		# Move sound packs
		if [ -d ./build/us_pc/res ]; then
			if [ -f sunshinesounds.zip ]; then
				mv sunshinesounds.zip ./build/us_pc/res
				rm sunshinesounds* # in case they exist from running the script before or selecting multiple times.
			fi
		fi
				
		# Move texture packs
		if [ -d ./build/us_pc/res ]; then
			if [ -f Hypatia_Mario_Craft_Complete.part3.rar ]; then
				mkdir ./build/hmcc/
				unrar x -o+ Hypatia_Mario_Craft_Complete.part1.rar ./build/hmcc/
				mv ./build/hmcc/res ./build/hmcc/gfx
				cd ./build/hmcc/
				zip -r hypatiamariocraft gfx
				mv hypatiamariocraft.zip ../../build/us_pc/res
				cd ../../
            	rm Hypatia_Mario_Craft_Complete.part*
				rm -rf ./build/hmcc/
			fi
			if [ -f mollymutt.zip ]; then
				mv mollymutt.zip ./build/us_pc/res
			fi
		fi
		
    	echo -e "\n${GREEN}The sm64pc binary is now available in the 'build/us_pc/' folder."
		echo -e "\n${YELLOW}If fullscreen doesn't seem like the correct resolution, then right click on the\nexe, go to properties, compatibility, then click Change high DPI settings.\nCheck the 'Override high DPI scaling behavior' checkmark, leave it on\napplication, then press apply."
		cd ./build/us_pc/
		start .
	else
    	echo -e "\n${RED}Oh no! Something went wrong."
	fi

else

	echo -e "\n${YELLOW} Executing: ${CYAN}make ${CMDL} $1${RESET}\n\n"

	if [ ${MACHINE_TYPE} == 'x86_64' ]; then
	  PATH=/mingw64/bin:/mingw32/bin:$PATH make $CMDL $1
	else
	  PATH=/mingw32/bin:$PATH make $CMDL $1
	fi

	echo -e "${GREEN}\nYour build is now clean.\n"
fi
