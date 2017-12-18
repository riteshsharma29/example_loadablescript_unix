#!/bin/bash 
##############################################################################################

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

		stappbseLoopChksum=54679
		loadinistr=SeatBaseTK
                dbstr=stappbse

		#Changing path where the main loadable script is kept
		cd $SOURCEPATH_LOADSCRIPT
		AirlineID=`grep -w "AirlineID" "$SOURCEPATH_LIB/app_config.ini"|cut -d "=" -f 2`
		stappbseloopfilename=$AirlineID"stappbseloop.tar"
	}


#Calling above function to read necessary variables

get_main

#Calling Function from below script to delete unwanted files & folders from output folder before starting lodable creation process.
. $SOURCEPATH_LIB/cleanup.sh

clean_base

#Checking if releasebase.txt file is present
#The releasebase.txt file is expected inside above path

	if [ ! -f $SOURCEPATH"app_dir/releasebase.txt" ]
	 then                       	
				echo ""
				echo "ERROR ------ releasebase.txt inside app_dir/ Missing-------- "
				echo ""
				echo "ERROR --- Please update releasebase.txt inside seatapps/app_dir/ "
				exit
	fi

###########################################################################################################################

#Copying releasebase.txt from source app_dir to seatappbase.sh script path for loadable creation

	cp $SOURCEPATH"app_dir/releasebase.txt" $SOURCEPATH_OUTPUT/
	chmod -R 777 $SOURCEPATH_OUTPUT/releasebase.txt

	# releaseApp.txt will be coverted to info.ini
	mv $SOURCEPATH_OUTPUT/releasebase.txt $SOURCEPATH_OUTPUT/info.ini

	dos2unix $SOURCEPATH_OUTPUT/info.ini
	chmod -R 777 $SOURCEPATH_OUTPUT/info.ini

	# Below File will be edited for fetching Part Number,Version Number.
	sed -i 's/Version Number=/VR=/g' $SOURCEPATH_OUTPUT/"info.ini"
	sed -i 's/Part Number=/PN=/g' $SOURCEPATH_OUTPUT/"info.ini"

#####################################################################################################################################

# Calling shell script & functions in it which are applicable for app to perform necessary checks before starting loadable creation process
. $SOURCEPATH_LIB/checks.sh

basecheck1  #Calling function to check if all 2 required parameters are proper or not
basecheck2  #Calling function to check if Part Number month is as per requirement or not
basecheck3  #Calling function to check if Version Number month is as per requirement or not
basecheck4  #Calling function to check if source app_dir folder structure is as per requirement or not

######################################################################################################################################

get_partnumber()
	{

		        
			#Extracting Current PARTNUMBER from the $SOURCEPATH_OUTPUT/info.ini

			PARTNUM=`grep -w "PN"  $SOURCEPATH_OUTPUT/"info.ini"|cut -d "=" -f 2`

			echo $PARTNUM

	}

get_version()
	{

			#Extracting Current VERSION from the $SOURCEPATH_OUTPUT/info.ini

			VERSION=`grep -w "VR"  $SOURCEPATH_OUTPUT/"info.ini"|cut -d "=" -f 2`

			echo $VERSION

	}

Createloadbledir()

	{

#Creating essential loadable folders

		        echo "##" >> $LOGFILENAME
		        echo "+ Executing Createloadbledir function " >> $LOGFILENAME

			APPPATH="$SOURCEPATH_OUTPUT/CORBUILD/disks/stappbse/stappbse/seatapps/app_dir/"
			DBPATH="$SOURCEPATH_OUTPUT/CORBUILD/disks/stappbse/stappbse/"			

			mkdir -p $DBPATH
			mkdir -p $APPPATH			

                        chmod -R 777 $SOURCEPATH_OUTPUT/CORBUILD

	}

