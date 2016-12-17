#Configure
There are two places you can configure the user settings for myth2kodi,
in the `myth2kodi` script directly or using the `myth2kodi.conf` file in
the working directory. The latter (`myth2kodi.conf`) is preferred.

## Essentials
**NOTE:** Even if you're doing configuration via the `myth2kodi.conf` file
you **must** make sure that the `m2kdir` parameter is configured correctly
directly in the script, as this is used to find the `myth2kodi.conf` file.
The default value of a `.myth2kodi` directory in the callers home directory
should work fine as long as you don't intend to make significant 
modifications of other defaults.

It is essential that the following parameters are set correctly, as they
are specific to your setup:  
`Librarian` -- Name of the user running mythbackend and myth2kodi.  
Some vocabulary: *episodes* are recordings recognised as episodes of a TV series; 
*movies*  are recordings recognised as being a movie; and *shows* are
recordings that aren't recognised -- which when everything else is working correctly
means one-off things like news or sports events.  
`MoveDir` -- *Default directory to move recorded TV episodes to.*  
`PrimaryMovieDir` -- *Default directory to move recorded movies to.*   
`PrimaryShowDir` -- *Default directory to move recorded shows to.*  
`DBHostName` -- *The IP address or name of the server for MythTV Database.*  
`MySQLuser` -- *MySQL user name*  
`MySQLpass` -- *MySQL password*  
`DBPin` -- *The database pin for the MythTV database.*  
`MySQLMythDb` -- *MythTV database name.*  

You'll also ideally want to make sure you have correctly set:  
`GuideDataType` -- *Specifies the method for processing the guide data found in
your MythTV-DB.*  
Even if it wasn't originally written for the purpose, one of the existing
`GuideDataType` options will hopefully work for your guide data-source. If not
then you may need to make your own processing function by modifying one of the
existing ones. (*WARNING: that's how I fell down the rabbit hole...*)

If you `Enable` Kodi notification (it is by default), then it is essential to set:  
`KODIIPs` -- IP-Address and port for KODI Notifications, you will also need to add
             username and password if you have enabled these in Kodi.

## Optional Extras
There are a number other parameters that can be used to Enable, Disable
or modify the function of various features. The ones you're most likely
to need or want to change are related to Logging, Notifications, and 
Commercial-markup.

#### Logging
The main logging functionality is controlled by four parameters:  
`LOGLEVEL` -- Controls the amount of information myth2kodi reports.  
`LOGTYPE` -- Defines where to direct logging messages.  
`LogFileName` -- Used to generate the name of the log file.  
`LOG_LIFE` --  How long to persist archived log files in months.
Additionally:  
`DailyReport` -- Whether to produce a brief log of shows added to your library per day.  
`DAILYREPORT_LIFE` -- How long to persist daily report files in months.  

#### Notifications:
######Kodi:  
`KODINotify` -- Whether to send notifications to the KODI UI.  
`KODIUpdate` -- Whether to ask KODI to Update library upon Successful move job.  
`KODIClean` -- Whether to ask KODI to cleanup its library.  
You can also create the directory `/var/www/myth2kodi-rss` and point Kodi
at it to have recently added recordings show up in the RSS feed scrolling across
the bottom of Kodi.

######Desktop:  
`Notify` -- Whether to send a notification to the Desktop.  
`NotifyUserName` -- User name to send the notifications to.

#### Commercial-Markup
`CommercialMarkup` -- Whether to generate comskip files for recordings when they are moved.  
`CommercialMarkupCleanup` --Whether to remove comskip & NFO files if the associated .mpg file can't be found.

## Other stuff...
There are still a number of the "User Settings" parameters that haven't been
mentioned here. Generally this means you probably shouldn't want to touch these.
Of course, you're free to experiment to your hearts content. Though I'd strongly
suggest using a [dummy media library](create_a_dummy_system_for_testing.md) for
any experimentation...
