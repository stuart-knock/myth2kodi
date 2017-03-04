#!/usr/bin/env bash

# Interactive installation script for myth2kodi.
#
#USAGE:
#  Run:
#    ./install.sh
#  at a command line and follow the instructions.
#
#REQUIRES:
#  
#  git -- only if running from a repository rather than a release tar-ball.
#
#DESCRIPTION:
#  An interactive command line tool for installing myth2kodi on your
#  system. The script gives you the opportunity to customise some of
#  the installation. Just pressing enter and providing your sudo
#  password when requested will do a default install. You will still
#  need to configure myth2kodi before first use, see:
#    https://github.com/stuart-knock/myth2kodi/blob/master/doc/CONFIGURE.md
#
# Author: Stuart A. Knock
# Originally Written: 2017-03
# https://github.com/stuart-knock/myth2kodi
#
# Thanks to jctennis at the Kodi forums for the suggestion/motivation:
#   http://forum.kodi.tv/showthread.php?tid=301925&pid=2538668#pid2538668
#

############################################################################
################################# Settings #################################
############################################################################

#Specify what you want to install. Only has an effect when installing from a
#clone/fork of the repository -- no effect from release tar-ball.
#NOTE: Setting 'Enabled' here can install a potentially unstable version
#      of myth2kodi. You do not generally want to do this.
#Options: ['Enabled'|'Disabled'(DEFAULT)]
DEVELOPMENT_INSTALL='Disabled'

############################## Logging Settings ##############################
#The settings below are for the bashlogging script which provides the configurable
#logging functionality used in myth2kodi.
#LOGLEVEL provides control over the amount of information myth2kodi reports.
#    0=Only Errors;
#    1=adds warnings;
#    2=adds more information;  --> DEFAULT
#    3=provides debugging output.
#Recommend 2 to start with or if you want to keep track of what myth2kodi is doing.
#Recommend 1 for usual operation, once you're confident that everything is working.
#Only use 3 if you have a particular problem that you're trying to track down,
#it significantly increases the output.
LOGLEVEL=2

#NOTE: LOGFILE is set to a temporary file which is copied into myth2kodi's
#      working directory after a successful install...

#LOGTYPE defines where to direct logging messages.
#Options: ['filestderr'|'stderr'|'file'(DEFAULT)|'stdout'|'filestdout']:
#NOTE: This is made read only within the bashlogging script.
LOGTYPE='file'


############################################################################
########################### Function Definitions ###########################
############################################################################

m2k_install_init(){
  #Who called me...
  CALLER=$(whoami) ; declare -gr CALLER
  
  #Strongly recommend against running as root.
  if [[ "$EUID" = '0' || "$UID" = '0' || "$USER" = 'root' || "$CALLER" = 'root' ]]; then
    printf 'WARNING: %s\n' "You do NOT need to run myth2kodi's install script as root."
    printf '         %s\n' "If you select an install directory that requires elevated"
    printf '         %s\n' "privileges, you will be asked for your sudo password by the"
    printf '         %s\n' "system commands as needed."
    return 1
  fi
  
  #Where am I
  SCRIPT_PATH="$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )"
  
  #Initialise logging system -- boot strapping, this is the bashlogging we're about to install.
  LOGFILE="$(mktemp "/tmp/m2k_install_log_${Today}-XXXX")"
  if [[ -f "$SCRIPT_PATH/bashlogging" ]]; then
    local bashloggingstatus
    # shellcheck source=./bashlogging
    source "$SCRIPT_PATH/bashlogging"
    bashloggingstatus="$?"
    [[ "$bashloggingstatus" != "0" ]] && exit "$bashloggingstatus"
  else
    printf 'ERROR: %s\n' "$SCRIPT_PATH/bashlogging does not exist." | tee -a "$LOGFILE"
    return 1
  fi
  
  #What am I
  eval "$(grep -o 'm2kVersion=".*"' "${SCRIPT_PATH}/myth2kodi")"
  
  #And when...
  Today="$(date +%F)"  #Date in IEEE standard format, ie YYYY-mm-dd
  ScriptStartTime="$(date +%H:%M:%S)" #Time in a readable IEEE standard format, ie HH:MM:SS
  FileNameNow="$(date +%FT%H%M%S)"  #ISO 8601: YYYY-mm-ddThhMMSS
  declare -gr Today
  declare -gr ScriptStartTime
  declare -gr FileNameNow

  return 0
}