Copybasefiles()

	{
		        echo "##" >> $LOGFILENAME
		        echo "+ Executing Copybasefiles function " >> $LOGFILENAME

#Copying Interactive folders

			cp -Rvf $SOURCEPATH"app_dir"/core $APPPATH

#Copying Interactive files

			cp -Rvf $SOURCEPATH"app_dir"/rev.xls $APPPATH
                        cp $SOURCEPATH_SCRIPT/pc-startup.sh "$SOURCEPATH_OUTPUT/CORBUILD/disks/stappbse/stappbse/seatapps/"
                       

#dos2unix conversion

			dos2unix $APPPATH"core"/*.txt
			dos2unix "$SOURCEPATH_OUTPUT/CORBUILD/disks/stappbse/stappbse/seatapps/"pc-startup.sh



#Creating cram of seatappbase files
 
			cd $APPPATH
			cd ..
			mkfs.cramfs -v app_dir base.cram
			chmod -R 777 base.cram
			rm -rf app_dir
                        cd $SOURCEPATH_OUTPUT

               

#Changing permissions of SOURCEPATH_OUTPUT

			chmod -R 777 $SOURCEPATH_OUTPUT

	}



createstappbsedb()

	{


		        echo "##" >> $LOGFILENAME
		        echo "+ Executing createstappbsedb function " >> $LOGFILENAME

			cd $DBPATH
			mkdir db
			cd db 
			echo "#Name(12)    LRUID   Hardwareid(12) ConfigID   Partnumber       Filename" >> stappbse.db
			echo "$dbstr     $VERSION     N/A           N/A     $PARTNUM     /loopfs/seatapps/app_dir/core/startk.txt" >> stappbse.db
			cd ..			
                        tar -xvf $SOURCEPATH_SCRIPT/gulftkstapbseloop.tar
                        chmod -R 777 $DBPATH
               
	}

createstappbsetgz()

	{


		        echo "##" >> $LOGFILENAME
		        echo "+ Executing createstappbsetgz function " >> $LOGFILENAME

			tar -cvzf stappbse.tgz *
			mv stappbse.tgz ../
			cd ..
			chmod -R 777 $DBPATH                        
			rm -rf stappbse

	}


CreateAirlineDBBase()
	{

		        echo "##" >> $LOGFILENAME
		        echo "+ Executing CreateAirlineDBBase function " >> $LOGFILENAME

			#Extracting the value of stappbse.tgz using chksum binary
		       
			CHECKSUMVAL=`chksum stappbse.tgz`
			result="${CHECKSUMVAL/*(}"
			CHECKSUM=`echo ${result//[)]}`

			echo "# KEY SOURCE CHCKSM VERSION DEST REBOOT PN ConfigID LoopChksum" >> stappbse.db
			echo "plugin /data/lru_core.2ke/qmu/plugin/stappbse.tgz $CHECKSUM $VERSION /loopfs/stappbse.tgz TRUE $PARTNUM NA $stappbseLoopChksum" >> stappbse.db
			chmod -R 777 *
			/usr/bin/zip -r stappbse.zip stappbse.db stappbse.tgz
			chmod -R 777 *
			rm -rf stappbse.db
			rm -rf stappbse.tgz
                        cp $SOURCEPATH_SCRIPT/stappbse.csh .
                        dos2unix stappbse.csh

	}

CreateLoadiniOneBase()
	{


		        echo "##" >> $LOGFILENAME
		        echo "+ Executing CreateLoadiniOneBase function " >> $LOGFILENAME

			rm -f load.ini
			echo [Load] > load.ini
			echo Type=4 >> load.ini
			echo Sub_Type=1 >> load.ini
			echo Total_Disks=1 >> load.ini
			echo Disk_Number=1 >> load.ini
			echo Script_File = stappbse.csh >> load.ini	
			echo Load_String=$loadinistr $PARTNUM $VERSION >> load.ini
			echo Name=$loadinistr $PARTNUM $VERSION >> load.ini
			chmod -R 777 load.ini
                        cd ../..

	}

CreateLoadiniTwoBase()
	{


		        echo "##" >> $LOGFILENAME
		        echo "+ Executing CreateLoadiniTwoBase function " >> $LOGFILENAME


			rm -f load.ini
			echo [Load] > load.ini
			echo Type=99 >> load.ini
			echo Version=$VERSION >> load.ini
			echo Build=0001 >> load.ini
			echo Name=$loadinistr $PARTNUM $VERSION >> load.ini
			echo Load_String=$loadinistr $PARTNUM $VERSION >> load.ini
			chmod -R 777 load.ini
                       

	}


renamefolder()
	{


		      echo "##" >> $LOGFILENAME
		      echo "+ Executing renamefolder function " >> $LOGFILENAME


		      cd $SOURCEPATH_OUTPUT/CORBUILD
		      rename 'y/a-z/A-Z/' *                  
		      cd DISKS
		      rename 'y/a-z/A-Z/' *
		      cd STAPPBSE
		      rename 'y/a-z/A-Z/' *

		      cd ../../../

		      chmod -R 777 CORBUILD 

		      mv CORBUILD SEATBASE"_"$VERSION

		      cd SEATBASE"_"$VERSION

		      zip -r SEATBASE"_"$VERSION.zip *

		      mv SEATBASE"_"$VERSION.zip ../

		      cd ..

		      chmod -R 777 SEATBASE"_"$VERSION.zip

		      rm -Rf SEATBASE"_"$VERSION
	

	}

endofcode()


	{

                   echo "##" >> $LOGFILENAME

                   echo "Seatappbase loadable is created inside $SOURCEPATH_OUTPUT/" >> $LOGFILENAME

                   endtime=`date "+%d %m %y %H %M %S"`

                   echo "+ END TIME IS: "$starttime >> $LOGFILENAME

                   rm -Rf $SOURCEPATH_OUTPUT/info.ini

                   chmod -R 777 $LOGFILENAME

	
	}


############################################################### Calling functions for loadable creation ############################################################### 

#Calling function to fetch Part Number information
get_partnumber

#Calling function to fetch version Number information
get_version

#Calling function to create loadable structure directories
Createloadbledir

#Calling function to copy seatappbase files & folders and create cram of it
Copybasefiles

#Calling function to create stappbsedb.db
createstappbsedb

#Calling function to create stappbsetgz
createstappbsetgz

#Calling function to create Airline stappbsedb.db
CreateAirlineDBBase

#Calling functions to create respective LOAD.INI files

CreateLoadiniOneBase
CreateLoadiniTwoBase

#Calling function to package loadable with required folder structure
renamefolder

#Coping the creted build to Archive folder
cp $SOURCEPATH_OUTPUT/SEATBASE"_"$VERSION.zip $ARCHIVEPATH
cd $ARCHIVEPATH
chmod -R 777 SEATBASE"_"$VERSION.zip

#Calling function to indicate end of the loadable creation
endofcode


