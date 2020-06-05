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
MASTER_OPTIONS=("Analog Camera" "No Draw Distance" "Texture Fixes" "Remove Extended Options Menu | Remove additional R button menu options" "Build for the web | Requires emsdk to be installed" "Build for a Raspberry Pi" "Clean build | This deletes the build folder")
MASTER_EXTRA=("BETTERCAMERA=1" "NODRAWINGDISTANCE=1" "TEXTURE_FIX=1" "EXT_OPTIONS_MENU=0" "TARGET_WEB=1" "TARGET_RPI=1" "clean")
NIGHTLY_OPTIONS=("Analog Camera" "No Draw Distance" "Texture Fixes" "Allow External Resources" "Remove Extended Options Menu | Remove additional R button menu options" "OpenGL 1.3 Renderer | Unrecommended. Only use if your machine is very old" "Build for the web | Requires emsdk to be installed" "Build for a Raspberry Pi" "Clean build | This deletes the build folder")
NIGHTLY_EXTRA=("BETTERCAMERA=1" "NODRAWINGDISTANCE=1" "TEXTURE_FIX=1" "EXTERNAL_DATA=1" "EXT_OPTIONS_MENU=0" "LEGACY_GL=1" "TARGET_WEB=1" "TARGET_RPI=1" "clean")

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

#Installs the msys dependency bullshit if it's not installed yet
if  [[ ! $(command -v make) || ! $(command -v git) ]]; then
	printf "\n${RED}Dependencies are missing. Proceeding with the installation... ${RESET}\n" >&2
	pacman -S --needed base-devel mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain \
                    git subversion mercurial \
                    mingw-w64-i686-cmake mingw-w64-x86_64-cmake --noconfirm
    pacman -S mingw-w64-i686-glew mingw-w64-x86_64-glew mingw-w64-i686-SDL2 mingw-w64-x86_64-SDL2 mingw-w64-i686-python-xdg mingw-w64-x86_64-python-xdg python3 --noconfirm
	pacman -Syuu --noconfirm
else
	printf "\n${GREEN}Dependencies are already installed. ${RESET}\n"
fi

#Upgrade to updating version
if [ ! -d "$FOLDER_PLACEMENT" ]; then
	git clone https://github.com/gunvalk/sm64pcBuilder/
	mv ./sm64pcBuilder c:/sm64pcBuilder
	cd c:/sm64pcBuilder
	printf "\n${GREEN}RESTARTING\n"
	exec ./build.sh $1
fi

#Update check
printf "\n${GREEN}Would you like to check for build.sh updates? ${CYAN}(y/n) ${RESET}\n"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	git stash push
	git stash drop
	git pull https://github.com/gunvalk/sm64pcBuilder
	printf "\n${GREEN}RESTARTING - ANSWER ${RESET}${RED}NO ${RESET}${GREEN}WHEN ASKED ABOUT UPDATES THIS TIME.${RESET}\n"
	sleep 2
	exec ./build.sh $1
fi
printf "\n"

#Update message
while :
do
    clear
    cat<<EOF
    ${YELLOW}==============================${RESET}
    ${CYAN}SM64PC Builder${RESET}
    ${YELLOW}------------------------------${RESET}
    ${GREEN}Updates:${RESET}

    ${CYAN}-Separate Nightly And Master Menus                    
    -Super Mario Sunshine Voice Pack Option 
    -120 Star Save File Option
    -Fixed King Bob-omb's Eyes On Nightly
    -Slimmer Make Clean Code                              

    (C)ontinue
    
    ${RESET}${YELLOW}------------------------------${RESET}
    ${CYAN}build.sh Update 16${RESET}
    ${YELLOW}==============================${RESET}

EOF
read -n1 -s
    case "$REPLY" in
    "c")  break
			;;
     * )  echo "invalid option"     
            ;;
    esac
    sleep 2
done

