#Key Differences to [mythicalLibrarian](https://github.com/adamoutler/mythicallibrarian)

## Scripts
### Added:
**bashlogging**

### Renamed:
*mythicalLibrarian* ==> **myth2kodi**  
*MythDataGrabber* ==> **mythdb_access**  
*librarian-notify-send* ==> **m2k_notify**  


## Changes to command flags
### Added:
**--movie**: *Specifies that the recording being processed is a movie.*  
**--comskip**: *Regenerates the comskip file for recordings that have
                already been processed.*  
**--series-info**: *Updates our local database tables for a specified series.*  
**--delete**: *Deletes a specified recording and its associated database entry.*  
**--disconnect**: *Disconnects a specified recording from MythTV, deleting the
                   MythTV-DB entry.*  
**--recording-info**: *Retrieves information on a recording from the MythTV-DB
                       and prints it to stdout.*  
**--log**: *Extracts just those parts of the log files relevant to the
            processing of a specified recording and displays them in a pager.*  
**--cleanse**: *Delete archived log files, myth2kodi database files, and daily
                report files that are older than the lifetime specified by
                their associated user setting.*

### Renamed:
*--mythicalDiagnostics* ==> **--diagnostics**  
*--doMaintenance* ==> **--maintenance**

### Removed:
**--update**


## Configuration Options
### Added:
**Librarian**: *Name of the user who will run myth2kodi.*  
**StorageGroupFallback**: *Use StorageGroup to determine if recording is a movie.*  
**PlotMatchFallback**: *Use fuzzy matching the Plot field to determine episode info.*  
**binpath**: *Directory containing myth2kodi and associated scripts.*  
**M2K_TMPDIR**: *Directory myth2kodi uses for temporary files.*  
**MAINTENANCE_PERIOD**: *How often (in seconds) to perform routine maintenance.*  
**LOGLEVEL**: *Controls the amount of information myth2kodi reports.*  
**LogFileName**: *Is the base of the name of the main log file*  
**LOG_LIFE**: *How long to persist archived log files in months.*  
**M2K_DB_LIFE**: *How long to persist archived myth2kodi database files in months.*  
**DAILYREPORT_LIFE**: *How long to persist daily report files in months*  
**LOGTYPE**: *Defines where to direct logging messages.*

### Renamed:
*mythicalLibrarian* ==> m2kdir**  
*XBMCIPs* ==> **KODIIPs**  
*XBMCUpdate* ==> **KODIUpdate**  
*XBMCNotify* ==> **KODINotify**  
*XBMCClean* ==>  **KODIClean**  
*maxItems* ==> **RSSmaxItems**

### Removed:
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
A large number of functions and variables have been renamed to improve conformance
with standard practices for bash scripts. A considerable number of new functions
have been added. A large number of minor bugs were fixed along the way (of course,
the extent of the changes probably means new ones have been introduced too... ).