#Make temporary copies of the files to be installed so we can modify them 
#rather than the originals.
prepare_installation(){
  #Use the presence of a .git directory to infer that we're in a repo
  [[ -d "${SCRIPT_PATH}/.git" ]] && INSTALL_SOURCE='repo'
  
  if [[ "$INSTALL_SOURCE" == 'repo' && "$DEVELOPMENT_INSTALL" != 'Enabled' ]]; then
  	#Make sure we have git
  	local pkgpath_git=''
  	pkgpath_git=$(command -v git) || { err "No git, but seems to be a repo"; return 1; }
  	debug "Found git at: '$pkgpath_git'"
    #Where we started
    ORIGINAL_DIR="$( pwd -P )"
    #Make sure we are actually in the directory containing install.sh
    cd "${SCRIPT_PATH}"
    #What branch did we start on
    ORIGINAL_BRANCH="$( git rev-parse --abbrev-ref HEAD )"
    #Make sure we are in master
    git checkout master
    #Get the latest release tag
    LATEST_RELEASE="$(git tag --list | tail -1)"
    #Switch to a temporary "detached HEAD" state
    git checkout tags/"$LATEST_RELEASE"
    #Copy the release version of the scripts and .conf file
    create_temporary_copies_scripts
    create_temporary_copy_conf
    #Put things back where they were
    git checkout "$ORIGINAL_BRANCH"
    cd "$ORIGINAL_DIR"
  else #We are either in a release tar-ball or a repo with 'Development' install Enabled.
    #Copy the available version of the scripts and .conf file
    create_temporary_copies_scripts
    create_temporary_copy_conf
  fi
  return 0
}

create_temporary_copies_scripts(){
  #Make a temporary copy of myth2kodi
  if [[ -f "${SCRIPT_PATH}/myth2kodi" ]]; then
    M2K_INSTALL_MYTH2KODI_FILE="$(mktemp "/tmp/m2k_install_myth2kodi_${Today}-XXXX")"
    cp -p "${SCRIPT_PATH}/myth2kodi" "$M2K_INSTALL_SCRIPT_FILE"
    [[ "$?" != 0 ]] && err "Failed to create a temporary copy of myth2kodi for install."
  else
    err "Cannot find the main script: '${SCRIPT_PATH}/myth2kodi'."
    return 1
  fi

  #Make a temporary copy of mythdb_access
  if [[ -f "${SCRIPT_PATH}/mythdb_access" ]]; then
    M2K_INSTALL_MYTHDB_ACCESS_FILE="$(mktemp "/tmp/m2k_install_mythdb_access_${Today}-XXXX")"
    cp -p "${SCRIPT_PATH}/mythdb_access" "$M2K_INSTALL_MYTHDB_ACCESS_FILE"
    [[ "$?" != 0 ]] && err "Failed to create a temporary copy of mythdb_access for install."
  else
    err "Cannot find the python script for accessing MythTV-DB: '${SCRIPT_PATH}/mythdb_access'."
    return 1
  fi
  
  #Make a temporary copy of bashlogging
  if [[ -f "${SCRIPT_PATH}/bashlogging" ]]; then
    M2K_INSTALL_BASHLOGGING_FILE="$(mktemp "/tmp/m2k_install_bashlogging_${Today}-XXXX")"
    cp -p "${SCRIPT_PATH}/bashlogging" "$M2K_INSTALL_BASHLOGGING_FILE"
    [[ "$?" != 0 ]] && err "Failed to create a temporary copy of bashlogging for install."
  else
    err "Cannot find the bashlogging script: '${SCRIPT_PATH}/bashlogging'."
    return 1
  fi
  
  #Make a temporary copy of m2k_notify
  if [[ -f "${SCRIPT_PATH}/m2k_notify" ]]; then
    M2K_INSTALL_M2K_NOTIFY_FILE="$(mktemp "/tmp/m2k_install_m2k_notify_${Today}-XXXX")"
    cp -p "${SCRIPT_PATH}/m2k_notify" "$M2K_INSTALL_M2K_NOTIFY_FILE"
    [[ "$?" != 0 ]] && err "Failed to create a temporary copy of m2k_notify for install."
  else
    err "Cannot find the m2k_notify script: '${SCRIPT_PATH}/m2k_notify'."
    return 1
  fi
  return 0
}