# Gives options to download from the Github
printf "\n${GREEN}Would you like to download or update the latest source files from Github? ${CYAN}(y/n) ${RESET}\n"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	printf "\n${GREEN}THE MASTER HAS NOT BEEN UPDATED IN A WHILE DOWNLOAD THE NIGHTLY!${CYAN}(master/nightly) ${RESET}\n"
    read answer
	if [ "$answer" != "${answer#[Mm]}" ] ;then
		# Checks for existence of previous .git folder, then creates one if it doesn't exist and moves the old folder
		if [ -d "$MASTER_GIT" ]; then
			cd ./sm64pc-master
			printf "\n"
			git stash push
			git stash drop
			git pull https://github.com/sm64pc/sm64pc
			I_Want_Master=true
			cd ../
		else
			if [ -d "$MASTER" ]; then
				mv sm64pc-master sm64pc-master.old
				printf "\n"
				git clone git://github.com/sm64pc/sm64pc sm64pc-master
				I_Want_Master=true
			else
				printf "\n"
				git clone git://github.com/sm64pc/sm64pc sm64pc-master
				I_Want_Master=true
			fi
		fi
	else
		if [ -d "$NIGHTLY_GIT" ]; then
			cd ./sm64pc-nightly
			printf "\n"
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
				printf "\n"
				mv sm64pc-nightly sm64pc-nightly.old
				git clone -b nightly git://github.com/sm64pc/sm64pc sm64pc-nightly
				if [ -f ./sm64pc-nightly/build.sh ]; then
					rm ./sm64pc-nightly/build.sh
				fi
				I_Want_Nightly=true
			else
				printf "\n"
				git clone -b nightly git://github.com/sm64pc/sm64pc sm64pc-nightly
				if [ -f ./sm64pc-nightly/build.sh ]; then
					rm ./sm64pc-nightly/build.sh
				fi
				I_Want_Nightly=true
			fi
		fi
	fi
else
    printf "\n${GREEN}Are you building master or nightly? (master/nightly) ${RESET}\n"
	read answer
	if [ "$answer" != "${answer#[Mm]}" ] ;then
		I_Want_Master=true
	else
		I_Want_Nightly=true
	fi
fi

# Checks for a pre-existing baserom file in old folder then moves it to the new one
if [ -f "$MASTER_OLD" ]; then
	cd ./sm64pc-master.old
    mv baserom.us.z64 ../sm64pc-master/baserom.us.z64
	cd ../
fi

if [ -f "$NIGHTLY_OLD" ]; then
	cd ./sm64pc-nightly.old
    mv baserom.us.z64 ../sm64pc-nightly/baserom.us.z64
	cd ../
fi

# Checks for which version the user selected & if baserom exists
if [ "$I_Want_Master" = true ]; then
    cd ./sm64pc-master
    if [ -f "$ROM_CHECK" ]; then
    	printf "\n\n${GREEN}Existing baserom found${RESET}\n"
    else
    	printf "\n${YELLOW}Place your baserom.us.z64 file in the ${MASTER} folder located\nin c:/sm64pcBuilder${RESET}\n"
		read -n 1 -r -s -p $'\nPRESS ENTER TO CONTINUE...\n'
	fi
fi

if [ "$I_Want_Nightly" = true ]; then
    cd ./sm64pc-nightly
    if [ -f "$ROM_CHECK" ]; then
    	printf "\n\n${GREEN}Existing baserom found${RESET}\n"
    else
    	printf "\n${YELLOW}Place your baserom.us.z64 file in the ${NIGHTLY} folder located\nin c:/sm64pcBuilder${RESET}\n"
		read -n 1 -r -s -p $'\nPRESS ENTER TO CONTINUE...\n'
	fi
fi

# Checks to see if the libaudio directory and files exist
if [ -d "$LIBDIR" -a -e "${LIBDIR}$LIBAFA" -a -e "${LIBDIR}$LIBAFLA"  ]; then
    printf "\n${GREEN}libaudio files exist, going straight to compiling.${RESET}\n"
