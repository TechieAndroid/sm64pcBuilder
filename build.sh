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

# Command line options
MASTER_OPTIONS=("Analog Camera" "No Draw Distance" "Texture Fixes" "Remove Extended Options Menu | Remove additional R button menu options" "Clean build | This deletes the build folder")
MASTER_EXTRA=("BETTERCAMERA=1" "NODRAWINGDISTANCE=1" "TEXTURE_FIX=1" "EXT_OPTIONS_MENU=0" "clean")
NIGHTLY_OPTIONS=("Analog Camera" "No Draw Distance" "Texture Fixes" "Allow External Resources" "Remove Extended Options Menu | Remove additional R button menu options" "OpenGL 1.3 Renderer | Unrecommended. Only use if your machine is very old" "Clean build | This deletes the build folder")
NIGHTLY_EXTRA=("BETTERCAMERA=1" "NODRAWINGDISTANCE=1" "TEXTURE_FIX=1" "EXTERNAL_DATA=1" "EXT_OPTIONS_MENU=0" "LEGACY_GL=1" "clean")

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# Checks for common required executables (make, git, gcc) and installs them if they are missing
if  [[ ! $(command -v make) || ! $(command -v git) ]]; then
	echo -e "\n${RED}Dependencies are missing. Proceeding with the installation... ${RESET}\n" >&2
	pacman -Sy --needed base-devel mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain \
                    git subversion mercurial \
                    mingw-w64-i686-cmake mingw-w64-x86_64-cmake --noconfirm
    pacman -S mingw-w64-i686-glew mingw-w64-x86_64-glew mingw-w64-i686-SDL2 mingw-w64-x86_64-SDL2 mingw-w64-i686-python-xdg mingw-w64-x86_64-python-xdg python3 --noconfirm
	pacman -Syuu --noconfirm
else
	echo -e "\n${GREEN}Dependencies are already installed. ${RESET}\n"
fi

#Upgrade to updating version
if [ ! -d "$FOLDER_PLACEMENT" ]; then
	git clone https://github.com/gunvalk/sm64pcBuilder/
	mv ./sm64pcBuilder c:/sm64pcBuilder
	cd c:/sm64pcBuilder
	echo -e "\n${GREEN}RESTARTING\n"
	exec ./build.sh $1
fi

#Delete their setup or old shit
if [ -f $HOME/build-setup.sh ]; then
	rm $HOME/build-setup.sh
fi

if [ -f $HOME/build.sh ]; then
	rm $HOME/build.sh
fi

#Update check
echo -e "\n${GREEN}Would you like to check for build.sh updates? ${CYAN}(y/n) ${RESET}"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	git stash push
	git stash drop
	git pull https://github.com/gunvalk/sm64pcBuilder
	echo -e "\n${GREEN}RESTARTING - ANSWER ${RESET}${RED}NO ${RESET}${GREEN}WHEN ASKED ABOUT UPDATES THIS TIME.${RESET}\n"
	sleep 2
	exec ./build.sh $1
fi
echo -e "\n"

#Update message
echo \
"${YELLOW}==============================${RESET}
${CYAN}SM64PC Builder${RESET}
${YELLOW}------------------------------${RESET}
${GREEN}Updates:${RESET}

${CYAN}-Code Fixes                    
-HD Coin Patch Option 
-Hypatia's Mario Craft Option
-Patch Uninstall Menu

${RESET}${YELLOW}------------------------------${RESET}
${CYAN}build.sh Update 17${RESET}
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
	PATH=/mingw64/bin:/mingw32/bin:$PATH LIBS=-lstdc++ ./configure --disable-docs

	echo -e "\n${YELLOW} Executing: ${CYAN}make $1${RESET}\n\n"
	PATH=/mingw64/bin:/mingw32/bin:$PATH make $1

    echo -e "\n${YELLOW} Making new directory ${CYAN}../lib${RESET}\n\n"
	mkdir ../lib

    echo -e "${YELLOW} Copying libaudio files to ${CYAN}../lib${RESET}\n\n"
	cp libaudiofile/.libs/libaudiofile.a ../lib/
	cp libaudiofile/.libs/libaudiofile.la ../lib/

    echo -e "${YELLOW} Going up one directory.${RESET}\n\n"
	cd ../

	sed -i 's/tabledesign_CFLAGS := -Wno-uninitialized -laudiofile/tabledesign_CFLAGS := -Wno-uninitialized -laudiofile -lstdc++/g' Makefile

	#Checks the computer architecture
	echo -e "${YELLOW} Executing: ${CYAN}make $1${RESET}\n\n"
	PATH=/mingw64/bin:/mingw32/bin:$PATH make $1

    echo -e "\n${YELLOW} Going up one directory.${RESET}\n"
		cd ../
fi 

#Patch menu
while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Patch Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

