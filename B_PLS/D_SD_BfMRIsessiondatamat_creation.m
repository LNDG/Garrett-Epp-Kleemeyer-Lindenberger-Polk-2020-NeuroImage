function D_SD_BfMRIsessiondatamat_creation
% This script performs the 2nd pre-step for PLS: Fill matrix with
% power and SD values for various condtions, runs and blocks.
% Input: mean_BfMRIsessiondata.mat
% Output: SD_BfMRIsessiondata.mat
% The SD_BfMRIsessiondata.mat are input for the PLS analysis and store the
% voxel's power values, whole brain coverage, and the common
% coordinate space between all subjects

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate SD values %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%% create this subject's datamat

session_mat.st_datamat = zeros(numel(conditions),numel(final_coords));


%% ---------------- SD_BOLD Calculation -----------------------------------
% Within each bloack (scan) as deviation from block's 
% temporal mean. 


  % intialize cond specific scan count for populating cond_data
  clear count cond_data block_scan;
  for cond = 1:numel(conditions)
      count{cond} = 0;
  end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % within each block express each scan as deviation from block's 
    % temporal mean.Concatenate all these deviation values into one 
    % long condition specific set of scans that were normalized for 
    % block-to-block differences in signal strength. In the end calculate
    % stdev across all normalized cond scans
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % for each condition identify its scans within  runs 
    % and prepare where to put cond specific normalized data
    used_run = [];
    for cond = 1:numel(conditions)
      tot_num_scans = 0;
      
      dst_run = 0;
      for run = 1:session_mat.session_info.num_runs
        onsets = session_mat.session_info.run(run).blk_onsets{cond}+1;% +1 is because we need matlab indexing convention
        if onsets==0 %this if statement looks for any conditions (within run) that don't have data of interest, and if it finds any, then the next "run" loop is entered.
            continue
        end
        
        dst_run = dst_run + 1;
        used_run(cond, run) = 1;
        
        lengths = session_mat.session_info.run(run).blk_length{cond};
        
        for block = 1:numel(onsets)
          block_scans{cond}{dst_run}{block} = onsets(block)-1+[1:lengths(block)];
          this_length = lengths(block);
          if max(block_scans{cond}{dst_run}{block}>session_mat.session_info.run(run).num_scans)
            disp(['bljak ' subj ' something wrong in block onset lengths']);
            block_scans{cond}{dst_run}{block} = intersect(block_scans{cond}{dst_run}{block},[1:session_mat.session_info.run(run).num_scans]);
            this_length = numel(block_scans{cond}{dst_run}{block});
          end
          tot_num_scans = tot_num_scans + this_length;
        end
      end
      cond_data{cond} = zeros(numel(final_coords),tot_num_scans);%create empty matrix with dimensions coords (rows) by total # of scans (columns). 
    end
    
    dst_run = 0;
    for run = 1:session_mat.session_info.num_runs   %1:2       
           
      % load nifti file for this run
      fname = ([session_mat.session_info.run(run).data_path, '/', session_mat.session_info.run(run).data_files]);
      nii = load_nii(fname); %(x by y by z by time)
      img = double(reshape(nii.img,[],size(nii.img,4)));% 4 here refers to 4th dimension in 4D file....time.
      img = img(final_coords,:);%this command constrains the img file to only use final_coords, which is common across subjects.

      %now regress out motion parameters for this run. If decide to
      %regress CSF and WM time series in the future, do it here by loading .txt files with that info.
      %temporal_mean = mean(img,2);%calculate mean for each voxel across all TRs (used in residualization step below).
      %mp_ts=load(['/Volumes/damain2/MRI/Data/DA_main/n-back/preproc+first_2010/nback_final/MC/prefiltered_func_data_mcf_',subj(1:8),'_run',num2str(run),'.txt']);%load motion params. The subj(1:8) command shrinks the subj string variable to locate MP files correctly.
      %img = residualize([mp_ts],img')' + repmat(temporal_mean,[1 size(img,2)]);%use Randy's "residualize" function to regress using matrices instead of vectors.
      %%repmat of the temp mean is needed here to put data back in original "zone" after residualization, rather than zero centred.
      clear nii;

      %now, proceed with creating SD datamat...          

	
	disp('writing SD data...')      
      
      dst_run = dst_run + 1;

      for cond = 1:numel(conditions)

        if not(used_run(cond,run))
          continue
        end
        
       for block = 1:numel(block_scans{cond}{run}) % {1:9} {1:6}  -> 4

          block_data = img(:,block_scans{cond}{dst_run}{block});% (vox time)
          % normalize block_data to global block mean = 100. 
          block_data = 100*block_data/mean(mean(block_data));
          % temporal mean of this block
          block_mean = mean(block_data,2); % (vox) - this should be 100
          % express scans in this block as  deviations from block_mean
          % and append to cond_data
          good_vox = find(block_mean);              
          for t = 1:size(block_data,2)
            count{cond} = count{cond} + 1;
            cond_data{cond}(good_vox,count{cond}) = block_data(good_vox,t) - block_mean(good_vox);%must decide about perc change option here!!??
          end
        end
      end
    end

    for cond = 1:numel(conditions)
      session_mat.st_datamat(cond,:) = squeeze(std(cond_data{cond},0,2))';
    end
    disp(['SD calculation: done'])

    %all values get saved in approp datamat below; nothing should need to be
    %saved to session files at this point, so leave those as is.
    clear data;
    
    
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
    save([SAVEPATH,'SD_',SubjectList{i},'_BfMRIsessiondata.mat'],'-struct','session_mat','-mat');
% 
%     waitbar(i/numel(ID),h);
 
	disp (['ID: ', SubjectList{i}, ' done!'])
    

clear session_mat

end

end