# User-jobs.

User jobs can be run automagically at the completion of `myth2kodi` by adding
them to a file of the form `$m2kdir/userjobs/$jobtype`. For example, you can
add a script that runs after successful processing of a recording by myth2kodi
by placing it in a file named (assuming default working directory):
```
    "$HOME/.myth2kodi/userjobs/SuccessfulProcessing"
```
or, if your script is only relevant in MOVE-mode, then use:
```
    "$HOME/.myth2kodi/userjobs/MoveModeSuccessful"
```
On completion `myth2kodi` always has a specific `EXIT_JOB_TYPE` set. As the 
final operation before return the directory `$m2kdir/userjobs/` is checked for
a file with the name `"$EXIT_JOB_TYPE"`, if none is present then the directory
is checked for `EXIT_JOB_TYPE`'s parent in the "Exit-job hierarchy", and so on
up the hierarchy. Only one user-job will be run. This means that the most
specific user-job that has been defined will be run.

#### Exit-job hierarchy.
The following list represents the hierarchy of exit `jobtype`s for the `myth2kodi` script:

+ `Success`: <description>
    + `SuccessfulCommandLineSwitch`: <description>
    + `SuccessfulIgnore`: <description>
        + `titleIgnore`: <description>
        + `categoricIgnore`: <description>
        + `DuplicateAvoided`: <description>
            + `RecordingAlreadyProcessed`: <description>
            + `FileAlreadyExists`: <description>
    + `SuccessfulProcessing`: <description>
        + `LinkModeSuccessful`: <description>
        + `MoveModeSuccessful`: <description>
        + `CopyModeSuccessful`: <description>
        + `FailSafeModeComplete`: <description>
+ `Failed`: <description>
    + `FailedCommandLineSwitch`: <description>
    + `GenericUnspecifiedError`: <description>
    + `FailedProcessing`: <description>
        + `BadCall`: <description>
            + `InvalidCall`: <description>
            + `InputPathNotFile`: <description>
            + `FileIsNotRecording`: <description>
            + `UserSettingError`: <description>
        + `InsufficientInformation`: <description>
            + `InsufficientInformationProvided`: <description>
            + `TheTVDBIsIncomplete`: <description>
            + `NameCouldNotBeAssigned`: <description>
        + `SystemFailure`: <description>
            + `MythTVdatabaseFailure`: <description>
            + `PermissionError`: <description>
            + `ZeroLengthFile`: <description>
            + `FileOrPathDoesNotExist`: <description>
            + `MoveFailed`: <description>
            + `CopyFailed`: <description>
            + `RemoveFailed`: <description>
            + `LinkingFailed`: <description>
            + `NoTargetPathAvailable`: <description>
            + `NotFileOrDirectory`: <description>
