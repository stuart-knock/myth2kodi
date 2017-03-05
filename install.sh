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

#How to go about the installation. The default 'Interactive' mode will give you
#the option of switching to the 'Quick' mode when you run the install script.
#The 'Quick' mode just does a default install with no questions or feedback
#about what is happening unless there is an error -- a log file is still written
#in 'Quick' mode. Quick mode does not set-up myth2kodi's working directory.
#Options: ['Interactive'(DEFAULT)|'Quick']
INSTALL_TYPE='Interactive'

############################## Logging Settings ##############################
#The settings below are for the bashlogging script which provides the configurable
#logging functionality used in myth2kodi.
#LOGLEVEL provides control over the amount of information myth2kodi reports.
#    0=Only Errors;
#    1=adds warnings;
#    2=adds more information;  --> DEFAULT
#    3=provides debugging output.
#Recommend 2 to keep track of what myth2kodi's install script has done.
#Only use 3 if you have a particular problem that you're trying to track down.
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
  #Where am I
  SCRIPT_PATH="$( cd "$(dirname "${BASH_SOURCE[0]}")" || return 1 ; pwd -P )"

  #Who called me...
  CALLER=$(whoami) ; declare -gr CALLER

  #And when...
  local script_start_time
  script_start_time="$(date +%H:%M:%S)" #Time in a readable IEEE standard format, ie HH:MM:SS
  TODAY="$(date +%F)"  #Date in IEEE standard format, ie YYYY-mm-dd
  FILE_NAME_NOW="$(date +%FT%H%M%S)"  #ISO 8601: YYYY-mm-ddThhMMSS
  declare -gr TODAY
  declare -gr FILE_NAME_NOW
  
  #Initialise logging system -- boot strapping, this is the bashlogging we're about to install.
  LOGFILE="$(mktemp "/tmp/m2k_install_log_${TODAY}-XXXX")"
  declare -gr LOGFILE
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
  inform "Running myth2kodi's installation script as $CALLER"
  inform "Install script called on $TODAY at $script_start_time."

  #Strongly recommend against running as root.
  if [[ "$EUID" = '0' || "$UID" = '0' || "$USER" = 'root' || "$CALLER" = 'root' ]]; then
    warn "You do NOT need to run myth2kodi's install script as root."
    warncont "If you select an install directory that requires elevated"
    warncont "privileges, you will be asked for your sudo password by the"
    warncont "system commands as needed."
    return 1
  fi

  #What am I
  if [[ ! -d "${SCRIPT_PATH}/.git" ]]; then
    local m2kVersion
    eval "$(grep -o 'm2kVersion=".*"' "${SCRIPT_PATH}/myth2kodi")"
    inform "Running installation script for $m2kVersion"
  fi

  #Pre-declare global variables set beyond this point in the script, to make it
  #easier to keep track of them.
  #Temporary installation files:
  declare -g M2K_INSTALL_MYTH2KODI_FILE
  declare -g M2K_INSTALL_MYTHDB_ACCESS_FILE
  declare -g M2K_INSTALL_BASHLOGGING_FILE
  declare -g M2K_INSTALL_M2K_NOTIFY_FILE
  declare -g M2K_INSTALL_CONF_FILE
  #Target directories:
  declare -g INSTALL_DIRECTORY
  declare -g M2K_WORKING_DIRECTORY

  inform "Install script successfully initialised."
  debug "SCRIPT_PATH='$SCRIPT_PATH'"
  debug "CALLER='$CALLER'"
  return 0
}

