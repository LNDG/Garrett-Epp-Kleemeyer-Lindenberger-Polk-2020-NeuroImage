 function B_Sessiondatamat_creation
% This script creates session data mat-files for PLS from txt template (B_PLS/batchfiles/SID_batchfile.txt)
% Input: SID_batchfile.txt (adjusted to your data) (after running script A_edit_txtfiles.sh)
% Output: mean_sessiondata.mat file for each subject

%% Set directories and ID list

[ProjectPath, SubjectList] = PLS_mat_config();

TEMPLPATH = ([ProjectPath, 'B_PLS/scripts/batchfiles/']); %where the template is
SAVEPATH =([ProjectPath, 'B_PLS/B_meanPLS/']); %output directory

mkdir(SAVEPATH);

%% Add PLS toolbox   
addpath(genpath([ProjectPath, 'E_toolboxes/Pls']));

%%
for i = 1:length(SubjectList)
    cd (SAVEPATH);

    batchname=[SAVEPATH, SubjectList{i},'_batchfile.txt'];
    batch_plsgui(batchname);
    
end