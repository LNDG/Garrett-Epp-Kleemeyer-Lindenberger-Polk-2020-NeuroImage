function C_GMcommonCoords
%This script creates a mask of coordinates including only gray matter (GM) coordinates and
%commonly activated coordinates for all subjects in the sample called final coordinates
%        
%Note: All niftis need to have the same resolution and be in standard space
%Input: preprocessed functional niftis in standard space
%Output: mat file containing common coordinates


%% Specify paths

[ProjectPath, SubjectList] = PLS_mat_config();

DATAPATH = [ProjectPath, 'A_preproc/data/']; %preprocessed niftis in standard space

SAVEPATH = [ProjectPath, 'G_standards_masks/GM_mask']; %standard gray matter mask
mkdir(SAVEPATH);

%% Load MNI template of GM mask

GMmask=load_nii ([ProjectPath, 'G_standards_masks/avg152_T1_gray_mask_90.nii']);

final_coords = (find(GMmask.img))';

%% Get common coordinates
% initialize common coordinates to a vector from 1 to 1 million to ensure 1st subjects coords are all included

common_coords = (1:1000000);


for i = 1:numel(SubjectList)
   try
    
    % load subject nifti
    fname = [DATAPATH , SubjectList{i}, '/fMRI/', SubjectList{i}, '_func_feat_BPfilt_denoised_MNI2mm_flirt.nii'];    
    nii = load_nii(fname); %load preprocessed images
           
    % create a matrix of intersecting coordinats over all subjects
    subj_coords = find(nii.img(:,:,:,1));
    common_coords=intersect(common_coords,subj_coords);
  
    disp ([SubjectList{i}, ': added to common coords'])
  
   % Error log    
   catch ME
       warning(['error with subject ', SubjectList{i}]);
   end
   
end

%% Match common coordinates with GM coordinates

final_coords=intersect(final_coords,common_coords); % creates final coordinates
final_coords=final_coords';

%% Save final coordinates

save ([SAVEPATH, 'GMcommoncoords.mat'], 'final_coords');

end