else 
    printf "\n${GREEN}libaudio files not found, starting initialization process.${RESET}\n\n"

    printf "${YELLOW} Changing directory to: ${CYAN}${AUDDIR}${RESET}\n\n"
		cd $AUDDIR

    printf "${YELLOW} Executing: ${CYAN}autoreconf -i${RESET}\n\n"
		autoreconf -i

	#Checks the computer architecture
	if [ `getconf LONG_BIT` = "64" ]; then
    	printf "\n${YELLOW} Executing: ${CYAN}./configure --disable-docs${RESET}\n\n"
			PATH=/mingw64/bin:/mingw32/bin:$PATH LIBS=-lstdc++ ./configure --disable-docs

    	printf "\n${YELLOW} Executing: ${CYAN}make $1${RESET}\n\n"
			PATH=/mingw64/bin:/mingw32/bin:$PATH make $1
	else
		if [ `getconf LONG_BIT` = "32" ]; then
			printf "\n${YELLOW} Executing: ${CYAN}./configure --disable-docs${RESET}\n\n"
				PATH=/mingw32/bin:/mingw64/bin:$PATH LIBS=-lstdc++ ./configure --disable-docs

    		printf "\n${YELLOW} Executing: ${CYAN}make $1${RESET}\n\n"
				PATH=/mingw32/bin:/mingw64/bin:$PATH make $1
		fi
	fi
    printf "\n${YELLOW} Making new directory ${CYAN}../lib${RESET}\n\n"
		mkdir ../lib


    printf "${YELLOW} Copying libaudio files to ${CYAN}../lib${RESET}\n\n"
		cp libaudiofile/.libs/libaudiofile.a ../lib/
		cp libaudiofile/.libs/libaudiofile.la ../lib/

    printf "${YELLOW} Going up one directory.${RESET}\n\n"
		cd ../
		
		#Checks if the Makefile has already been changed

		sed -i 's/tabledesign_CFLAGS := -Wno-uninitialized -laudiofile/tabledesign_CFLAGS := -Wno-uninitialized -laudiofile -lstdc++/g' Makefile

	#Checks the computer architecture
    if [ `getconf LONG_BIT` = "64" ]; then
    	printf "${YELLOW} Executing: ${CYAN}make $1${RESET}\n\n"
			PATH=/mingw64/bin:/mingw32/bin:$PATH make $1
	else
		if [ `getconf LONG_BIT` = "32" ]; then
			printf "${YELLOW} Executing: ${CYAN}make $1${RESET}\n\n"
				PATH=/mingw32/bin:/mingw64/bin:$PATH make $1
		fi
	fi
    printf "\n${YELLOW} Going up one directory.${RESET}\n"
		cd ../
fi 

#Patch menu
while :
do
    clear
    cat<<EOF
    ${YELLOW}==============================${RESET}
    ${CYAN}Patch Menu${RESET}
    ${YELLOW}------------------------------${RESET}
    ${CYAN}Press a number to select:

    (1) 60 FPS Patch (WIP)                    
    (2) 60 FPS Patch Uncapped Framerate (WIP)
    (3) HD Mario Model
    (4) Super Mario Sunshine Mario Voice
    (5) 120 Star Save | Nightly Only
    (6) Download Reshade - Post processing effects                  
    (C)ontinue

    ${GREEN}Press C without making a selection to
    continue with no patches.${RESET}
    ${RESET}${YELLOW}------------------------------${RESET}
