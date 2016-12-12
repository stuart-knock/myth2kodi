# myth2kodi:
![myth2kodi icon](myth2kodi.png)

myth2kodi automates the mapping of MythTV recordings to a Kodi library.
It is designed to be a user job in MythTV. It can also be run manually from
a command line. It must have access to your MythTV recordings. The program
generates file names compatible with Kodi, then moves or links recordings
based on user settings. Comskip and NFO files are also generated from your
MythTV database, as required, so that Kodi can make use of them.

*myth2kodi is a modified version of mythicalLibrarian by Adam Outler.*

### Quick Start Guide
  + Download the release tarball.
  + Make sure you have the dependencies installed.
  + Copy the four scripts into the appropriate directory.
  + Modify the user settings for your setup.
  + Check basic functionality with: `myth2kodi --diagnostics`

#### Dependencies
**curl** -- downloads webpages and sends commands to Kodi;
**jq** -- parses json files, used for tvmaze data.
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


### User Jobs