#Make temporary copies of the files to be installed so we can modify them 
#rather than the originals.
prepare_installation(){
  debug "ENTERING: ${FUNCNAME[0]}() ; CALLED FROM: ${FUNCNAME[1]}()"
  debugcont "DEVELOPMENT_INSTALL='$DEVELOPMENT_INSTALL'"
  debugcont "SCRIPT_PATH='$SCRIPT_PATH'"

  local install_source
  local original_dir
  local original_branch orig_branch_status
  local latest_release latest_release_status

  #Use the presence of a .git directory to infer that we're in a repo
  [[ -d "${SCRIPT_PATH}/.git" ]] && install_source='repo'
  
  if [[ "$install_source" == 'repo' && "$DEVELOPMENT_INSTALL" != 'Enabled' ]]; then
    debug "In a repository, so will switch to a release tag before installing."

    #Make sure we have git
    local pkgpath_git=''
    pkgpath_git=$(command -v git) || { err "No git, but we seem to be in a repo"; return 1; }
    debug "Found git at: '$pkgpath_git'"

    #Where we started
    original_dir="$( pwd -P )"
    debug "original_dir='$original_dir'"

    #Make sure we are actually in the directory containing install.sh
    cd "${SCRIPT_PATH}" || return 1

    #What branch did we start on
    debug 'Getting the repository branch we were in when called.'
    original_branch="$( git rev-parse --abbrev-ref HEAD )"
    orig_branch_status="$?"
    debug "original_branch='$original_branch'"
    [[ "$orig_branch_status" != 0 ]] && { err "Failed to get original branch." ; return 1; }

    #Make sure we are in master
    debug "Make sure we start from master."
    git checkout master 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1

    #Get the latest release tag
    debug "Get the latest release tag."
    latest_release="$(git tag --list | tail -1)"
    latest_release_status="$?"
    debug "latest_release='$latest_release'"
    [[ "$latest_release_status" != 0 ]] && { err "Failed to get latest release." ; return 1; }

    #Switch to a temporary "detached HEAD" state
    debug "Switch to 'detached HEAD' state at the latest release tag."
    git checkout tags/"$latest_release" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1

    #Copy the release version of the scripts and .conf file
    create_temporary_copies_scripts
    if [[ "$?" != '0' ]]; then
      printf '%s\n' "Failed creating temporary copies of scripts, see '$LOGFILE'."
      return 1
    fi
    create_temporary_copy_conf
    if [[ "$?" != '0' ]]; then
      printf '%s\n' "Failed creating temporary copy of configuration file, see '$LOGFILE'."
      return 1
    fi
    #Put things back where they were
    debug "Switch back to the branch we started on."
    git checkout "$original_branch" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
    #Change back to where we started
    debug "Change back to the directory we started in."
    cd "$original_dir" || return 1
  else #We are either in a release tar-ball or a repo with 'Development' install Enabled.
    #Copy the available version of the scripts and .conf file
    create_temporary_copies_scripts
    if [[ "$?" != '0' ]]; then
      printf '%s\n' "Failed creating temporary copies of scripts, see '$LOGFILE'."
      return 1
    fi
    create_temporary_copy_conf
    if [[ "$?" != '0' ]]; then
      printf '%s\n' "Failed creating temporary copy of configuration file, see '$LOGFILE'."
      return 1
    fi
  fi
  return 0
}