create_temporary_copy_conf(){
  if [[ -f "${SCRIPT_PATH}/myth2kodi.conf" ]]; then
    M2K_INSTALL_CONF_FILE="$(mktemp "/tmp/m2k_install_conf_${Today}-XXXX")"
    cp -p "${SCRIPT_PATH}/myth2kodi.conf" "$M2K_INSTALL_CONF_FILE"
    [[ "$?" != 0 ]] && err "Failed to create a temporary copy of myth2kodi.conf for install."
  else
    err "Cannot find the myth2kodi.conf script: '${SCRIPT_PATH}/myth2kodi.conf'."
    return 1
  fi
  return 0
}

set_install_dir(){
  CUSTOM_INSTALL_DIR=''
  read -r -p "Where do you want myth2kodi installed? [DEFAULT:/usr/local/bin]>" CUSTOM_INSTALL_DIR
  printf '\n'
  if [[ -n "$CUSTOM_INSTALL_DIR" ]]; then
    if [[ -d "$CUSTOM_INSTALL_DIR" ]]; then
      INSTALL_DIRECTORY="$CUSTOM_INSTALL_DIR"
    else
      yesorno='N'
      printf ' %s\n\n' "The directory you provided does not exist: '$CUSTOM_INSTALL_DIR'."
      read -r -n1 -p "Do you want us to try and make it? y/(n)>" yesorno
      printf '\n'
      if [[ "${yesorno,,}" = "y" ]]; then
        mkdir -P "$CUSTOM_INSTALL_DIR"  2>&1 | err_pipe "${FUNCNAME[0]}(): "
        [[ "$?" != '0' ]] && err "Could not create requested directory: $CUSTOM_INSTALL_DIR"
      elif [[ "${yesorno,,}" = "n" ]]; then
        CUSTOM_INSTALL_DIR=''
        read -r -p "Where do you want myth2kodi installed? [DEFAULT:/usr/local/bin]>" CUSTOM_INSTALL_DIR
        printf '\n'
        if [[ -n "$CUSTOM_INSTALL_DIR" && -d "$CUSTOM_INSTALL_DIR" ]]; then
          INSTALL_DIRECTORY="$CUSTOM_INSTALL_DIR"
        else
          err "The directory you provided does not exist: '$CUSTOM_INSTALL_DIR'"
          return 1
        fi
      else
        err "You must respond with 'y' or 'n', you responded: '$yesorno'"
        return 1
      fi
    fi
  else
    INSTALL_DIRECTORY='/usr/local/bin'
  fi
  return 0
}

get_working_dir_location(){
  M2K_WORKING_DIRECTORY=''
  # Ask do you want your myth2kodi working directory "$m2kdir" initialised.
  printf ' %s\n' 'The myth2kodi script requires a working directory. This is used'
  printf ' %s\n' "to store myth2kodi's local television series tables, the file" 
  printf ' %s\n' "myth2kodi.conf which is used for user configuration settings,"
  printf ' %s\n\n' "as well as logging information and other bits and pieces."
  
  CREATE_WORKING_DIR=''
  read -r -n1 -p "Do you want to set-up a working directory for '$CALLER'? y/(n)>" CREATE_WORKING_DIR
  printf '\n'
  if [[ "${CREATE_WORKING_DIR,,}" = "y" ]]; then
    read -r -p "Where do you want the working directory? [DEFAULT:$HOME/.myth2kodi]>" M2K_WORKING_DIRECTORY
    printf '\n'
  else
    return 0
  fi
  if [[ -n "$M2K_WORKING_DIRECTORY" ]]; then
    if [[ ! -d "$M2K_WORKING_DIRECTORY" ]]; then
    	#Two levels of inception:
      if [[ -w "$(dirname "$M2K_WORKING_DIRECTORY")" ]] || [[ ! -e "$(dirname "$M2K_WORKING_DIRECTORY")" && -w "$(dirname "$(dirname "$M2K_WORKING_DIRECTORY")")" ]]; then
        inform "Working directory will be set as: $M2K_WORKING_DIRECTORY"
      else
        err "You do not have permission to create '$M2K_WORKING_DIRECTORY' or its parent."
        M2K_WORKING_DIRECTORY="$HOME/.myth2kodi"
      fi
    fi
  else
    M2K_WORKING_DIRECTORY="$HOME/.myth2kodi"
  fi
  return 0
}

make_customisations(){
  #Modify the m2kdir dir in myth2kodi if that was requested
  if [[ "$M2K_WORKING_DIRECTORY" != "$HOME/.myth2kodi" ]]; then
    sed -i 's|m2kdir="$HOME/.myth2kodi"|m2kdir="'"${M2K_WORKING_DIRECTORY}"'"|' "$M2K_INSTALL_MYTH2KODI_FILE"
  fi

  #Set the callers user-name as the Librarian
  if [[ "${CREATE_WORKING_DIR,,}" = "y" ]]; then
    sed -i "s|#\?Librarian='mythtv'|Librarian='$CALLER'|" "$M2K_INSTALL_CONF_FILE"
  fi

  return 0
}

