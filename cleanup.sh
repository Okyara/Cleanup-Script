#!/bin/bash
# Oksana's cleaning script 
#The cron would be:
# 0 0 1,10,20 * * root cleanup.sh
         vals='/home/v-okyare'
         OBSOLETE_DIR='/home/Obsolete'
         OLD_FILELIST='old_filelist'
	 CURRENT_FILELIST='cur_filelist'
	 OBSOLETE_FILELIST='obs_filelist'
	 TMP_FILE='old_filelist.tmp'	
  
         create_content()
         {
                 for i in $vals;
		 do
                         #List files and calculate their checksum (md5sum).
                         find $i -type f | xargs md5sum
                 done | sort -o $1
         }

         #Test if the old_filelist exists on the system.
         if [ -e $OLD_FILELIST ]
         then
		LIFETIME=`find $OLD_FILELIST -mtime +9`
		
		if [ -z "$LIFETIME" ]
		then
          		#File is not old enough
			exit 0	
		else 	
       			create_content $CURRENT_FILELIST

                        #Find common files with the same checksum (md5sum).
                        #Use sed utility to remove the md5sum and the leading slash.
        	        comm -12 $OLD_FILELIST $CURRENT_FILELIST | sed -e 's/^[^ ]* //' -e 's, /,,' > $OBSOLETE_FILELIST

                        cat  $OBSOLETE_FILELIST | cpio -pd $OBSOLETE_DIR || exit 1
                        cat  $OBSOLETE_FILELIST | xargs rm -f || exit 1

			#Suppress lines that aapear in both files and output the result to the old_filelist.
	                comm -3 $OLD_FILELIST $CURRENT_FILELIST > $TMP_FILE
                        mv $TMP_FILE $OLD_FILELIST

                        #Clean up.
                        rm $OBSOLETE_FILELIST $CURRENT_FILELIST
               fi
         else
                create_content $OLD_FILELIST
                exit 0
         fi