create_temporary_copies_scripts(){
  debug "ENTERING: ${FUNCNAME[0]}() ; CALLED FROM: ${FUNCNAME[1]}()"
  debugcont "SCRIPT_PATH='$SCRIPT_PATH'"
  #Make a temporary copy of myth2kodi
  if [[ -f "${SCRIPT_PATH}/myth2kodi" ]]; then
    debug "Creating a temporary copy of myth2kodi for install."
    M2K_INSTALL_MYTH2KODI_FILE="$(mktemp "/tmp/m2k_install_myth2kodi_${TODAY}-XXXX")"
    [[ "$?" != '0' ]] && return 1
    cp -p "${SCRIPT_PATH}/myth2kodi" "$M2K_INSTALL_MYTH2KODI_FILE" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
  else
    err "Cannot find the main script: '${SCRIPT_PATH}/myth2kodi'."
    return 1
  fi

  #Make a temporary copy of mythdb_access
  if [[ -f "${SCRIPT_PATH}/mythdb_access" ]]; then
    debug "Creating a temporary copy of mythdb_access for install."
    M2K_INSTALL_MYTHDB_ACCESS_FILE="$(mktemp "/tmp/m2k_install_mythdb_access_${TODAY}-XXXX")"
    [[ "$?" != '0' ]] && return 1
    cp -p "${SCRIPT_PATH}/mythdb_access" "$M2K_INSTALL_MYTHDB_ACCESS_FILE" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
  else
    err "Cannot find the python script for accessing MythTV-DB: '${SCRIPT_PATH}/mythdb_access'."
    return 1
  fi

  #Make a temporary copy of bashlogging
  if [[ -f "${SCRIPT_PATH}/bashlogging" ]]; then
    debug "Creating a temporary copy of bashlogging for install."
    M2K_INSTALL_BASHLOGGING_FILE="$(mktemp "/tmp/m2k_install_bashlogging_${TODAY}-XXXX")"
    [[ "$?" != '0' ]] && return 1
    cp -p "${SCRIPT_PATH}/bashlogging" "$M2K_INSTALL_BASHLOGGING_FILE" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
  else
    err "Cannot find the bashlogging script: '${SCRIPT_PATH}/bashlogging'."
    return 1
  fi

  #Make a temporary copy of m2k_notify
  if [[ -f "${SCRIPT_PATH}/m2k_notify" ]]; then
    debug "Creating a temporary copy of m2k_notify for install."
    M2K_INSTALL_M2K_NOTIFY_FILE="$(mktemp "/tmp/m2k_install_m2k_notify_${TODAY}-XXXX")"
    [[ "$?" != '0' ]] && return 1
    cp -p "${SCRIPT_PATH}/m2k_notify" "$M2K_INSTALL_M2K_NOTIFY_FILE" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
  else
    err "Cannot find the m2k_notify script: '${SCRIPT_PATH}/m2k_notify'."
    return 1
  fi
  debug "M2K_INSTALL_MYTH2KODI_FILE='$M2K_INSTALL_MYTH2KODI_FILE'"
  debug "M2K_INSTALL_MYTHDB_ACCESS_FILE='$M2K_INSTALL_MYTHDB_ACCESS_FILE'"
  debug "M2K_INSTALL_BASHLOGGING_FILE='$M2K_INSTALL_BASHLOGGING_FILE'"
  debug "M2K_INSTALL_M2K_NOTIFY_FILE='$M2K_INSTALL_M2K_NOTIFY_FILE'"
  return 0
}

create_temporary_copy_conf(){
  debug "ENTERING: ${FUNCNAME[0]}() ; CALLED FROM: ${FUNCNAME[1]}()"
  debugcont "SCRIPT_PATH='$SCRIPT_PATH'"
  debugcont "TODAY='$TODAY'"
  if [[ -f "${SCRIPT_PATH}/myth2kodi.conf" ]]; then
    debug "Creating a temporary copy of myth2kodi.conf for install."
    M2K_INSTALL_CONF_FILE="$(mktemp "/tmp/m2k_install_conf_${TODAY}-XXXX")"
    [[ "$?" != '0' ]] && return 1
    cp -p "${SCRIPT_PATH}/myth2kodi.conf" "$M2K_INSTALL_CONF_FILE" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
  else
    err "Cannot find the myth2kodi.conf script: '${SCRIPT_PATH}/myth2kodi.conf'."
    return 1
  fi
  return 0
}

get_install_type(){
  debug "ENTERING: ${FUNCNAME[0]}() ; CALLED FROM: ${FUNCNAME[1]}()"

  #Install mode message
  printf ' %s\n' 'There are two modes of installation:'
  printf '   %s\n' '1. Interactive (Preferred) -- Informs you of progress, provides'
  printf '               %s\n' 'the option to select non-default install location,'
  printf '               %s\n\n' 'as well as some other basic configuration.'
  printf '   %s\n' '2. Quick -- Do default install, no questions or feedback, does'
  printf '               %s\n\n' 'not create a myth2kodi working directory.'

  #Install mode selection
  local install_type_code
  read -r -p "What type of install do you want to do? (1)|2 >" install_type_code
  printf '\n'
  [[ -z "$install_type_code" ]] && install_type_code=1
  if [[ "$install_type_code" = "1" || "${install_type_code,,}" = 'interactive' ]]; then
    inform "Selected interactive install mode."
  elif [[ "$install_type_code" = "2" || "${install_type_code,,}" = 'quick'  ]]; then
    inform "Selected quick install mode."
    INSTALL_TYPE='Quick'
  else
    err "Failed to specify install mode correctly, you provided: '$install_type_code'"
    return 1
  fi
  return 0
}

