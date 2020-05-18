#!/bin/bash

## This script adjusts and copies the template_batchfile.txt file for every subject

# Get ProjectPath & SubjectList
# TODO: open B_PLS/scripts/template_batchfile.txt and adjust number of conditions, block onsets and block length!
# TODO: Run script from the */B_PLS/scripts folder to properly access the PLS_bash_config file

source preproc_bash_config.sh

for SID in $SubjectList; do

		fMRIDir="${ProjectPath}/A_preproc/data/${SID}/fMRI" #directory with input image
		InputImage="${fMRIDir}/${SID}_func_feat_BPfilt_denoised_MNI2mm_flirt.nii.gz" #input image
		tmpl_batchfile = "${ProjectPath}/B_PLS/scripts/template_batchfile.txt"
        batchfile = "${ProjectPath}/B_PLS/batchfiles/${SID}_batchfile.txt"
        mkdir "${ProjectPath}/B_PLS/batchfiles" 

		project = "FACEHOUSE" # change according to your project name!
		COND1 = "face" #change according to your condition names; don't forget to adjust block_onsets and length in batchfile!
		COND2 = "house" #change according to your condition names; don't forget to adjust block_onsets and length in batchfile!
		COND3 = "fixation" #change according to your condition names; don't forget to adjust block_onsets and length in batchfile!

	    cp ${tmpl_batchfile} ${batchfile} #copy template file and change

		sed -i "s/PROJECT/$project/g" ${batchfile}
		sed -i "s/ID/${SID}/g" ${batchfile}
		sed -i "s/FUNCdata_run1/$InputImage/g" ${batchfile}
		sed -i "s/COND1/$COND1/g" ${batchfile}
		sed -i "s/COND2/$COND2/g" ${batchfile}
		sed -i "s/COND3/$COND3/g" ${batchfile}
	
	done
done