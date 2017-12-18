#!/bin/bash

#Intialization of necessary variables in the below function
starttime=`date "+%d %m %y %H %M %S"`


	cd ..
	
	get_main()
	{


		#Storing source app_dir path in variable
		ARCHIVEPATH=`pwd`/archive
		SOURCEPATH=`pwd`/seatapps/
		SOURCEPATH_OUTPUT=`pwd`/output
		SOURCEPATH=`pwd`/seatapps/
		SOURCEPATH_LOADSCRIPT=`pwd`/loadable_script
		SOURCEPATH_SCRIPT=`pwd`/loadable_script/scripts
		SOURCEPATH_LIB=`pwd`/loadable_script/lib
		LOGFILENAME=$SOURCEPATH_OUTPUT/"LOG.TXT"

		#F1 Beginning String declaration for seatapp.db type files
                dbfilestring=Seatapp

		#Changing path where the main loadable script is kept
		cd $SOURCEPATH_LOADSCRIPT

		#Loadable folder structures stored in the vraiables
		SCR_PATH=`pwd`
		CONFIGFILEPATH="$SOURCEPATH/"
		SEATAPPDB_PATH="$SOURCEPATH_OUTPUT/APPBUILD/disks/seatapp/cfgapp/config/speclrus"
		APPCSHPATH="$SOURCEPATH_OUTPUT/APPBUILD/disks/seatapp/cfgapp/seatapps"
		PRELOAD_INI_PATH="$SOURCEPATH_OUTPUT/APPBUILD/disks/seatapp/cfgapp/seatapps/"
		PAXUSFILESPATH="$SOURCEPATH_OUTPUT/APPBUILD/disks/seatapp/cfgapp/seatapps/paxus"
		AVODPATH=$SOURCEPATH"app_dir/month"/avod.cfg
	
		#Extracting essential Variables from app_config.ini
		AirlineID=`grep -w "AirlineID" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		INIFILENAME=`grep -w  "INIFILENAME" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		CFGAPPDBDISP=`grep -w  "CFGAPPDBDISP" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		PAXUSFILESEPERATOR=`grep -w  "PAXUSFILESEPERATOR" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		MEDIACYCLE=`grep -w  "MEDIACYCLE" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		CFGAPPFILE=`grep -w  "CFGAPPFILE" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`


		#Variables required for Paxus and Preload.ini file.
		PAXUS=`grep -w  "PAXUS" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		PRELOAD=`grep -w  "PRELOAD" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		CONFIGPATH=`grep -w  "CONFIGPATH" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		MONTH_CODE=`grep -w  "MONTH_CODE" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		CRAMFORMAT=`grep -w  "CRAMFORMAT" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`

		#Variables For custom files - Flightleg & Seatmessage file.
		FlightLegPath=`grep -w  "FlightLegPath" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		FlightLegFileName=`grep -w  "FlightLegFileName" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		SeatMessageFilePath=`grep -w  "SeatMessageFilePath" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		SeatMessageFileName=`grep -w  "SeatMessageFileName" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		DBPATH_IN_TGZ=`grep -w "DBPATH_IN_TGZ" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		INIFILE_IN_DB_CFGAPP=`grep -w "INIFILE_IN_DB_CFGAPP" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		SEATINTDB_PATH=`grep -w "SEATINTDB_PATH" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		BASEDLDCRAM=`grep -w "BASEDLDCRAM" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		LOADABLEPACKAGE_TAG=`grep -w "LOADABLEPACKAGE_TAG" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
	}

#Calling above function to read necessary variables

get_main

#Calling Function from below script to delete unwanted files & folders from output folder before starting lodable creation process.
. $SOURCEPATH_LIB/cleanup.sh

clean_apps

#Checking if releaseapp.txt file is present
#The releaseapp.txt file is expected inside above path

	if [ ! -f $SOURCEPATH"app_dir/releaseapp.txt" ]
	 then                       	
				echo ""
				echo "ERROR------ releaseapp.txt inside app_dir/ Missing-------- "
				echo ""
				echo "ERROR --- Please update releaseapp.txt inside seatapps/app_dir/ "
				exit
	fi

###########################################################################################################################