get_install_dir(){
  debug "ENTERING: ${FUNCNAME[0]}() ; CALLED FROM: ${FUNCNAME[1]}()"
  local custom_install_dir
  read -r -p "Where do you want myth2kodi installed? [DEFAULT:/usr/local/bin]>" custom_install_dir
  printf '\n'
  if [[ -n "$custom_install_dir" ]]; then
    if [[ -d "$custom_install_dir" ]]; then
      INSTALL_DIRECTORY="$custom_install_dir"
    else
      local yesorno
      printf ' %s\n\n' "The directory you provided does not exist: '$custom_install_dir'."
      read -r -n1 -p "Do you want us to try and make it? (y)/n>" yesorno
      printf '\n'
      [[ -z "$yesorno" ]] && yesorno='y'
      if [[ "${yesorno,,}" = "y" ]]; then
        debug 'Trying to create install directory.'
        mkdir -P "$custom_install_dir" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
        if [[ "${PIPESTATUS[0]}" != '0' ]]; then
          err "Could not create requested directory: $custom_install_dir"
          return 1
        fi
        INSTALL_DIRECTORY="$custom_install_dir"
      else
        err "${FUNCNAME[0]}(): Cannot install into a directory that does not exist: '$custom_install_dir'."
        return 1
      fi
    fi
  else
    INSTALL_DIRECTORY='/usr/local/bin'
  fi
  inform "Install directory set as: '$INSTALL_DIRECTORY'"
  return 0
}

get_working_dir_location(){
  debug "ENTERING: ${FUNCNAME[0]}() ; CALLED FROM: ${FUNCNAME[1]}()"

  # Ask do you want your myth2kodi working directory "$m2kdir" initialised.
  printf ' %s\n' 'The myth2kodi script requires a working directory. This is used'
  printf ' %s\n' "to store myth2kodi's local television series tables, the file" 
  printf ' %s\n' "myth2kodi.conf which is used for user configuration settings,"
  printf ' %s\n\n' "as well as logging information and other bits and pieces."

  #Get user choices regarding working directory set-up.
  read -r -n1 -p "Do you want to set-up a working directory for '$CALLER'? y/(n)>" CREATE_WORKING_DIR
  printf '\n\n'
  if [[ "${CREATE_WORKING_DIR,,}" = "y" ]]; then
    read -r -p "Where do you want the working directory? [DEFAULT:$HOME/.myth2kodi]>" M2K_WORKING_DIRECTORY
    printf '\n'
  else
    debug 'Not setting-up working directory.'
    inform 'You will need to manually specify a working directory.'
    return 0
  fi

  #If specified, check the custom working directory.
  if [[ -n "$M2K_WORKING_DIRECTORY" ]]; then
    if [[ ! -d "$M2K_WORKING_DIRECTORY" ]]; then
      #Two levels of inception:
      if [[ -w "$(dirname "$M2K_WORKING_DIRECTORY")" ]] || [[ ! -e "$(dirname "$M2K_WORKING_DIRECTORY")" && -w "$(dirname "$(dirname "$M2K_WORKING_DIRECTORY")")" ]]; then
        inform "Working directory will be set as: $M2K_WORKING_DIRECTORY"
      else
        err "You do not have permission to create '$M2K_WORKING_DIRECTORY' or its parent."
        return 1
      fi
    fi
  else
    debug 'Setting default working directory.'
    M2K_WORKING_DIRECTORY="$HOME/.myth2kodi"
  fi
  return 0
}

