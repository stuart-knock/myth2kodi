# Key Differences to [mythicalLibrarian](https://github.com/adamoutler/mythicallibrarian)

## Call signature
When processing a recording, optional arguments for providing season and
episode number have been added. It now has the form:
    
    myth2kodi "Input File" ["show name"] ["episode name"] ["season-number" "episode-number"]

## Scripts
### Added:
**bashlogging**: *Provides configurable logging functionality.*  
**install.sh**: *A basic installation script.*

### Renamed:
*mythicalLibrarian* ==> **myth2kodi**  
*MythDataGrabber* ==> **mythdb_access**  
*librarian-notify-send* ==> **m2k_notify**  

### Removed:
**mythicalSetup.sh**: *A nice feature that I've, so far, been too lazy to update and maintain.*

## Changes to command flags
### Added:
**--movie**: *Specifies that the recording being processed is a movie.*  
**--comskip**: *Regenerates the comskip file for recordings that have
                already been processed.*  
**--recording-info**: *Retrieves information on a recording from your MythTV-DB
                       and prints it to stdout.*  
**--log**: *Extracts just those parts of the log files relevant to the
            processing of a specified recording and displays them in a pager.*  
**--series-info**: *Updates our local database tables for a specified series.*  
**--delete**: *Deletes a specified recording and its associated database entry.*  
**--rerecord**: *Same as --delete, but, also requests mythbackend to rerecord.*  
**--disconnect**: *Disconnects a specified recording from MythTV, deleting the
                   MythTV-DB entry.*  
**--cleanse**: *Delete archived log files, myth2kodi database files, and daily
                report files that are older than the lifetime specified by
                their associated user setting. (This is a subset of --maintenance,
                intended for when you want to clean-up myth2kodi's working files
                but not files associated with your processed recordings.)*

### Modified:
**--undo**: *Now supports single recording undo. Old behaviour is achieved with `--undo 'all'`.*

### Renamed:
*--mythicalDiagnostics* ==> **--diagnostics**  
*--doMaintenance* ==> **--maintenance**

### Removed:
**--update**: *A nice feature that I've, so far, been too lazy to update and maintain.*  
**-m**, **-s**, **-u**, **-d**: *All short forms have been removed. The version of
mythicalLibrarian I started from already had duplicates of these that made things
ambiguous. With the increased number of command flags the potential for confusion
only increased. So, it seemed safer, and easier, just to drop them.*


## Configuration Options
### Added:
**Librarian**: *Name of the user who will run myth2kodi.*  
**PROCESS_RECORDING_MODE**: *Whether to move the original recording file or just link to it.*  
**SYMLINK**: *Whether symlinking is Enabled. NOTE: different to previous parameter with same name, see PROCESS_RECORDING_MODE.*  
**StorageGroupFallback**: *Use StorageGroup to determine if recording is a movie.*  
**PlotMatchFallback**: *Use fuzzy matching the Plot field to determine episode info.*  
**binpath**: *Directory containing myth2kodi and associated scripts.*  
**M2K_TMPDIR**: *Directory myth2kodi uses for temporary files.*  
**MAINTENANCE_PERIOD**: *How often (in seconds) to perform routine maintenance.*  
**LOGLEVEL**: *Controls the amount of information myth2kodi reports.*  
**LogFileName**: *Is the base of the name of the main log file*  
**LOG_LIFE**: *How long to persist archived log files in months.*  
**M2K_DB_LIFE**: *How long to persist archived myth2kodi database files in months.*  
**DAILYREPORT_LIFE**: *How long to persist daily report files in months.*  
**LOGTYPE**: *Defines where to direct logging messages -- stdout, stderr, file.*  
**CREATE_RSS**: *Whether to create an RSS entry.*  
**RSS_DIRECTORY**: *The directory to place the RSS file.*

### Renamed:
*mythicalLibrarian* ==> **m2kdir**  
*SYMLINK* ==> **PROCESS_RECORDING_MODE** (see entries in the **Added** section above.)  
*DatabaseType* ==> **DATABASE_ACCESS**  
*XBMCIPs* ==> **KODIIPs**  
*XBMCUpdate* ==> **KODIUpdate**  
*XBMCNotify* ==> **KODINotify**  
*XBMCClean* ==>  **KODIClean**  
*maxItems* ==> **RSSmaxItems**  
*DirTracking* ==> **DIR_TRACKING_CLEANUP**

### Removed:
**SYMLINK**: *See the entries in the* **Added** *section above.*  
**DEBUGMODE**: *Its purpose was superseded by the new logging system.*

## Logging
The myth2kodi script makes heavy use of the logging system defined in the
[bashlogging](https://github.com/stuart-knock/bash-tools/blob/master/bashlogging)
script. A log rotation mechanism has also been added that archives log 
files once they exceed a certain size, appending a date-time stamp to the file
name for the archived log and compressing them.

## Internal myth2kodi databases
The formatting and maintenance of myth2kodi's local TV-series information has
been cleaned up. When possible, additional series information is also obtained
from tvmaze, in addition to TheTVDB.

## User Jobs
To add user jobs you do not need to edit the myth2kodi script, placing your job
in an appropriately named file in the `$m2kdir/userjobs` directory will be run
as the final task of the exit_job() (formerly RunJob()) function.

## Refactoring
A large number of functions and variables have been renamed to improve
consistency and conformance with standard practices for bash scripts. A
considerable number of new functions have been added. A large number of minor
bugs were fixed along the way (of course, the extent of the changes probably
means new ones have been introduced too...).