EOF
    read -n1 -s
    case "$REPLY" in
    "1")  if [[ -f "./enhancements/60fps_interpolation_wip.patch" ]]; then
			git apply ./enhancements/60fps_interpolation_wip.patch  --ignore-whitespace --reject
			printf "$\n${GREEN}60 FPS Patch Selected${RESET}\n"
		  else
			cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/707763437975109788/715783586460205086/60fps_interpolation_wip.patch
		  	cd ../
	      	git apply ./enhancements/60fps_interpolation_wip.patch --ignore-whitespace --reject
          	printf "$\n${GREEN}60 FPS Patch Selected${RESET}\n"
          fi 
            ;;
    "2")  if [[ -f "./enhancements/60fps_interpolation_wip_nocap.patch" ]]; then
			git apply ./enhancements/60fps_interpolation_wip_nocap.patch --ignore-whitespace --reject
			printf "$\n${GREEN}60 FPS Patch Uncapped Framerate Selected${RESET}\n"
		  else
		  	cd ./enhancements
		  	wget https://cdn.discordapp.com/attachments/707763437975109788/716761081355173969/60fps_interpolation_wip_nocap.patch
		  	cd ../
		  	git apply ./enhancements/60fps_interpolation_wip_nocap.patch --ignore-whitespace --reject
		  	printf "$\n${GREEN}60 FPS Patch Uncapped Framerate Selected${RESET}\n"
		  fi
            ;;
    "3")  wget https://cdn.discordapp.com/attachments/710283360794181633/717479061664038992/HD_Mario_Model.rar
		  unrar x -o+ HD_Mario_Model.rar
		  rm HD_Mario_model.rar
		  printf "$\n${GREEN}HD Mario Model Selected${RESET}\n"
            ;;
    "4")  wget https://cdn.discordapp.com/attachments/710283360794181633/718232544457523247/Sunshine_Mario_VO.rar
		  unrar x -o+ Sunshine_Mario_VO.rar
		  rm Sunshine_Mario_VO.rar
		  printf "$\n${GREEN}Super Mario Sunshine Mario Voice Selected${RESET}\n"
            ;;
    "5")  wget https://cdn.discordapp.com/attachments/710283360794181633/718232280224628796/sm64_save_file.bin
		  if [ -f $APPDATA/sm64pc/sm64_save_file.bin ]; then
		  	mv -f $APPDATA/sm64pc/sm64_save_file.bin $APPDATA/sm64pc/sm64_save_file.old.bin
		  	mv sm64_save_file.bin $APPDATA/sm64pc/sm64_save_file.bin
		  fi
		  printf "$\n${GREEN}120 Star Save Selected${RESET}\n"
            ;;
    "6")  wget https://reshade.me/downloads/ReShade_Setup_4.6.1.exe
		  printf "$\n${GREEN}Reshade Downloaded${RESET}\n"
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
if [ "${CMDL}" != " clean" ] && [ `getconf LONG_BIT` = "64" ]; then
	#printf "${YELLOW}Only cross-compile if you intend to play the game on an OS that has a different\narchitecture than yours. ${RESET}\n"
	#printf "${CYAN}Make sure to select \"Clean build\" before attempting to cross-compile. ${RESET}\n"
	#printf "${GREEN}Would you like to cross-compile a 32-bit binary? ${CYAN}(y/n) ${RESET}\n"
	#read answer
	#if [ "$answer" != "${answer#[Yy]}" ]; then
		#printf "\n${YELLOW} Executing: ${CYAN}make ${CMDL} TARGET_BITS=32 $1${RESET}\n\n"
		#PATH=/mingw32/bin:/mingw64/bin:$PATH make $CMDL TARGET_BITS=32 $1
	#else
		printf "\n${YELLOW} Executing: ${CYAN}make ${CMDL} $1${RESET}\n\n"
		PATH=/mingw64/bin:/mingw32/bin:$PATH make $CMDL $1
	#fi

	if [ "${CMDL}" != " clean" ] && [ `getconf LONG_BIT` = "32" ]; then
		#printf "${YELLOW}Only cross-compile if you intend to play the game on an OS that has a different\narchitecture than yours. ${RESET}\n"
		#printf "${CYAN}Make sure to select \"Clean build\" before attempting to cross-compile. ${RESET}\n"
		#printf "${GREEN}Would you like to cross-compile a 64-bit binary? ${CYAN}(y/n) ${RESET}\n"
		#read answer
		#if [ "$answer" != "${answer#[Yy]}" ]; then
			#printf "\n${YELLOW} Executing: ${CYAN}make ${CMDL} TARGET_BITS=64 $1${RESET}\n\n"
			#PATH=/mingw32/bin:/mingw64/bin:$PATH make $CMDL TARGET_BITS=64 $1
		#else
			printf "\n${YELLOW} Executing: ${CYAN}make ${CMDL} TARGET_BITS=32 $1${RESET}\n\n"
			PATH=/mingw32/bin:/mingw64/bin:$PATH make $CMDL TARGET_BITS=32 $1
		#fi
	fi

	if ls $BINARY 1> /dev/null 2>&1; then
		if [ -f ReShade_Setup_4.6.1.exe ]; then
			mv ./ReShade_Setup_4.6.1.exe ./build/us_pc/ReShade_Setup_4.6.1.exe
		fi
		if [ -d ./build/us_pc/res ]; then
			wget https://cdn.discordapp.com/attachments/710283360794181633/718232903066189884/king_bob-omb_eyes.rgba16.png
			mv -f king_bob-omb_eyes.rgba16.png ./build/us_pc/res/actors/king_bobomb/king_bob-omb_eyes.rgba16.png
		fi
    	printf "\n${GREEN}The sm64pc binary is now available in the 'build/us_pc/' folder.\n"
		printf "\n${YELLOW}If fullscreen doesn't seem like the correct resolution, then right click on the\nexe, go to properties, compatibility, then click Change high DPI settings.\nCheck the 'Override high DPI scaling behavior' checkmark, leave it on\napplication, then press apply."
		cd ./build/us_pc/
		start .
	else
    	printf "\n${RED}Oh no! Something went wrong."
	fi
	
else
	printf "\n${YELLOW} Executing: ${CYAN}make ${CMDL} $1${RESET}\n\n"
	make $CMDL $1
	printf "\nYour build is now clean.\n"
fi 
