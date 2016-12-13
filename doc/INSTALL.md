# Install
Installation is relatively straight-forward, it just involves copying the
four scripts into an appropriate directory, making sure the ones that need
to be are executable

*NOTE:* If you're setting up a new [MythTV](https://www.mythtv.org/) system
then I recommend you simplify your life by having a single user function
as your media librarian. This user should own your media directories, run
`mythbackend` and be the user to run `myth2kodi`.

### Copy scripts to an appropriate bin directory (Default: `/usr/local/bin`):
See the `bindir` user setting in myth2kodi.conf:  
    sudo cp myth2kodi /usr/local/bin/
    sudo cp bashlogging /usr/local/bin/
    sudo cp MythDataGrabber /usr/local/bin/
    sudo cp m2k_notify /usr/local/bin/
    
### Make those that need to be executable
    chmod o+rx /usr/local/bin/myth2kodi
    chmod o+rx /usr/local/bin/MythDataGrabber
    chmod o+rx /usr/local/bin/m2k_notify

### Create the myth2kodi working directory
**This is an optional extra.** It's possible to configure myth2kodi using
the user settings section near the top of the main `myth2kodi` script. The
first invocation of `myth2kodi` will create the working directory specified
by the `m2kdir` parameter. However, it is probably better/easier if you
choose to use the file `myth2kodi.conf` to modify the default parameters set
in the script.

As the user who will function as your media librarian, run:
    
    mkdir ~/.myth2kodi
    cp myth2kodi.conf ~/.myth2kodi
    cp myth2kodi.png ~/.myth2kodi
    cp myth2kodi_failed.png ~/.myth2kodi

For extra information on configuration, see [CONFIGURE.md](CONFIGURE.md).
