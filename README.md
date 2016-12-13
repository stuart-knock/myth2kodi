![myth2kodi icon](myth2kodi.png)
# myth2kodi:

**WARNING:** Still a work in progress...

myth2kodi automates the mapping of MythTV recordings to a Kodi library.
It is designed to be a user job in MythTV. It can also be run manually from
a command line. It must have access to your MythTV recordings. The program
generates file names compatible with Kodi, then moves or links recordings
based on user settings. Comskip and NFO files are also generated from your
MythTV database, as required, so that Kodi can make use of them.
For usage and command line options see: `myth2kodi --help`

*myth2kodi is a modified version of [mythicalLibrarian](https://github.com/adamoutler/mythicallibrarian) by Adam Outler.*

### Quick Start Guide
  + Download the release tarball.
  + Make sure you have the dependencies installed.
  + Copy the four scripts into the appropriate directory.
  + Modify the user settings for your setup.
  + Check basic functionality with: `myth2kodi --diagnostics`

#### Dependencies
**curl** -- downloads webpages and sends commands to Kodi;  
**jq** -- parses json files, used for tvmaze data;  
**agrep** -- provides fuzzy string matching;  
**libnotify-bin** -- allows GNOME desktop notifications;  
**mythbackend** -- Access the MythTV database.  

#### Installation & Configuration
The myth2kodi file should be placed in the users path, see the binpath
variable in user settings (Default: /usr/local/bin). Some of the
functionality of this script is provided in other files, these will also
need to be placed in $binpath along with this script. They are:
MythDataGrabber -- Uses MythTV python bindings to access database information.
m2k_notify -- A script for sending notifications to Gnome Desktop.
bashlogging -- A set of bash functions that provide the logging mechanism
               used throughout myth2kodi.

#### Usage
myth2kodi can be used as a MythTV user-job or from the commmand-line.

The MythTV user job should be called as follows:

    $binpath/myth2kodi "%DIR%/%FILE%"

where "$binpath" is replaced by the full explicit path from USER SETTINGS.
At the command line, the script can be called with the following form:
    
    myth2kodi "Input File" "show name" "episode name"

for example:

    myth2kodi "/home/myth/recordings/2308320472023429837.mpg" "South Park" "Here Comes the Neighborhood"

for additional functionality type:
    
    myth2kodi --help

### User Jobs
