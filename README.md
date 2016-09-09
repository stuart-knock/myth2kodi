
Starting from the version of mythicalLibrarian that was roughly version 950, 
I began cleaning it up a little, standardising indentation, wrapping comment
lines to roughly 80, etc. Mostly for my own benefit while I figured out how it 
worked.

Subsequently decided to make significant changes, working around SchedulesDirect 
specific processing, making it work with the existing cached data when internet 
connection not available, adding some specific processing for the particular 
idiosyncrasies of FTA guide data broadcast with the digital television stations
in Sydney, Australia, and renaming mythicalLibrarian to myth2kodi to avoid 
confusion -- although, the original name was nicer...





#User Jobs
#TODO: Drop update entirely, however, consider repurposing mythicalSetup as myth2kodi --setup
# myth2kodi --update (mythicalSetup) will merge user jobs into myth2kodi automagically.
# Put your desired commands into one of the following files.  You may need to create the folder
# /etc/myth2kodi/JobSuccessful
# /etc/myth2kodi/JobInformationNotComplete
# /etc/myth2kodi/JobGenericError
# /etc/myth2kodi/JobFilesystemError
# /etc/myth2kodi/JobInsufficientData
# /etc/myth2kodi/JobIgnoreList
# /etc/myth2kodi/JobUnspecified
# After running mythicalSetup, the user job will be incorporated into the
# myth2kodi script and  Executed when the job is run.

### EXAMPLE JOB (Leading "# " should be removed) ###
# /etc/myth2kodi/JobSuccessful:
# #Transcode your file using the myth2kodi variables
# ffmpeg -i S:"$MoveDir/$ShowFileName.$OriginalExt" -target ntsc-svcds:"$MoveDir/$ShowFileName.mp4"
# #remove the myth2kodi symlink
# rm "$InputPath"
# #make a new symlink
# ln -s  "$MoveDir/$ShowFileName.mp4" "$InputPath"
# #Set the new file extension
# OriginalExt=mp4
# #Create tracking entry for the file
# add_undo ; [[ "$RequiresDoover" = "1" ]] && add_doover
# ####Move the .txt(comskip) and .nfo(Information) files if needed.
# enable the KODI communications
# KODIUpdate=Enabled
# KODIClean=Enabled
# KODINotify=Enabled
# #Tell myth2kodi to do KODI communications
# kodi_newshow
# kodi_cleanup

#Suggested examples are:
# 1.string together multiple versions of myth2kodi configured for
#   different languages. Set a different Language for each, then on failure,
#   call the next job.
# 2.custom name replacement of certain programming
# 3.custom file moving of certain programming
# 4.set custom folders based upon recorded channel
# 5.set custom user jobs based upon who ran the file
# 6.make a "new movies" "old movies" folder.
#The limits are endless.

#The following is a list of variables which can be used as a part of user jobs
#at the end of myth2kodi:
#####ALL RECORDINGS####
#$MoveDir/$ShowFileName.$OriginalExt = location of moved file.
#$ShowName = Processed Title
#$InputTitle = actual database title
#$MoveDir = the folder to which the file was moved ie. "/home/mythtv/videos/Episode"
#$ShowFileName = the name of the show moved, not including extension eg. "simpsons S01E02 (foo)" or "MovieTitle(year)"
#$OriginalExt = original file extension  eg "mpg"
#$NewShowName = Successfully resolved show name
#$ChanID = ChannelID
#$ProgramID= The Program IDentification information found in the MythTV DB
#$ShowStartTime = begin recording time
#$ShowCategory = category like children or sports also specifies Movie in SydFTA data
#$m2kProgramIDCheck = "SH" for SHow or sports - "MV" for MoVie - "EP" for EPisode
#$Plot = Plot
#$Stars = Stars
#$FileBaseName = name of the file to be moved without ext
#$XMLTVGrabber = your guide data type
#$ProgramIDType= Generic episode with no data, Movie, or Series With Episode Data
#$Zap2itSeriesID= Zap2it ID with SH, MV or EP stripped
#$MyUserName = name of user running myth2kodi
#$SafeShowName = title of show after showTranslations formatted for filesystem use

####EPISODES AND GENERIC SHOWS####
#$OriginalAirDate = original air date  Generic programming will be the first episode ever, for episodes it will be the first aired date
#$EpisodeSubtitle = Subtitle or EPisode Name

#####EPISODES####
#$Exx = Episode Number or "Movie" in case of a movie
#$Sxx = Season number or blank in case of movie
#$SeriesID = TheTVDB series ID
#$TvDbTime = current tvdb time
#$LastUpdatedTVDB = last updated time from TheTVDB (for Episodes only others will be blank)
# = tvdb order numbering

####MOVIES####
#$MovieAirDate = the original year the movie aired

############################## END USER JOBS ###################################