make_customisations(){
  debug "ENTERING: ${FUNCNAME[0]}() ; CALLED FROM: ${FUNCNAME[1]}()"
  debugcont "HOME='$HOME'"
  debugcont "M2K_WORKING_DIRECTORY='$M2K_WORKING_DIRECTORY'"
  debugcont "CREATE_WORKING_DIR='$CREATE_WORKING_DIR'"
  debugcont "CALLER='$CALLER'"
  debugcont "M2K_INSTALL_CONF_FILE='$M2K_INSTALL_CONF_FILE'"

  #Modify the m2kdir dir in myth2kodi if that was requested
  if [[ "$M2K_WORKING_DIRECTORY" != "$HOME/.myth2kodi" ]]; then
    debug "Adding custom working directory to the myth2kodi script's settings."
    sed -i 's|^m2kdir="$HOME/.myth2kodi"|m2kdir="'"${M2K_WORKING_DIRECTORY}"'"|' "$M2K_INSTALL_MYTH2KODI_FILE" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
  fi

  #Set the callers user-name as the Librarian
  if [[ "${CREATE_WORKING_DIR,,}" = "y" ]]; then
    debug "Setting 'Librarian' in myth2kodi.conf to: '$CALLER'."
    sed -i "s|#\?Librarian='mythtv'|Librarian='$CALLER'|" "$M2K_INSTALL_CONF_FILE" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
  fi

  return 0
}

install_scripts(){
  debug "ENTERING: ${FUNCNAME[0]}() ; CALLED FROM: ${FUNCNAME[1]}()"
  debugcont "INSTALL_DIRECTORY='$INSTALL_DIRECTORY'"
  debugcont "M2K_INSTALL_MYTH2KODI_FILE='$M2K_INSTALL_MYTH2KODI_FILE'"
  debugcont "M2K_INSTALL_MYTHDB_ACCESS_FILE='$M2K_INSTALL_MYTHDB_ACCESS_FILE'"
  debugcont "M2K_INSTALL_BASHLOGGING_FILE='$M2K_INSTALL_BASHLOGGING_FILE'"
  debugcont "M2K_INSTALL_M2K_NOTIFY_FILE='$M2K_INSTALL_M2K_NOTIFY_FILE'"

  if [[ -w "$INSTALL_DIRECTORY" ]]; then
    #We can install without sudo, probably installing in a caller owned directory.
    cp -p "$M2K_INSTALL_MYTH2KODI_FILE"     "$INSTALL_DIRECTORY/myth2kodi"     2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
    cp -p "$M2K_INSTALL_MYTHDB_ACCESS_FILE" "$INSTALL_DIRECTORY/mythdb_access" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
    cp -p "$M2K_INSTALL_BASHLOGGING_FILE"   "$INSTALL_DIRECTORY/bashlogging"   2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
    cp -p "$M2K_INSTALL_M2K_NOTIFY_FILE"    "$INSTALL_DIRECTORY/m2k_notify"    2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
  else #Assume we are installing in a system directory
    #Copy the scripts preserving mode and timestamp
    sudo cp --preserve=mode,timestamps "$M2K_INSTALL_MYTH2KODI_FILE"     "$INSTALL_DIRECTORY/myth2kodi"     2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
    sudo cp --preserve=mode,timestamps "$M2K_INSTALL_MYTHDB_ACCESS_FILE" "$INSTALL_DIRECTORY/mythdb_access" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
    sudo cp --preserve=mode,timestamps "$M2K_INSTALL_BASHLOGGING_FILE"   "$INSTALL_DIRECTORY/bashlogging"   2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
    sudo cp --preserve=mode,timestamps "$M2K_INSTALL_M2K_NOTIFY_FILE"    "$INSTALL_DIRECTORY/m2k_notify"    2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
    #Some sudo setups will preserve owner, so make sure owner is now root.
    sudo chown root:root "$INSTALL_DIRECTORY/myth2kodi"     2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
    sudo chown root:root "$INSTALL_DIRECTORY/mythdb_access" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
    sudo chown root:root "$INSTALL_DIRECTORY/bashlogging"   2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
    sudo chown root:root "$INSTALL_DIRECTORY/m2k_notify"    2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != '0' ]] && return 1
  fi
  return 0
}

