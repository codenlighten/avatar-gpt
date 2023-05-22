#!/bin/bash

FILENAME=$APP_NAME

# Actually do the Unity build
rm -rf build/win
mkdir -p build/win
./GenerateBuildDate.bat
echo Building project...

# So let's delete these things from the shared stuff that we don't need in this kind of build? (remove the : in front to delete)
# rm -f Assets/RT/MySQL/RTSqlManager.cs
# rm -f Assets/RT/RTNetworkServer.cs

UNITY_EXE=unity   # Replace with the actual Unity executable or command

$UNITY_EXE -quit -batchmode -logFile log.txt -buildWindows64Player build/win/$APP_NAME.exe -projectPath $(pwd)
$UNITY_EXE -quit -batchmode -logFile log.txt -executeMethod Win64Builder.BuildRelease -projectPath $(pwd)
echo Finished building.
if [ ! -f build/win/$APP_NAME.exe ]; then
    echo Error with build!
    # start notepad.exe log.txt  # Commented out since Notepad is a Windows-specific program
    # $RT_UTIL/beeper.exe /p  # Commented out since $RT_UTIL is not defined
    read -p "Press any key to continue..." -n1 -s
fi

# Add a few more files we need
cp config_template.txt build/win
cp Misc/readme.txt build/win

$RT_PROJECTS/Signing/sign.bat "build/win/$APP_NAME.exe" "GPTAvatar"  # Replace $RT_PROJECTS with the actual path

# Create the archive
ZIP_FNAME=GPTAvatar_Windows.zip
rm -f $ZIP_FNAME
cd build
$RT_UTIL/7za.exe a -r -tzip ../$ZIP_FNAME win
cd ..
# Rename the root folder
$RT_UTIL/7z.exe rn $ZIP_FNAME win/ GPTAvatar/

if [ "$NO_PAUSE" = "" ]; then
    read -p "Press any key to continue..." -n1 -s
fi
