#!/bin/bash
echo "PinkelStar iOS package build: DO NOT RUN THIS SCRIPT BEFORE YOU HAVE RUN THE FOLLOWING SCRIPTS:"
echo "THE PINKELSTAR-SERVER-FRAMEWORK SCRIPT"
echo "THE PINKELSTAR-PRODUCTION-DEMO-APP SCRIPT"
echo "If you haven't done that, start over. I will fix this and automate all steps later..............."
echo "PinkelStar iOS package build: Copying assets into current version..."

# this helps prevent making dumb copying mistakes
# change at will
# FIX ME PLEASE: don't know how to avoid absolute paths (I suck at scripts ;-) )
SOURCE_PATH="../pinkelstar-iphone"
FRAMEWORK_PATH="../pinkelstar-production-demo-app/"
PACKAGE_PATH="."
# there are a few files that shuld never be altered unless there is a need for it
# we put them in this directory and copy them from there again
SAVED_FILES_PATH="../saved_files_dir"

# Clean any existing source code that might be there  
# already  
echo "PinkelStar iOS package build: Cleaning package PinkelStar Include dir..." [ -d "$PACKAGE_PATH" ] && rm -rf "$PACKAGE_PATH"/PinkelStar/Include
echo "PinkelStar iOS package build: Cleaning package Resources dir..." [ -d "$PACKAGE_PATH" ] && rm -rf "$PACKAGE_PATH"/PinkelStar/Resources
echo "PinkelStar iOS package build: Cleaning package Resources-iPad dir..." [ -d "$PACKAGE_PATH" ] && rm -rf "$PACKAGE_PATH"/PinkelStar/Resources-iPad
echo "PinkelStar iOS package build: Cleaning package PinkelStarUI dir..." [ -d "$PACKAGE_PATH" ] && rm -rf "$PACKAGE_PATH"/PinkelStar/PinkelStarUI
echo "PinkelStar iOS package build: Cleaning package PinkelStar.framework dir..." [ -d "$PACKAGE_PATH" ] && rm -rf "$PACKAGE_PATH"/PinkelStar.framework


# Build the canonical package directory  
# structure  
echo "PinkelStar iOS package build: Setting up directories..."

# The resources directory for iPhone
mkdir -pv $PACKAGE_PATH/PinkelStar
mkdir -pv $PACKAGE_PATH/PinkelStar/Resources
mkdir -pv $PACKAGE_PATH/PinkelStar/Resources/PSImages
mkdir -pv $PACKAGE_PATH/PinkelStar/Resources/PSImages/sharebuttons
mkdir -pv $PACKAGE_PATH/PinkelStar/Resources/PSImages/maindesign

# The resources directory for iPad
mkdir -pv $PACKAGE_PATH/PinkelStar/Resources-iPad

#source files
mkdir -pv $PACKAGE_PATH/PinkelStar/Include
mkdir -pv $PACKAGE_PATH/PinkelStar/Include/PinkelStar
mkdir -pv $PACKAGE_PATH/PinkelStar/PinkelStarUI

# now copy everything to the right place
# private source and header files
# Remember, this is the PinkelStar iOS package, we only need to copy public sources
# everything else is part of the PinkelStar.framework

# copy the changelog file as well. Handy for the developer
cp $SOURCE_PATH/CHANGELOG.mdown $PACKAGE_PATH/CHANGELOG.mdown
# cp $PACKAGE_PATH/README.mdown $PACKAGE_DEMO_PATH/README.mdown # no need to cpy this, the master file is in this directory anyways

echo "PinkelStar production package build: Copying public header files..."

# public header files
cp -R $SOURCE_PATH/Classes/PSPinkelStarServer*.h $PACKAGE_PATH/PinkelStar/Include/PinkelStar/
cp -R $SOURCE_PATH/Classes/PSMainViewController*.h $PACKAGE_PATH/PinkelStar/Include/PinkelStar/
cp -R $SOURCE_PATH/Classes/PSSettingsViewController*.h $PACKAGE_PATH/PinkelStar/Include/PinkelStar/
cp -R $SOURCE_PATH/Classes/PSPermissionViewDelegate.h $PACKAGE_PATH/PinkelStar/Include/PinkelStar/
cp -R $SOURCE_PATH/Classes/PSServerRequestDelegate.h $PACKAGE_PATH/PinkelStar/Include/PinkelStar/
cp -R $SOURCE_PATH/Classes/PSShareButton*.h $PACKAGE_PATH/PinkelStar/Include/PinkelStar/
cp -R $SOURCE_PATH/Classes/PSSocialNetworks.h $PACKAGE_PATH/PinkelStar/Include/PinkelStar/
cp -R $SOURCE_PATH/Classes/PSPermissionView.h $PACKAGE_PATH/PinkelStar/Include/PinkelStar/
cp -R $SOURCE_PATH/Classes/PSPinkelStar.h $PACKAGE_PATH/PinkelStar/Include/PinkelStar/
cp -R $SOURCE_PATH/Classes/PSCommon.h $PACKAGE_PATH/PinkelStar/Include/PinkelStar/

# copy the public PinkelStar UI source files
cp -R $SOURCE_PATH/Classes/PSMainViewController.m $PACKAGE_PATH/PinkelStar/PinkelStarUI
cp -R $SOURCE_PATH/Classes/PSSettingsViewController.m $PACKAGE_PATH/PinkelStar/PinkelStarUI
cp -R $SOURCE_PATH/Classes/PSShareButton.m $PACKAGE_PATH/PinkelStar/PinkelStarUI

echo "PinkelStar production package build: Copying resources for iPhone and iPhone 4..."

cp -R $SOURCE_PATH/PSimages/sharebuttons/* $PACKAGE_PATH/PinkelStar/Resources/PSimages/sharebuttons
cp -R $SOURCE_PATH/PSimages/maindesign/* $PACKAGE_PATH/PinkelStar/Resources/PSimages/maindesign
cp -R $SOURCE_PATH/en.lproj/Localizable.strings $PACKAGE_PATH/PinkelStar/Resources/
#Note that we need to copy a local copy of the pinkelstar.plist file into
# the resources directory. This ensures that we are using invalid application keys and secrets
cp $SAVED_FILES_PATH/pinkelstar.plist $PACKAGE_PATH/PinkelStar/Resources/

#nib files
cp -R $SOURCE_PATH/Classes/PSMainViewController_iPhone.xib $PACKAGE_PATH/PinkelStar/Resources/

echo "PinkelStar production package build: Copying resources... for iPad"

# all iPad resources
cp -R $SOURCE_PATH/Resources-iPad/* $PACKAGE_PATH/PinkelStar/Resources-iPad/
# We have an issue here. The MainWindow-ipad.xib file should not be copied, as it is different
# in the demo app.
# We overwrite the copied one now with a correct version
cp $SAVED_FILES_PATH/MainWindow-iPad.xib $PACKAGE_PATH/PinkelStar/Resources-iPad/

# Copy the framework now
cp -R $FRAMEWORK_PATH/PinkelStar.framework $PACKAGE_PATH
# the framework misses the public header files so we add them to be sure
cp -R $PACKAGE_PATH/PinkelStar/Include/PinkelStar/*.h $PACKAGE_PATH/PinkelStar.framework/Headers/