setup_working_dir(){
  debug "ENTERING: ${FUNCNAME[0]}() ; CALLED FROM: ${FUNCNAME[1]}()"
  debugcont "CREATE_WORKING_DIR='$CREATE_WORKING_DIR'"
  debugcont "M2K_WORKING_DIRECTORY='$M2K_WORKING_DIRECTORY'"
  debugcont "SCRIPT_PATH='$SCRIPT_PATH'"

  if [[ "${CREATE_WORKING_DIR,,}" = "y" ]]; then
    # If directory does not already exist: create working directory 
    [[ -d "$M2K_WORKING_DIRECTORY" ]] || mkdir -p "$M2K_WORKING_DIRECTORY" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != 0 ]] && return 1
  
    # If myth2kodi.conf does not already exist: Copy myth2kodi.conf template into place .
    [[ -f "$M2K_WORKING_DIRECTORY/myth2kodi.conf" ]] || cp -p "$M2K_INSTALL_CONF_FILE" "$M2K_WORKING_DIRECTORY/myth2kodi.conf" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != 0 ]] && return 1
  
    # Copy myth2kodi.png and myth2kodi_failed.png into place.
    [[ -f "$M2K_WORKING_DIRECTORY/myth2kodi.png" ]] || cp -p "${SCRIPT_PATH}/myth2kodi.png" "$M2K_WORKING_DIRECTORY" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != 0 ]] && return 1
    [[ -f "$M2K_WORKING_DIRECTORY/myth2kodi_failed.png" ]] || cp -p "${SCRIPT_PATH}/myth2kodi_failed.png" "$M2K_WORKING_DIRECTORY" 2>&1 | err_pipe "${FUNCNAME[0]}(): "
    [[ "${PIPESTATUS[0]}" != 0 ]] && return 1
  fi
  return 0
}

############################################################################
############################### Main Script ################################
############################################################################

# Initialisation: Who; Where; What; When; logging; etc...
m2k_install_init
[[ "$?" != '0' ]] && { printf '%s\n' "Failed during init, see '$LOGFILE'."; exit 1 ; }

if [[ "$INSTALL_TYPE" != 'Quick' ]]; then
  #Orientation message
  printf '\n        %s\n'   "#######################################"
  printf '        %s\n'   "#### Install Script for myth2kodi. ####"
  printf '        %s\n'   "#######################################"
  printf '        %s\n\n' "${BASH_SOURCE[0]}"
  printf ' %s\n' 'This script will walk you through the installation process.'
  printf ' %s\n' 'It allows you to customise some of the installation. However,'
  printf ' %s\n' 'just pressing enter for each option (after this first one)'
  printf ' %s\n' 'will do a default install. If you select an install directory'
  printf ' %s\n' 'that requires elevated privileges (such as "/usr/local/bin"),'
  printf ' %s\n' 'you will be asked for your sudo password by the system commands'
  printf ' %s\n\n' 'as needed.'

  #Should we proceed?
  read -r -n1 -p "Do you want to install myth2kodi? y/(n)>" yesorno
  printf '\n\n'
  if [[ "$yesorno" != "y" ]]; then
    inform "You must press 'y' to continue, installation aborted."
    exit 0
  fi

  #Does the caller want an Interactive or a quick and blind install.
  get_install_type
  [[ "$?" != '0' ]] && { printf '%s\n' "Failed getting install type, see '$LOGFILE'."; exit 1 ; }
fi

############################ Gather Information ############################
#Make temporary copies of the files to be installed
prepare_installation
[[ "$?" != '0' ]] && { printf '%s\n' "Failed during preparation, see '$LOGFILE'."; exit 1 ; }

if [[ "$INSTALL_TYPE" != 'Quick' ]]; then
  #Set installation directory
  get_install_dir
  [[ "$?" != '0' ]] && { printf '%s\n' "Failed setting install dir, see '$LOGFILE'."; exit 1 ; }
else
  INSTALL_DIRECTORY='/usr/local/bin'
fi

#TODO: if custom working directory but system install, warn about multiple users or maybe prevent...
if [[ "$INSTALL_TYPE" != 'Quick' ]]; then
  #Ask if working directory set-up is wanted
  get_working_dir_location
  [[ "$?" != '0' ]] && { printf '%s\n' "Failed getting working dir, see '$LOGFILE'."; exit 1 ; }
else
  M2K_WORKING_DIRECTORY="$HOME/.myth2kodi"
fi

#################### Make Any Requested Customisations #####################
#Add customisations to myth2kodi and myth2kodi.conf
make_customisations
[[ "$?" != '0' ]] && { printf '%s\n' "Failed customising install, see '$LOGFILE'."; exit 1 ; }

