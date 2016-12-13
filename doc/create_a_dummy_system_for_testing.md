# Create a Dummy System for Testing...
If you want to fully test myth2kodi without risking your active MythTV
system then it's relatively straight-forward to duplicate your setup on
a spare device such as a laptop.

*NOTE:* The specifics below are based on my specific directory structure
but should be 

## On Your MythTV Box
#### Get a copy of your MythTV database
https://www.mythtv.org/wiki/Database_Backup_and_Restore
    
    mythconverg_backup.pl

####  and directory structure
    
    cd /media/video/recordings/Movies
    ls -l > 'recMovies.txt'

    cd /media/video/recordings/TVshows
    ls -l > 'recTVshows.txt'


## On Your Test Box (eg laptop)
Install MythTV and [myth2kodi](INSTALL.md)

#### Create the directory structure for your MythTV recordings and Kodi Library...
    
    sudo mkdir /media
    sudo chown librarian:users /media
    mkdir --parents /media/video/recordings/TVshows
    mkdir /media/video/recordings/Movies
    mkdir /media/video/movies
    mkdir /media/video/tv

#### Use ls dumps to touch fake files
Put the recordings listings created above into the newly created directories
on your test system.
    
    cd /media/video/recordings/Movies
    while read line ; do
      [[ -n "$line" ]] && touch "$line"
      printf '%s\n' "Created: $line"
    done <"recMovies.txt"
    
    cd /media/video/recordings/TVshows
    while read line ; do
      [[ -n "$line" ]] && touch "$line"
    done <"recTVshows.txt"

#### Restore the database with either:
https://www.mythtv.org/wiki/Backend_migration

*NOTE:* the MySQL Time Zone Tables must be installed on the MySQL server prior to using MythTV

Either run:
    
    mythconverg_restore.pl  --verbose --filename mythconverg-1317-20151210151330.sql.gz

on a fresh machine, or:
    
    mythconverg_restore.pl --verbose --drop_database --create_database --filename mythconverg-1317-20151210151330.sql.gz

on a machine that previously had a mythconverg database, stick a --verbose
on the end if you want to see what's happening.

#### Change the hostname stored in the restored database to that of the new machine, it has the form:
    
    /usr/share/mythtv/mythconverg_restore.pl --change_hostname --old_hostname="XXXX" --new_hostname="YYYY"

so, something like:
    
    /usr/share/mythtv/mythconverg_restore.pl --change_hostname --old_hostname="mediamaster" --new_hostname="borg"
    /usr/share/mythtv/mythconverg_restore.pl --change_hostname --old_hostname="192.168.1.42" --new_hostname="192.168.1.78"
 
and use mythtv-setup to change the master backend IP address on the General Settings page.

You should now have a functioning dummy system that you can use to test
myth2kodi's effects on your media library.

