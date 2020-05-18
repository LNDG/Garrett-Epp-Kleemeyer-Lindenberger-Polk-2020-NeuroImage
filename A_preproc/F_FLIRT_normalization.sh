#!/bin/bash

## This script registers the preprocessed nifti to standard space (e.g. MNI space)
## Input: 1. preprocessed nifti, 2. anatomical brain-extracted nifti, 3. MNI standard template
## Output: prepocessed nifti in standard space

#The command line calls made in a two-stage registration of imageA to imageB to imageC are as follows:
#optional: fslreotient2std imageA imageA-> reorients the image to standard MNI orientation, NO registration, only rotation!
#flirt [desired options] -in imageA -ref imageB -omat transf_A_to_B.mat
#flirt [desired options] -in imageB -ref imageC -omat transf_B_to_C.mat
#convert_xfm -omat transf_A_to_C.mat -concat transf_B_to_C.mat transf_A_to_B.mat
#flirt -in imageA -ref imageC -out imageoutput -applyxfm -init transf_A_to_C.mat

#The above steps perform two registrations (the first two steps) saving the respective transformations as .mat files, then concatenate the transformations using convert_xfm, then apply the concatenated transformation to resample the original image using flirt. Note that the first two calls to flirt would normally require the cost function or degrees of freedom (dof) to be set in the desired options. In the final call to flirt the option -interp is useful for specifying the interpolation method to be used (the default is trilinear).

# Get ProjectPath & SubjectList
# TODO: Run script from the */A_preproc/scriptsfolder to preoperly access the preproc_bash_config file
# TODO after registration: check each registered image visually, using MNI as background 

source preproc_bash_config.sh

for SID in $SubjectList; do
	
	fMRIDir="${ProjectPath}/A_preproc/data/${SID}/fMRI" #directory with input image
	highres="${ProjectPath}/A_preproc/data/${SID}/anat/mprage_brain.nii.gz" #anatomical image, brain extracted (conduct BET beforehands!!)
	highres_head="${ProjectPath}/A_preproc/data/${SID}/anat/mprage.nii.gz" #anatomical image
	example_func="${fMRIDir}/${SID}.feat/reg/example_func.nii" #example func image from FEAT
	InputImage="${fMRIDir}/${SID}_func_feat_BPfilt_denoised.nii.gz" #input image
	OutputImage="${fMRIDir}/${SID}_func_feat_BPfilt_denoised_MNI3mm_flirt.nii.gz" #output image	
	standard_2mm="${ProjectPath}/G_standards_masks/standard/MNI152_T1_2mm_brain.nii.gz" #standard image
	standard_3mm="${ProjectPath}/G_standards_masks/standard/MNI152_T1_3mm_brain.nii.gz" #standard image
	
	RegMatricesDir="${fMRIDir}/reg" # directory where registration matrices will be stored
	mkdir ${RegMatricesDir}

	echo "Running registration procedure for ${SID}"
	
	#reorient to standard orientation
	fslreorient2std ${InputImage} ${InputImage} #image is overwritten: only rotations applied, no registration
	echo "${SID} Reoriented to standard"

	# functional nifti (lowres, example_func) to subject-specific highres T1 (anat)
	epi_reg --epi=$example_func --t1=$highres_head --t1brain=$highres --out=${RegMatricesDir}/transf_lowres_to_highres.mat
	echo "${SID} epi_reg finished"
	
	# T1 (anat) to standard space
	echo "creating transf_highres_to_refMNI.mat"
	#flirt -in ${highres} -ref ${standard_2mm} -omat ${RegMatricesDir}/transf_highres_to_refMNI.mat 
	flirt -in ${highres} -ref ${standard_3mm} -omat ${RegMatricesDir}/transf_highres_to_refMNI.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear

	# functional input image to standard space concatenating the two steps above
	echo "creating transf_lowres_to_refMNI.mat" 
	convert_xfm -omat ${RegMatricesDir}/transf_lowres_to_refMNI.mat -concat ${RegMatricesDir}/transf_highres_to_refMNI.mat ${RegMatricesDir}/transf_lowres_to_highres.mat

	echo "performing registration"
	#flirt -in ${InputImage} -ref ${standard_2mm} -out ${OutputImage} -applyxfm -init ${RegMatricesDir}/transf_lowres_to_refMNI.mat
	flirt -in ${InputImage} -ref ${standard_3mm} -out ${OutputImage} -applyxfm -init ${RegMatricesDir}/transf_lowres_to_refMNI.mat

done