install_scripts(){
  if [[ -w "$INSTALL_DIRECTORY" ]]; then
    cp -p "$M2K_INSTALL_MYTH2KODI_FILE"     "$INSTALL_DIRECTORY" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    cp -p "$M2K_INSTALL_MYTHDB_ACCESS_FILE" "$INSTALL_DIRECTORY" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    cp -p "$M2K_INSTALL_BASHLOGGING_FILE"   "$INSTALL_DIRECTORY" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    cp -p "$M2K_INSTALL_M2K_NOTIFY_FILE"    "$INSTALL_DIRECTORY" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
  else
    sudo cp -p "$M2K_INSTALL_MYTH2KODI_FILE"     "$INSTALL_DIRECTORY" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    sudo cp -p "$M2K_INSTALL_MYTHDB_ACCESS_FILE" "$INSTALL_DIRECTORY" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    sudo cp -p "$M2K_INSTALL_BASHLOGGING_FILE"   "$INSTALL_DIRECTORY" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    sudo cp -p "$M2K_INSTALL_M2K_NOTIFY_FILE"    "$INSTALL_DIRECTORY" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
  fi
}

setup_working_dir(){
  if [[ "${CREATE_WORKING_DIR,,}" = "y" ]]; then
    # If directory does not already exist: create working directory 
    [[ -d "$M2K_WORKING_DIRECTORY" ]] || mkdir -p "$M2K_WORKING_DIRECTORY"
  
    # If myth2kodi.conf does not already exist: Copy myth2kodi.conf template into place .
    [[ -f "$M2K_WORKING_DIRECTORY/myth2kodi.conf" ]] || cp -p "$M2K_INSTALL_CONF_FILE" "$M2K_WORKING_DIRECTORY"
  
    # Copy myth2kodi.png and myth2kodi_failed.png into place.
    [[ -f "$M2K_WORKING_DIRECTORY/myth2kodi.png" ]] || cp -p "${SCRIPT_PATH}/myth2kodi.png" "$M2K_WORKING_DIRECTORY"
    [[ -f "$M2K_WORKING_DIRECTORY/myth2kodi_failed.png" ]] || cp -p "${SCRIPT_PATH}/myth2kodi_failed.png" "$M2K_WORKING_DIRECTORY"
  fi
}

############################################################################
############################### Main Script ################################
############################################################################

# Initialisation: Who; Where; What; When; logging; etc...
m2k_install_init
[[ "$?" != '0' ]] && exit 1

#Orientation message
printf '        %s\n'   "#######################################"
printf '        %s\n'   "#### Install Script for myth2kodi. ####"
printf '        %s\n'   "#######################################"
printf '        %s\n\n' "${BASH_SOURCE[0]}"
printf ' %s\n' 'This script will walk you through the installation process.'
printf ' %s\n' 'It allows you to customise some of the installation. However,'
printf ' %s\n' 'just pressing enter for each option will do a default install.'
printf ' %s\n' 'If you select an install directory that requires elevated'
printf ' %s\n' 'privileges (such as the default "/usr/local/bin"), you will be'
printf ' %s\n\n' 'asked for your sudo password by the system commands as needed.'

#Should we proceed?
yesorno='N'
read -r -n1 -p "Do you want to install myth2kodi? y/(n)>" yesorno
printf '\n'
if [[ "$yesorno" != "y" ]]; then
  inform "You must press 'y' to continue, installation aborted."
  exit 1
fi

############################ Gather Information ############################
#Make temporary copies of the files to be installed
prepare_installation
[[ "$?" != '0' ]] && exit 1

#Set installation directory
set_install_dir
[[ "$?" != '0' ]] && exit 1

#Ask if working directory set-up is wanted
get_working_dir_location

#################### Make Any Requested Customisations #####################
#Add customisations to myth2kodi and myth2kodi.conf
make_customisations

########################### Install Everything #############################
# Copy all scripts to proper directory, only use sudo if necessary
install_scripts

#If working directory set-up was requested then do it...
setup_working_dir

###################### Installation Complete Messages ######################


#For configuration and setup help see

#For usage help see
#myth2kodi --help | less

#Be sure to run myth2kodi --diagnostics to verify your configuration settings and to check that the current version is compatible with your system 
