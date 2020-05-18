function E_mean_BfMRIsessiondatamat_creation
% This script adds a fourth condition to the mean_sessiondata.mats: house - face 

% to do: set condition names!


%% Set directories, condition names & ProjectID

[ProjectPath, SubjectList] = PLS_mat_config();

MATPATH = [ProjectPath, 'B_PLS/B_meanPLS/']; % specify directory containing MeanBOLD PLS files

SAVEPATH = [ProjectPath, 'B_PLS/A_SD_PLS/'];   % specify where SD_BOLD PLS files will be saved

conditions = {'face','house','fixation'};%set all relevant condition names

Project = "FACEHOUSE"; % change project according to project name in A_edit_txtfiles.sh!

%% Add toolbox

addpath(genpath([ProjectPath, 'E_toolboxes/preprocessing_tools']));

%% Load common coordinates (Output of S_GMcommonCoords.m)
 
load([ProjectPath, 'G_standards_masks/GM_mask/GMcommoncoords.mat']);


for i = 1:length(SubjectList)

%% Specify subject's nifti path

NIIPATH_ROOT = [ ProjectPath, 'A_preproc/data/', SubjectList{i}, '/fMRI/'];       % specify directory containing preprocessed images

NIIPATH = ([NIIPATH_ROOT, SubjectList{i}, '_func_feat_BPfilt_denoised_MNI2mm_flirt.nii']);

%% Load a subject's session data mat file (output from previous step).

session_mat = load([MATPATH, 'mean_', Project, '_', SubjectList{i},'_BfMRIsessiondata.mat']);

% replace fields with correct info: prefix and replacing st_coords with
% final_coords= gray matter masked common set of coords between all
% subjects
session_mat = rmfield(session_mat,'st_datamat');
session_mat = rmfield(session_mat,'st_coords');
session_mat.session_info.datamat_prefix=['SD_',SubjectList{i}, Project];
session_mat.st_coords = final_coords';  



    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% create a fourth condition: house - face %% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% compute change House - Face
    session_mat.st_datamat(4,:) = session_mat.st_datamat(2,:) - session_mat.st_datamat(1,:);
    
    %% adjust headers
    a.session_info.num_conditions            = 4;
    a.session_info.num_conditions0           = 4;
    a.session_info.condition {1,4}           = ['house-face'];
    a.session_info.condition_baseline {1,4}  = [0,1];
    a.session_info.condition_baseline0 {1,4} = [0,1];
    a.num_subj_cond                          = [1,1,1,1];
    a.st_evt_list                            = [1,2,3,4];
    
    % save each subject's datamat
    save([SAVEPATH,'mean_',SubjectList{i},'_BfMRIsessiondata.mat'],'-struct','session_mat','-mat');
% 
%     waitbar(i/numel(ID),h);
 
	disp (['ID: ', SubjectList{i}, ' done!'])
    

clear session_mat

end

end