########################### Install Everything #############################
# Copy all scripts to proper directory, only use sudo if necessary
install_scripts
[[ "$?" != '0' ]] && { printf '%s\n' "Failed installing scripts, see '$LOGFILE'."; exit 1 ; }

if [[ "$INSTALL_TYPE" != 'Quick' ]]; then
  #If working directory set-up was requested then do it...
  setup_working_dir
  [[ "$?" != '0' ]] && { printf '%s\n' "Failed to setup working directory, see '$LOGFILE'."; exit 1 ; }
fi

################################# Clean-Up #################################

#If we're not debugging then remove temporary files.
if ((LOGLEVEL < 3)); then
  debug 'Cleaning up temporary installation files.'
  [[ -f "$M2K_INSTALL_MYTH2KODI_FILE" ]]     && rm -f "$M2K_INSTALL_MYTH2KODI_FILE"
  [[ "$?" != '0' ]] && err "Failed removing temporary file: $M2K_INSTALL_MYTH2KODI_FILE"
  [[ -f "$M2K_INSTALL_MYTHDB_ACCESS_FILE" ]] && rm -f "$M2K_INSTALL_MYTHDB_ACCESS_FILE"
  [[ "$?" != '0' ]] && err "Failed removing temporary file: $M2K_INSTALL_MYTHDB_ACCESS_FILE"
  [[ -f "$M2K_INSTALL_BASHLOGGING_FILE" ]]   && rm -f "$M2K_INSTALL_BASHLOGGING_FILE"
  [[ "$?" != '0' ]] && err "Failed removing temporary file: $M2K_INSTALL_BASHLOGGING_FILE"
  [[ -f "$M2K_INSTALL_M2K_NOTIFY_FILE" ]]    && rm -f "$M2K_INSTALL_M2K_NOTIFY_FILE"
  [[ "$?" != '0' ]] && err "Failed removing temporary file: $M2K_INSTALL_M2K_NOTIFY_FILE"
  [[ -f "$M2K_INSTALL_CONF_FILE" ]]          && rm -f "$M2K_INSTALL_CONF_FILE"
  [[ "$?" != '0' ]] && err "Failed removing temporary file: $M2K_INSTALL_CONF_FILE"
else
  debug "Not removing temporary installation files. See, '/tmp/m2k_*'."
fi

#Copy the install log file to the working directory if it exists
inform 'Installation successful.'
debug "Moving log file to: '$M2K_WORKING_DIRECTORY/m2k_install_log_${FILE_NAME_NOW}.txt'."
[[ -d "$M2K_WORKING_DIRECTORY" ]] && mv "$LOGFILE" "$M2K_WORKING_DIRECTORY/m2k_install_log_${FILE_NAME_NOW}.txt"

###################### Installation Complete Messages ######################

if [[ "$INSTALL_TYPE" != 'Quick' ]]; then
  #Successful installation message
  printf '        %s\n'   "##################################"
  printf '        %s\n'   "#### Installation Successful. ####"
  printf '        %s\n\n' "##################################"
  printf ' %s\n' "myth2kodi was installed in: $INSTALL_DIRECTORY"
  if [[ "${CREATE_WORKING_DIR,,}" = "y" ]]; then
    printf ' %s\n' "Created Working directory: $M2K_WORKING_DIRECTORY"
    printf ' %s\n\n' "Placed installation log at: $M2K_WORKING_DIRECTORY/m2k_install_log_${FILE_NAME_NOW}.txt"
  fi
  #
  printf ' %s\n' 'For configuration and setup help see:'
  printf '     %s\n' 'myth2kodi --config-help'
  printf '     %s\n' 'doc/CONFIGURE.md'
  printf ' %s\n' 'or:'
  printf '     %s\n' 'https://github.com/stuart-knock/myth2kodi/blob/master/doc/CONFIGURE.md'
  printf ' %s\n' 'For usage help see:'
  printf '     %s\n\n' ' myth2kodi --help'
  printf ' %s\n\n' 'And, before using your new/updated install, be sure to run:'
  printf '     %s\n\n' 'myth2kodi --diagnostics'
fi

exit 0
