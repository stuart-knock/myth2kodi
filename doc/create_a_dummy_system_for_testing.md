# Create a Dummy System for Testing...
If you want to fully test myth2kodi without risking your active MythTV
system then it's relatively straight-forward to duplicate your setup on
a spare device such as a laptop.

*NOTE:* The specifics, such as directory names, below are based on my
directory structure but should be sufficient as a guide...

## On Your MythTV Box
#### Get a copy of your MythTV database
https://www.mythtv.org/wiki/Database_Backup_and_Restore
    
    mythconverg_backup.pl

####  and a listing of your recording files
    
```bash
cd /media/video/recordings/Movies
ls -l > 'recMovies.txt'

cd /media/video/recordings/TVshows
ls -l > 'recTVshows.txt'
```


## On Your Test Box (eg laptop)
Install MythTV and [myth2kodi](INSTALL.md)

#### Create the directory structure for your MythTV recordings and Kodi Library...

```bash
sudo mkdir /media
sudo chown librarian:users /media
mkdir --parents /media/video/recordings/TVshows
mkdir /media/video/recordings/Movies
mkdir /media/video/movies
mkdir /media/video/tv
```

#### Create some fake recording files
Put the recordings listings created above into the newly created directories
on your test system, then use them to create empty files with the names of 
your recordings (and thus compatible with your MythTV-DB information):
    
```bash
cp recMovies.txt /media/video/recordings/Movies
cp recTVshows.txt /media/video/recordings/TVshows

cd /media/video/recordings/Movies
while read line ; do
  [[ -n "$line" ]] && touch "$line"
  printf '%s\n' "Created: $line"
done <"recMovies.txt"

cd /media/video/recordings/TVshows
while read line ; do
  [[ -n "$line" ]] && touch "$line"
done <"recTVshows.txt"
```

#### Restore the database
https://www.mythtv.org/wiki/Backend_migration  
https://www.mythtv.org/wiki/Database_Backup_and_Restore

*NOTE:* the MySQL Time Zone Tables must be installed on the MySQL server prior to using MythTV

Either run:
    
    mythconverg_restore.pl  --verbose --filename mythconverg-1317-20151210151330.sql.gz

on a fresh machine, or:
    
    mythconverg_restore.pl --verbose --drop_database --create_database --filename mythconverg-1317-20151210151330.sql.gz

on a machine that previously had a mythconverg database. Remove the --verbose
if you don't want to see what's happening (maybe a good idea if you have a MythTV-DB
that has spent years filling up).

#### Change the hostname stored in the restored database to that of the new machine, it has the form:
    
    /usr/share/mythtv/mythconverg_restore.pl --change_hostname --old_hostname="XXXX" --new_hostname="YYYY"

so, something like:
    
    /usr/share/mythtv/mythconverg_restore.pl --change_hostname --old_hostname="mediamaster" --new_hostname="borg"
    /usr/share/mythtv/mythconverg_restore.pl --change_hostname --old_hostname="192.168.1.42" --new_hostname="192.168.1.78"
 
and use mythtv-setup to change the master backend IP address on the General Settings page.

You should now have a functioning dummy system that you can use to test
myth2kodi's effects on your media library.

