# Usage
The main purpose of myth2kodi is to processes a MythTV recording in order to
generate a file name that Kodi will be able to make use of in building your
media library. It can do this as a MythTV user job that you can add to your
recording rules or from manually, from a command line. The myth2kodi  

The use of myth2kodi can be broken into three categories: 
    1. as a MythTV user job;
    2. to process a recording from the command line; and
    3. 

### As a MythTV User Job.

The MythTV user job should be called as follows:

    $binpath/myth2kodi "%DIR%/%FILE%"

where `$binpath` is replaced by the full explicit path from USER SETTINGS.


### To Process a Recording from the Command Line

To process a recording at the command line, the script can be called with the
following form:
    
    myth2kodi "Input File" "show name" "episode name"

when called as a MythTV user job, the `"%DIR%/%FILE%"` argument is expanded by
MythTV to provide the `"Input File"` argument. 
The command line equivalent would be, for example:
    
     myth2kodi "/home/myth/recordings/2308320472023429837.mpg"

But if we know the show and episode name we can provide them, which saves
myth2kodi having to figure them out for itself, for example:

    myth2kodi "/home/myth/recordings/2308320472023429837.mpg" "South Park" "Here Comes the Neighborhood"


### To Access Extra Functionality via Flags from the Command Line
Once myth2kodi is installed you can get an overview of additional functionality
by running:
    
    myth2kodi --help

The first argument, beginning with `--`, is a command flag telling myth2kodi
that it will be doing something other than processing a single recording in
the usual way. The first one of these that you should make use of as the final
step of installation is the `--diagnostics` flag. Running:
    
    myth2kodi --diagnostics

causes basic tests for the presence 
