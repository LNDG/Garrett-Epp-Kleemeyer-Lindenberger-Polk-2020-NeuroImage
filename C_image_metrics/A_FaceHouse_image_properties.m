%calculate image stats (contrast, correlation, energy, homogeneity) for face
%and house stimuli.

%% Faces and houses

[ProjectPath, SubjectList] = metric_mat_config();

img_dir = ([ProjectPath, 'F_images_experiment/']);
fig_dir = ([ProjectPath, 'D_figures/';]);

mkdir(fig_dir)

imagetype_names = {'AmericanManFace','AmericanWomanFace','HouseSingApt','HouseSingHouse','HouseUsaApt','HouseUsaHouse'};


%set up for stdfilt
NHOOD = true(9);%set neighbourhood to match entropy algortihm default in Matlab...

%now loop
for i=1:numel(imagetype_names)
    if i <= 2 % for faces
        stim_count = 30;%30 faces from each category, 15 houses from each category.
        else stim_count = 15;
    end
    
    for j=1:stim_count
        I = imread([img_dir,imagetype_names{i},num2str(j),'.bmp']); %read-in image
        Efilt_loc_mean(j,i) = mean(mean(entropyfilt(I)));%default is 9*9 matrix for calculation. This give us average entropy over local bits...
        Stdfilt_loc_mean(j,i) = mean(mean(stdfilt(I,NHOOD)));%using same matrix size as for entropy, gives average std of local bits.
        
        glcm = graycomatrix(I); %creates gray-level co-occurrence matrix from image I
        contrast(j,i) = graycoprops(glcm,'contrast'); %calculates contrast from glcm
        correlation(j,i) = graycoprops(glcm,'correlation'); %calculates correlation from glcm
        energy(j,i) = graycoprops(glcm,'energy'); %calculates energy from glcm
        homogeneity(j,i) = graycoprops(glcm,'homogeneity'); %calculates homogeneity from glcm

    end
   
end
save([img_dir,'facehouse_image_properties.mat']);



%% create matrices, add NaNs

contrast = squeeze(struct2cell(contrast));
empties = cellfun('isempty',contrast);
contrast(empties) = {NaN};
imagestats{1} = cell2mat(contrast);

correlation = squeeze(struct2cell(correlation));
empties = cellfun('isempty',correlation);
correlation(empties) = {NaN};
imagestats{2} = cell2mat(correlation);

energy = squeeze(struct2cell(energy));
empties = cellfun('isempty',energy);
energy(empties) = {NaN};
imagestats{3} = cell2mat(energy);

homogeneity = squeeze(struct2cell(homogeneity));
empties = cellfun('isempty',homogeneity);
homogeneity(empties) = {NaN};
imagestats{4} = cell2mat(homogeneity);

Efilt_loc_mean = mat2cell(Efilt_loc_mean,30,6);
empties = cellfun('isempty',Efilt_loc_mean);
Efilt_loc_mean(empties) = {NaN};%%doesn't work...must fix
imagestats{5} = Efilt_loc_mean{1,1};

Stdfilt_loc_mean = mat2cell(Stdfilt_loc_mean,30,6);
empties = cellfun('isempty',Stdfilt_loc_mean);
Stdfilt_loc_mean(empties) = {NaN};%%doesn't work...must fix
imagestats{6} = Stdfilt_loc_mean{1,1};

%% Set up subplots for hybrid figure
imagestat_names = {'Contrast','Correlation','Energy','Homogeneity','Entropyfilt','Stdfilt'};

%plot grid and histograms
figure;
for i=1:length(imagestat_names)    
    
    fig(i) = subplot(2,3,i);% add plots into a 3*5 grid
    h_face = histogram(imagestats{i}(1:30,1:2));%first two cols are face stim, all rows
    h_face.FaceAlpha = .5;
    hold on;
    h_house = histogram(imagestats{i}(1:15,3:end));%last four columns are house stim, but with only 15 stim per category.
    h_house.FaceAlpha = .5;
    xlabel(imagestat_names{i},'fontsize',20);
    set(gca,'fontsize',16);
    axis square;
end

lgd = legend('Faces','Houses');
lgd.FontSize = 20;
%lgd.Location = 'east'; %might have to manually move it to taste...
lgd.Orientation = 'horizontal';


%prepare for output
FigXX = gcf;
FigXX.PaperPositionMode = 'auto';
fig_pos = FigXX.PaperPosition;
FigXX.PaperSize = [fig_pos(3) fig_pos(4)];% (3) and (4) values are actually XXXX (width) and YYYY (height) to reproduce exact fig...

%save
saveas(gcf,[fig_dir,'FigXX_imagestats.pdf'])