(1) 60 FPS Patch (WIP)                    
(2) 60 FPS Patch Uncapped Framerate (WIP)
(3) HD Mario Model
(4) HD Coin Patch
(5) Hypatia´s Mario Craft 64 | ${RED}Nightly Only, Needs External Resources${RESET}
${CYAN}(6) Super Mario Sunshine Mario Voice
(7) 120 Star Save | ${RED}Nightly Only${RESET}
${CYAN}(8) Download Reshade - Post processing effects                  
(U)ninstall Patches
(C)ontinue

${GREEN}Press C without making a selection to
continue with no patches.${RESET}
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
    "3")  wget https://cdn.discordapp.com/attachments/710283360794181633/717479061664038992/HD_Mario_Model.rar
		  unrar x -o+ HD_Mario_Model.rar
		  rm HD_Mario_model.rar
		  echo -e "$\n${GREEN}HD Mario Model Selected${RESET}\n"
            ;;
    "4")  if [[ -f "./enhancements/coin.patch" ]]; then
			git apply ./enhancements/coin.patch  --ignore-whitespace --reject
			echo -e "$\n${GREEN}HD Coin Model Selected${RESET}\n"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/710283360794181633/718523593180577882/coin.patch
		  	cd ../
	      	git apply ./enhancements/coin.patch --ignore-whitespace --reject
          	echo -e "$\n${GREEN}HD Coin Model Selected${RESET}\n"
          fi 
            ;;
    "5")  wget https://cdn.discordapp.com/attachments/718584345912148100/718901885657940091/Hypatia_Mario_Craft_Complete.part1.rar
          wget https://cdn.discordapp.com/attachments/718584345912148100/718902211165290536/Hypatia_Mario_Craft_Complete.part2.rar
          wget https://cdn.discordapp.com/attachments/718584345912148100/718902377553592370/Hypatia_Mario_Craft_Complete.part3.rar
          if [ ! -f Hypatia_Mario_Craft_Complete.part3.rar ]; then
          	echo -e "${RED}Your download fucked up"
          else
          	echo -e "$\n${GREEN}Hypatia´s Mario Craft 64 Selected${RESET}\n"
          fi
            ;;
    "6")  wget https://cdn.discordapp.com/attachments/710283360794181633/718232544457523247/Sunshine_Mario_VO.rar
		  unrar x -o+ Sunshine_Mario_VO.rar
		  rm Sunshine_Mario_VO.rar
		  echo -e "$\n${GREEN}Super Mario Sunshine Mario Voice Selected${RESET}\n"
            ;;
    "7")  wget https://cdn.discordapp.com/attachments/710283360794181633/718232280224628796/sm64_save_file.bin
		  if [ -f $APPDATA/sm64pc/sm64_save_file.bin ]; then
		  	mv -f $APPDATA/sm64pc/sm64_save_file.bin $APPDATA/sm64pc/sm64_save_file.old.bin
		  	mv sm64_save_file.bin $APPDATA/sm64pc/sm64_save_file.bin
		  fi
		  echo -e "$\n${GREEN}120 Star Save Selected${RESET}\n"
            ;;
    "8")  wget https://reshade.me/downloads/ReShade_Setup_4.6.1.exe
		  echo -e "$\n${GREEN}Reshade Downloaded${RESET}\n"
      		;;
    "u")  while :
do
    clear
	echo \
"${YELLOW}==============================${RESET}
${CYAN}Patch Menu${RESET}
${YELLOW}------------------------------${RESET}
${CYAN}Press a number to select:

(1) Uninstall 60 FPS Patch (WIP)                    
(2) Uninstall 60 FPS Patch Uncapped Framerate (WIP)
(3) Uninstall HD Coin Patch                
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
    "3")  if [[ -f "./enhancements/coin.patch" ]]; then
			git apply -R ./enhancements/coin.patch  --ignore-whitespace --reject
			echo -e "$\n${GREEN}HD Coin Model Removed${RESET}\n"
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

#Master flags menu
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

#Master flags menu
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

#Checks the computer architecture
if [ "${CMDL}" != " clean" ]; then
	echo -e "\n${YELLOW} Executing: ${CYAN}make ${CMDL} $1${RESET}\n\n"
	PATH=/mingw64/bin:/mingw32/bin:$PATH make $CMDL $1

	if ls $BINARY 1> /dev/null 2>&1; then
		if [ -f ReShade_Setup_4.6.1.exe ]; then
			mv ./ReShade_Setup_4.6.1.exe ./build/us_pc/ReShade_Setup_4.6.1.exe
		fi
		#Move texture packs
		if [ -d ./build/us_pc/res ]; then
			wget https://cdn.discordapp.com/attachments/710283360794181633/718232903066189884/king_bob-omb_eyes.rgba16.png
			mv -f king_bob-omb_eyes.rgba16.png ./build/us_pc/res/actors/king_bobomb/king_bob-omb_eyes.rgba16.png
			if [ -f Hypatia_Mario_Craft_Complete.part3.rar ]; then
				unrar x -o+ Hypatia_Mario_Craft_Complete.part1.rar ./build/us_pc/
            	rm Hypatia*
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
	PATH=/mingw64/bin:/mingw32/bin:$PATH make $CMDL $1
	echo -e "${GREEN}\nYour build is now clean.\n"
fi
