clear all;

folder = "SD-20250605B";
cwd = "D:\Project\SDANNCE-Models\555-5CAM\"+folder;
cd(cwd)

%%

isPicker = 0;  % Only include the pickerView views in the merged label file

pickerView = 5; % [2,3,4]
numCam = 4;

%%

labelData = cell(numCam, 1);
for j = 1:numCam
    tempStruct = struct('data_2d', [], 'data_sampleID', []);
    labelData{j} = tempStruct;
end

matfiles = dir('*.mat');
matmerged = dir(folder+'*.mat');
mergedmat = {matmerged.name};
for m = 1:length(matfiles)
    matname = matfiles(m).name;
    currentmat = load(matname);
    curmatvars = fieldnames(currentmat);
    isDannce = ismember('labelData', curmatvars);
    if isDannce
        comID = size(currentmat.labelData{1}.data_2d,2);
        if comID ~= 2 && ~ismember(matname,mergedmat)
            for i = 1:numCam
               labelData{i}.data_2d = vertcat(labelData{i}.data_2d,currentmat.labelData{i}.data_2d);
               labelData{i}.data_sampleID = horzcat(labelData{i}.data_sampleID,currentmat.labelData{i}.data_sampleID);
            end
        end
    end
end

savename = folder+'.mat';

if isPicker == 1
    for k = 1:numCam
        if ~ismember(k,pickerView)
            labelData{k}.data_2d = [];
            labelData{k}.data_sampleID = [];
        end
    end
    savename = folder+'-cam'+pickerView+'.mat';
end

save(savename,"labelData");