#!/bin/bash

## This script performs ICA on the functional niftis with the help of FSL MELODIC
## goal: use the ICA to detect artefacts and remove these components later from the data
############################################################################################

# Get ProjectPath & SubjectList: adjust in preproc_bash_config.sh file
# TODO: Run script from the */A_preproc/scripts folder to preoperly access the preproc_bash_config file
# TODO: adjust TR to TR of your func data
source preproc_bash_config.sh

for SID in $SubjectList; do

	fMRIDir="${ProjectPath}/A_preproc/data/${SID}/fMRI/" # directory where input niftis are located
	ICADir="${fMRIDir}/${SID}_func_feat_BPfilt.ica" # output directory with ICA results
														
	# run fsl melodic
	melodic -i ${fMRIDir}/${SID}_func_feat_BPfilt -o ${ICADir} --dimest=mdl -v --nobet --bgthreshold=3 --tr=2.0 --report --guireport=${ICADir}/report.html -d 0 --mmthresh=0.5 --Ostats

done

	