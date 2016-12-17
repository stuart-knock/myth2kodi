# Usage
The main purpose of myth2kodi is to processes a MythTV recording in order to
generate a file name that Kodi will be able to make use of in building your
media library. It can do this as a MythTV user job that you can add to your
recording rules or manually, from a command line.

For a very brief overview of usage, at a command prompt run:
    
    myth2kodi --usage

The use of myth2kodi can be broken into three categories:
  1. MythTV user job;
  2. Process a recording from the command line; and
  3. Access support functionality via command line flags.

### MythTV User Job.

The MythTV user job should be called as follows:

    $binpath/myth2kodi "%DIR%/%FILE%"

where `$binpath` is replaced by the full explicit path from `myth2kodi.conf` or
the USER SETTINGS section of `myth2kodi`.


### Process a Recording from the Command Line

To process a recording at the command line, the script can be called with the
following form:
    
    myth2kodi "Input File" "show name" "episode name"

when called as a MythTV user job, the `"%DIR%/%FILE%"` argument is expanded by
MythTV to provide the `"Input File"` argument. The command line equivalent
would be, for example:
    
     myth2kodi "/home/myth/recordings/2308320472023429837.mpg"

But if we know the show and episode name we can provide them, which saves
myth2kodi having to figure them out for itself, for example:

    myth2kodi "/home/myth/recordings/2308320472023429837.mpg" "South Park" "Here Comes the Neighborhood"


### Access support functionality via command line flags.
Once myth2kodi is installed you can get an overview of additional functionality
by running:
    
    myth2kodi --help

The first argument, beginning with `--`, is a command flag telling myth2kodi
that it will be doing something other than processing a single recording in
the usual way. The first one of these that you should make use of, as the final
step of installation, is the `--diagnostics` flag. Running:
    
    myth2kodi --diagnostics

causes basic tests for the presence of dependencies to be run, it also does
some checks of the configuration and core functionality. Summaries of what is
found are printed via the logging system (by default this means both to stdout
and a file called `diagnostics.log` in the myth2kodi working directory).

*PROBABLY SHOULD PUT A DESCRIPTION OF ALL COMMAND FLAGS HERE...*

#### A practical example of using some of myth2kodi's command flags:
If a recording fails to process, you can look at the logs for that recording
to try and get an idea of why the processing failed:
    
    myth2kodi --log '/media/video/recordings/TVshows/1020_20151105093800.mpg'

In this case the series was recognised as 'Sherlock' but even falling through
to fuzzy matching the plot against myth2kodi's episode tables for Sherlock
failed to identify the correct episode (in this case the plot from the guide
data stored in our MythTV-DB was just too different to those available from
TheTVDB and tvmaze, we're only as good as our data). To see what information
your MythTV-DB contains on the recording we use:

    myth2kodi --recording-info '/media/video/recordings/TVshows/1020_20151105093800.mpg'

which, in this case returned:
    
    MythTV-DB information for: 1020_20151105093800.mpg
    
    Title='Sherlock'
    Subtitle=''
    Season=''
    Episode=''
    Airdate=''
    Originalairdate=''
    Category='Drama'
    Storagegroup='TVshows'
    Stars='0.0'
    Description='A game of cat and mouse as a crazed bomber pits his wits again Sherlock.  Who is behind these deadly puzzles  CAST Benedict Cumberbatch and Martin Freeman'
    Seriesid=''
    Programid='zw0123a003s00'
    Chanid='1020'
    Starttime='2015-11-05 19:38:00+10:00'

As you can see, the guide data broadcast by Australian free-to-air digital tv
stations can be pretty terrible. Luckily, interwebs search is a magical invention.
Copying the description field into your favourite search engine quickly reveals
that this is "Sherlock, Season 1, Episode 3, The Great Game", so, with this
knowledge at hand, we just run:
    
    myth2kodi  '/media/video/recordings/TVshows/1020_20151105093800.mpg' 'Sherlock' 'The Great Game'

and the recording is now processed correctly, with:
    
    ls -l /media/video/recordings/TVshows/1020_20151105093800.mpg

returning:
    
    lrwxrwxrwx 1 librarian users  70 Dec 17 16:07 /media/video/recordings/TVshows/1020_20151105093800.mpg -> /media/video/tv/Sherlock/Season 1/Sherlock S01E03 (The Great Game).mpg

