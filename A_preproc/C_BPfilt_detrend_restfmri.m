%% Load, Filter and Save a NIfTI
% This function bandpass filters unfiltered nifti files 
% Filtering is performed with a
% butterworth filter with LowCutoff = 0.01; HighCutoff = 0.1;
% filtorder = 8; Also uses spm12.
% Input: functional nifti
% Output: bandpass filtered nifti
% Parameters: low and high cutoff frequencies, filtorder, adjust in script below!

%% NOTES:

% The script requires the user to alter a preproc_mat_config file in which
% the ProjectPath and SubjectList are stated.

% Please run the script while in the */A_preproc/scripts
% folder so as to properly access the preproc_mat_config file.

%% Add paths & SubjectList

[ProjectPath,SubjectList]=preproc_mat_config;

addpath(genpath([ProjectPath, 'E_toolboxes/NIFTI_toolbox']))
addpath(genpath([ProjectPath, 'E_toolboxes/spm12/spm_detrend']))
addpath(genpath([ProjectPath, 'E_toolboxes/spm12/preprocessing_tools']))

%% Define filter variables, for detail see help NoiseGenerator.m
LowCutoff = 0.01;
HighCutoff = 0.1;
filtorder = 8;

%% loop over subjects
for i=1:numel(SubjectList)
    
    %% Variable Paths

    fMRIPATH = ([ProjectPath 'A_preproc/data/', SubjectList{i}, '/fMRI']);
    FEATDATA = ([fMRIPATH, '/', SubjectList{i}, '.feat/filtered_func_data.nii.gz']);

    img = load_untouch_nii(FEATDATA);    
    nii = double(reshape(img.img, [], img.hdr.dime.dim(5)));
    % TR
    TR = img.hdr.dime.pixdim(5);
    samplingrate = 1/TR;         %in Hz, TR=2s, FS=1/(TR=2)
    
    %%load mask
    mask = load_untouch_nii ([fMRIPATH,'/', SubjectList{i}, '.feat/mask.nii.gz']);
    mask = double(reshape(mask.img, [], mask.hdr.dime.dim(5)));
    mask_coords = find(mask);
    % mask image
    nii_masked = nii(mask_coords,:);
    
    %%%%%%%%%%%%%
    %% Detrend %%
    %%%%%%%%%%%%%
    k = 2;           % linear and quadratic detrending
    nii_means = mean(nii_masked,2); % get TS voxel means
    [ nii_masked ] = S_detrend_data2D( nii_masked, k );

    %% read TS voxel means
    for m=1:size(nii_masked,2)
        nii_masked(:,m) = nii_masked(:,m)+nii_means;
    end    
    
    %%%%%%%%%%%%
    %% filter %%
    %%%%%%%%%%%%    
    for n = 1:size(nii_masked,1)

        [B,A] = butter(filtorder,LowCutoff/(samplingrate/2),'high'); 
        nii_masked(n,:)  = filtfilt(B,A,nii_masked(n,:)); clear A B;

        [B,A] = butter(filtorder,HighCutoff/(samplingrate/2),'low');
        nii_masked(n,:)  = filtfilt(B,A,nii_masked(n,:)); clear A B

    end
    disp ([subjID, ': detrending + bandpass filtering + add mean back done']);

    %% save file
    nii(mask_coords,:)= nii_masked;
    img.img = reshape(nii,img.hdr.dime.dim(2),img.hdr.dime.dim(3),img.hdr.dime.dim(4), size(img.img,4));
    save_nii (img, [fMRIPATH, '/', SubjectList{i}, '_func_feat_BPfilt.nii'])
    disp (['saved as: ',[fMRIPATH, '/', SubjectList{i}, '_func_feat_BPfilt.nii']])



end