#Copying releaseapp.txt from source app_dir to seatapp.sh script path for loadable creation

	cp $SOURCEPATH"app_dir/releaseapp.txt" $SOURCEPATH_OUTPUT/
	chmod -R 777 $SOURCEPATH_OUTPUT/releaseapp.txt

	# releaseApp.txt will be coverted to info.ini
	mv $SOURCEPATH_OUTPUT/releaseapp.txt $SOURCEPATH_OUTPUT/info.ini

	dos2unix $SOURCEPATH_OUTPUT/info.ini
	chmod -R 777 $SOURCEPATH_OUTPUT/info.ini

	# Below File will be edited for fetching 3 letter ID, Current month,Current year,Part Number,Version Number.
	sed -i 's/Program ID=/PID=/g' $SOURCEPATH_OUTPUT/"info.ini"	
	sed -i 's/Version Number=/VR=/g' $SOURCEPATH_OUTPUT/"info.ini"
	sed -i 's/Part Number=/PN=/g' $SOURCEPATH_OUTPUT/"info.ini"
	sed -i 's/Month=/MTH=/g' $SOURCEPATH_OUTPUT/"info.ini"
	sed -i 's/Year=/YR=/g' $SOURCEPATH_OUTPUT/"info.ini"

# Calling shell script & functions in it which are applicable for app to perform necessary checks before starting loadable creation process
. $SOURCEPATH_LIB/checks.sh

appcheck1  #Calling function to check if all 4 required parameters are proper or not
appcheck2  #Calling function to check if app month is as per requirement or not
appcheck3  #Calling function to check if year month is as per requirement or not
appcheck4  #Calling function to check if Part Number month is as per requirement or not
appcheck5  #Calling function to check if Version Number month is as per requirement or not
appcheck6  #Calling function to check if source app_dir folder structure is as per requirement or not


# Calling shell scripts to call functions for loadable creation process
. $SOURCEPATH_LIB/app_lib.sh 
. $SOURCEPATH_LIB/paxus.sh
. $SOURCEPATH_LIB/preload.sh
. $SOURCEPATH_LIB/app_tgzcreator.sh
. $SOURCEPATH_LIB/renameapp.sh
echo "+ Including all the Library files">> $LOGFILENAME
######################################################################################################################################

#Calling function to clear the terminal
clear

# Calling function [from lib/app_lib.sh] to read month parameter into a variable       
get_month

# Calling function [from lib/app_lib.sh] to read year parameter into a variable                                                                                  
get_year

# Calling function  [from lib/app_lib.sh] to read partnumber parameter into a variable
get_partnumber

# Calling function  [from lib/app_lib.sh] to read version parameter into a variable
get_version

# Calling function  [from lib/app_lib.sh] to convert numrical month parameter to a word string                                     
init_monthnames "$MONTH"                      

# Calling function [from lib/app_tgzcreator.sh] to run month_files.sh script for copy seatapps files & folders
CopyAppfiles                                     

#Calling function [from lib/app_lib.sh] is being called to create seatapp.db inside disks/seatapp/cfgapp/config/speclrus

CreateCfgAppDb

#Calling function [from lib/app_paxus.sh] to create paxus files
CreatePaxusfiles

#Calling function from [lib/app_preload.sh] to create Preloadini based on paxus with preload type
CreatePreloadini

#Calling function from [lib/app_lib.sh] to Create Loading Script Files (Preload.csh, ap-month.csh & seatapp.csh)

CreateLoadScripts

#Calling function from [lib/app_lib.sh] to Create cfgapp folder

CreateCfgappzip

#Calling functions from [lib/app_tgzcreator.sh] to Create respectve db files for the program

CreateDB_SeatApps_InTgz
CreateSeatintDb

#Calling function from [lib/app_tgzcreator.sh] to Create app.cram
CreateCram

#Calling functions from [lib/app_tgzcreator.sh] to Create respectve db files for the program

CreateSeatAppTgz
#Calling function from [lib/app_tgzcreator.sh] to Create db for tgz file
CreateDbForTgz

#Calling function from [lib/app_tgzcreator.sh] to Create seatapp.zip file

CreateSeatAppZip

#Calling functions from [lib/app_tgzcreator.sh] to Create LOAD.INI files

CreateAppLoadiniTwo
CreateAppLoadiniOne

#Calling function from [lib/app_tgzcreator.sh] to change permissions of the folder structure created and dos2unix conversion of .csh files
CreateAppDisk

#Calling function from [lib/renameapp.sh] to force files & folders to upercase 
renameapp

#Calling function from [lib/renameapp.sh] to create loadable package with required naming convention
createloadablepackage

#Calling function from [lib/app_tgzcreator.sh] which indicates end of the loadable creation process
End_Script

#Coping the creted build to Archive folder
cp $SOURCEPATH_OUTPUT/$LOADABLEPACKAGE_TAG"_"$VERSION.zip $ARCHIVEPATH
cd $ARCHIVEPATH
chmod -R 777 $LOADABLEPACKAGE_TAG"_"$VERSION.zip

exit

