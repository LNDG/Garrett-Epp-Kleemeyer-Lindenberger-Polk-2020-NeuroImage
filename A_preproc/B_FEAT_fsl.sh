#!/bin/bash 

# TODO: Before running preproc scripts, please change the preproc_bash_config file and the preproc_mat_config file with the correct directories.

#### This script performs FSL FEAT on the raw functional niftis. Before performing it, adjust the design.fsf file matching your images (correct TR, total volumes, volumes to delete etc.)
##################################################################################################################################

# Get ProjectPath & SubjectList
# TODO: Run script from the */A_preproc/scripts to properly access the preproc_bash_config file
source preproc_bash_config.sh

#creates a designfile for each subject and adjust name and paths
for SID in $SubjectList; do 
 
	fMRIDir="${ProjectPath}/A_preproc/data/${SID}/fMRI/" #output directory
	MNI_2mm="${ProjectPath}/G_standards_masks/standard/MNI152_T1_2mm_brain.nii.gz" #standard template
	InputImage="${ProjectPath}/A_preproc/RAW/${SID}/func_nifti.nii.gz" #input niftis
	T1w_brain = "${ProjectPath}/A_preproc/RAW/${SID}/mprage.nii.gz" #T1 weighted image, brain-extracted
	
	#create a designfile based off of the design_NKI.fsf model file
	mkdir -p ${fMRIDir} #creates output directory
	cp ${ProjectPath}/A_preproc/scripts/B_0_design_template.fsf ${fMRIDir}/design_${SID}.fsf #copies designfile for each subject
	
	# For each subject: adjust paths with input path, output path and MNI image path
	cd ${fMRIDir}
	sed -i '' 's|dummy_input|'${InputImage}'|'	 				design_${SID}.fsf #replaces dummy variable by input image name
	sed -i '' 's|dummy_output|'${fMRIDir}/${SID}.feat'|' 		design_${SID}.fsf #replaces dummy variable by output file directory (output of FEAT is .feat)
	sed -i '' 's|dummy_mni|'${MNI_2mm}'|'						design_${SID}.fsf #replaces dummy standard template by chosen template
	sed -i '' 's|dummy_t1_brain|'${T1w_brain}'|'				design_${SID}.fsf #replaces dummy t1w by subject's mprage image
 
done 
 
# run FEAT
for SID in $SubjectList; do   
	
	cd ${fMRIDir} 
	feat design_${SID}.fsf #run FEAT for each subject in output directory
	
done 

