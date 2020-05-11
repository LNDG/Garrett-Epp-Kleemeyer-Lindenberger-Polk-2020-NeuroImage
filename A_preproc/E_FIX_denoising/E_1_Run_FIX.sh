#!/bin/bash

## This script extracts features with FIX
## these features are needed for the classifier
############################################################################################

# Get ProjectPath & SubjectList: adjust in preproc_bash_config.sh file
# TODO: Download & install FSL FIX in your homedirectory: /usr/local/fix (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIX/UserGuide)
# TODO: create rejcomps folder: */A_preproc/scripts/E_FIX/rejcomps: 
	## Go through the ICAs (html site), output from the previous ICA step, and decide on which components are artefactual
	## Fill out E_0_create_rejcomp_txtfiles.sh accordingly 
	## Execute E_0_create_rejcomp_txtfiles.sh. Output: Textfiles named XXX_rejcomps.txt containing artefactual ICA components
# TODO: Run this script from the */A_preproc/scripts folder to properly access the preproc_bash_config file

source preproc_bash_config.sh
SCRIPTDIR = ${ProjectPath}/A_preproc/scripts

for SID in $SubjectList; do		
	
	## run feature extraction
	fMRIDir="${ProjectPath}/A_preproc/data/${SID}/fMRI/" # directory where input niftis are located
	FEATDir="${fMRIDir}/${SID}.feat"
 	/usr/local/fix/fix -f $FEATDir

	## check if fix terminated properly
	cd ${FEATDir}/fix
	Log=`grep "End of Matlab Script" logMatlab.txt | tail -1` # Get line containing our desired text output
		
	if [ ! -d ${FEATDir}/fix ]; then
		echo "${SID}: missing fix folder" 
		continue
	elif [ ! "$Log" == "End of Matlab Script" ]; then
		echo "${SID}: fix did not terminate properly" 
	fi


	## Create hand_labels_noise.txt file
	# the rejcomps folder has to be created manully, filled with textfiles naming artefactual components (see template in above description)
	cd $SCRIPTDIR/E_FIX/rejcomps 
	echo  "${SID}: creating hand_labels_noise.txt"
	rm ${FEATDir}/hand_labels_noise.txt #remove file if it already exists
	cp BIK${subj}_prerun${run}_rejcomps.txt ${FEATDir}/hand_labels_noise.txt #copy rejcomps file to FEAT dir and rename it
		
	## create list for training set
	TrainingSet=""
	TrainingSet="${TrainingSet} ${FEATDir}"
done

## create training set
cd $SCRIPTDIR/E_FIX/
/usr/local/fix/fix -t TrainingData ${TrainingSet}

## apply cleanup
for SID in $SubjectList; do	
	fMRIDir="${ProjectPath}/A_preproc/data/${SID}/fMRI/" # directory where input niftis are located
	FEATDir="${fMRIDir}/${SID}.feat"
	/usr/local/fix/fix  -c ${FEATDir} $SCRIPTDIR/E_FIX/TrainingData.RData 60
done