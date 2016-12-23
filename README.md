<img align="right" src="myth2kodi.png" alt="myth2kodi icon" />

# myth2kodi
*myth2kodi is a modified version of [mythicalLibrarian by Adam Outler](https://github.com/adamoutler/mythicallibrarian).*

The myth2kodi script automates the mapping of MythTV recordings to a Kodi
library. It is designed to be a user job in MythTV. It can also be run
manually from a command line. It must have access to your MythTV recordings.
The program generates file names compatible with Kodi, then moves or links
recordings based on user settings. Comskip and NFO files are also generated
from your MythTV database, as required, so that Kodi can make use of them.
For usage and command line options see: `myth2kodi --help`

### Quick Start Guide
  + Download the release tarball.
  + Make sure you have the dependencies installed, see below.
  + Copy the four scripts (*myth2kodi*, *mythdb_access*, *m2k_notify*, and
    *bashlogging*) into the appropriate directory, these first three steps
    are covered in a little more detail in [INSTALL.md](./doc/INSTALL.md).
  + Modify the user settings for your setup, see [CONFIGURE.md](./doc/CONFIGURE.md).
  + Check basic functionality with: `myth2kodi --diagnostics`

#### Dependencies
**curl** -- downloads webpages and sends commands to Kodi;  
**jq** -- parses json files, used for tvmaze data;  
**agrep** -- provides fuzzy string matching;  
**libnotify-bin** -- allows GNOME desktop notifications;  
**mythbackend** -- Access the MythTV database.  

#### Installation & Configuration
The myth2kodi file should be placed in the users path, see the `binpath`
variable in user settings (Default: `/usr/local/bin`). Some of the
functionality of this script is provided in other files, these will also
need to be placed in `binpath` along with this script. The three supporting
scripts to myth2kodi are:  
**mythdb_access** -- Uses MythTV python bindings to access database information.  
**m2k_notify** -- A script for sending notifications to Gnome Desktop.  
[**bashlogging**](https://github.com/stuart-knock/bash-tools) --
                A set of bash functions that provide the logging mechanism used
                throughout myth2kodi.

#### Usage
myth2kodi can be used as a MythTV user-job or from the commmand-line.

The MythTV user job should be called as follows:

    $binpath/myth2kodi "%DIR%/%FILE%"

where `$binpath` is replaced by the full explicit path from USER SETTINGS.
To process a recording at the command line, the script can be called with the
following form:
    
    myth2kodi "Input File" "show name" "episode name"

for example:

    myth2kodi "/home/myth/recordings/2308320472023429837.mpg" "South Park" "Here Comes the Neighborhood"

for additional functionality type:
    
    myth2kodi --help


#### Repository Overview
<p>
  ├── <a href="./myth2kodi">myth2kodi</a> (The main script.) <br>
  ├── <a href="./mythdb_access">mythdb_access</a> (Accesses MythTV-DB using Python bindings.) <br>
  ├── <a href="./m2k_notify">m2k_notify</a> (Sends desktop notifications.) <br>
  ├── <a href="./bashlogging">bashlogging</a> (Provides a configurable logging mechanism.) <br>
  ├── <a href="./myth2kodi.conf">myth2kodi.conf</a> (A complete configuration template.) <br>
  ├── <a href="./myth2kodi.png">myth2kodi.png</a> (The icon displayed with desktop notifications on successful processing.) <br>
  ├── <a href="./myth2kodi_failed.png">myth2kodi_failed.png</a> (The icon displayed with desktop notifications on failed processing.) <br>
  ├── <a href="./showTranslations.SydFTA">showTranslations.SydFTA</a> (An example translation file for Sydney free-to-air guide data.) <br>
  ├── <a href="./guessepisodefromplot.py">guessepisodefromplot.py</a> (Possible future NLP addon.) <br>
  ├── <a href="./doc/">doc</a> (Documentation.) <br>
      ├── <a href="./doc/OVERVIEW.md">OVERVIEW.md</a> (An overview of the myth2kodi documentation.) <br>
      ├── <a href="./doc/INSTALL.md">INSTALL.md</a> (A description of how to install myth2kodi.) <br>
      ├── <a href="./doc/CONFIGURE.md">CONFIGURE.md</a> (An overview of the configuration options.) <br>
      ├── <a href="./doc/USAGE.md">USAGE.md</a> (A brief guide to using myth2kodi.) <br>
      ├── <a href="./doc/key_differences_to_mythicalLibrarian.md">key_differences_to_mythicalLibrarian.md</a> (How is myth2kodi different from mythicalLibrarian?) <br>
      ├── <a href="./doc/create_a_dummy_system_for_testing.md">create_a_dummy_system_for_testing.md</a> (Rough guide to building a test system that mirrors your actual system.) <br>
      └── <a href="./doc/example_myth2kodi.conf">example_myth2kodi.conf</a> (A minimal example configuration file.) <br>
  ├── <a href="./doc/">tools</a> (Simple scripts that do something useful using myth2kodi.) <br>
      └── <a href="./tools/manual_process">manual_process</a> (Helps manually processing failed episode identification.) <br>
  └── <a href="./attic/">attic</a> (Old stuff I just haven't thrown away yet.) <br>
</p>
