function B_run_hmax_s1_c1_s2_c2

% returns:
%
%     c1: a cell array [1 nBands], contains the C1 responses for img
%     s1: a cell array [1 nBands], contains the S1 responses for img
%     c2: fit to simple and complex (hybrid) C1-level prototypical feature sets
%     s2: max over all scale bands, quantifying the global fit (inverse Euclidean distance) between the
%       features of each image and each prototype, separately for each prototype C1 neighborhood size
%     average_c1_house/face: average of values within each scale band & orientation
% The output of the S1/C1 layer depends on the scale of the filter (i.e. on
% the receptive field sizes per filter band)
% output s1: 8 cells (per scale band) x 2 cells = 2 filter sizes per scale band x
% 16 cells: orientations x matrices with img dimensions
% output c1: downsampled (depending on pooling size) matrix of img (e.g. 150x150 values x16 orientations) per scale band
% attention: number of RFsizes has to be twice the number of scale bands!
% (a max of two filter sizes is taken per scale band)
% attention: number of scaling factors (div) has to match number of RFsizes!
% attention: number of c1Scale has to match number of c1Space+1 (or number of bands + 1: i.e. 9 for 8
% scale bands)
%
% TODO: add toolbox E_toolboxes/hmaxMatlab to path!
% configure and add C_image_metrics/metric_mat_config to path


%% Specify paths

[ProjectPath, SubjectList] = metric_mat_config();
SAVEDIR = fullfile(ProjectPath, 'C_image_metrics', 'hmax_output');
mkdir(SAVEDIR);
TOOLBOXDIR = fullfile(ProjectPath, 'E_toolboxes', 'hmaxMatlab');
addpath(genpath(TOOLBOXDIR))


%% Initialize filters with appropriate parameters
fprintf('initializing S1 gabor filters\n');
orientations = [90 -45 0 45]; % 4 orientations for gabor filters
RFsizes      = 7:2:37;        % 16 receptive field sizes in pixel (n x n): 16 x 16 = 256 receptive fields -> 16 filters with 16 orientations
div          = 4:-.05:3.25;    % scaling facotrs  tuning parameters for the filters' "tightness"
[filterSizes,filters,c1OL,nOrientations] = initGabor(orientations,RFsizes,div); %c10L = 2: overlap between C1 units

fprintf('initializing C1 parameters\n')
c1Scale = 1:2:18; % define 8 scale bands group of filter sizes over which a local max is taken; 8 bands, 16 scales, 16 filters (orientations)
c1Space = 8:2:22; % defining spatial pooling range for each scale band; neighborhood of m x m S1 units =  
  % determines the size of the array of neighboring S1 units of all sizes in that filter band which feed into a C1 unit 
  

%% Read in images
% Creates a cell array with each cell containing a grayscaled
% representation of one image. Data type should be double, not uint8.
IMG=([ProjectPath, 'F_images_experiment/']);
for i=1:30
        Faces{i} = double(imread([IMG, 'AmericanManFace', num2str(i), '.bmp']));
        Faces{i+30} = double(imread([IMG, 'AmericanWomanFace', num2str(i), '.bmp']));
end

for i=1:15
        Houses{i} = double(imread([IMG, 'HouseSingApt', num2str(i), '.bmp']));
        Houses{i+15} = double(imread([IMG, 'HouseSingHouse', num2str(i), '.bmp']));
        Houses{i+30} = double(imread([IMG, 'HouseUsaApt', num2str(i), '.bmp']));
        Houses{i+45} = double(imread([IMG, 'HouseUsaHouse', num2str(i), '.bmp']));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% calculate s1 and c1:faces %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k=1:length(Faces)      
    [c1_face{k},s1_face{k}] = C1(Faces{k},filters,filterSizes,c1Space,c1Scale,c1OL, 0);
end

%% calculate per band/orientation average of (nonzeros) over values/locations!
%% median of c1 as well as sd and entropy of c1 distributions/heatmaps

for k=1:length(c1Scale)-1
    for j=1:length(orientations)
        for i=1:length(Faces)
        average_c1_face(k, j, i)=median(nonzeros(c1_face{1, i}{1, k}(:, :, j)));
        sd_c1_face(k, j, i)=std(nonzeros(c1_face{1, i}{1, k}(:, :, j))); 
        entropy_c1_face(k, j, i) = median(nonzeros(entropyfilt((c1_face{1, i}{1, k}(:, :, j)))));
        end
    end
end

save(SAVEDIR, 'average_c1_face', 'sd_c1_face', 'entropy_c1_face');

clear c1_face s1_face  average_c1_face


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% calculate s1 and c1:houses %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k=1:length(Faces)      
    [c1_house{k},s1_house{k}] = C1(Houses{k},filters,filterSizes,c1Space,c1Scale,c1OL, 0);
end

%% calculate per band/orientation average of (nonzeros) over values/locations!

for k=1:length(c1Scale)-1
    for j=1:length(orientations)
        for i=1:length(Faces)
        average_c1_house(k, j, i)=median(nonzeros(c1_house{1, i}{1, k}(:, :, j)));
        sd_c1_house(k, j, i)=std(nonzeros(c1_house{1, i}{1, k}(:, :, j)));
        entropy_c1_house(k, j, i) = median(nonzeros(entropyfilt((c1_house{1, i}{1, k}(:, :, j)))));
        end
    end
end

save(SAVEDIR, 'average_c1_house',  'sd_c1_house', 'entropy_c1_house');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% compare means of face / house distributions per scale & orientation %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for k=1:length(c1Scale)-1
    for j=1:length(orientations)
        [h(k, j), p(k, j),  ~, ~]=ttest2(average_c1_face(k, j, :), average_c1_house(k, j, :), 'Vartype','unequal'); 
        [h_sd(k, j), p_sd(k, j), ~, ~]=ttest2(sd_c1_face(k, j, :), sd_c1_house(k, j, :), 'Vartype','unequal'); 
        [h_entropy(k, j), p_entropy(k, j), ~, ~]=ttest2(entropy_c1_face(k, j, :), entropy_c1_house(k, j, :), 'Vartype','unequal'); 
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% calculate s2 and c2:faces & houses %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load universal patch set
load([TOOLBOXDIR, 'universal_patch_set.mat'], 'patchSizes', 'patches');

nPatchSizes = size(patchSizes,2);

for k = 1:length(Faces)
        
    [c2_faces{k},~,bestBands_faces{k},bestLocations_faces{k},s2_faces{k},~] = extractC2forCell...
        (filters,filterSizes,c1Space,c1Scale,c1OL,patches,Faces{k},nPatchSizes,patchSizes(1:3,:));
end

save([SAVEDIR, 'c2_s2_faces.mat'], 'c2_faces', 'bestBands_faces', 'bestLocations_faces','s2_faces', '-v7.3');

for k = 1:length(Houses)
        
    [c2_houses{k},~,bestBands_houses{k},bestLocations_houses{k},s2_houses{k},~] = extractC2forCell...
        (filters,filterSizes,c1Space,c1Scale,c1OL,patches,Houses{k},nPatchSizes,patchSizes(1:3,:));
end

save([SAVEDIR, 'c2_s2_houses.mat'], 'c2_houses', 'bestBands_houses', 'bestLocations_houses','s2_faces', '-v7.3');


end
