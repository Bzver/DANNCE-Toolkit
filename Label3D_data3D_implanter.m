clear all;
cd 'D:\Repository\Label3D-mod'

%%
numCam = 4;

manualFrames = [];

% Only used when manual frames is not supplied
startFrame = 0;
stepSize = 25;
maxFrame = 4000;

videoResolution = [960, 540]; % Per view
distort = false;

% Set this to 1 if extracting COM data from com3d.mat
isCOM = 0;

% Set this to 1 if dealing with multiple animals
isMultiAnimal = 0;
idx = 1; % Animal index to extract

%%
if numCam == 4
    hostname = 'viewer-host.mat';
elseif numCam == 5
    hostname = 'viewer-host-5cam.mat';
end
load(hostname);

if isempty(manualFrames)
    framesToLabel = startFrame:stepSize:maxFrame;
else
    framesToLabel = manualFrames';
end

if isCOM == 1
    start_sample = 0;
    if isMultiAnimal == 0
        load('com3d.mat');
    else
        matname = "instance" + string(idx) + "com3d.mat";
        load(matname);
    end
    skeleton = load('skeletons/com');
    data_3D = com;
else % Loading 3D data from prediction
    AVGfiles = dir(fullfile('D:\Repository\Label3D-mod','save_data_AVG*.mat'));
    load(AVGfiles(1).name)
    start_sample = sampleID(1); % In case AVGData starts with frames bigger than 0
    skeleton = load('skeletons/rat16');
    pred_sqz = squeeze(pred(:,idx,:,:));
    data_3D = nan(size(pred_sqz,1), length(skeleton.joint_names)*3);
    for j = 1:size(pred_sqz,3)
        for ok = 1:size(pred_sqz,2)
            data_3D(:,ok+3*(j-1)) = pred_sqz(:,ok,j);
        end
    end
end
num_keypoint = length(skeleton.joint_names);
numFrames = length(framesToLabel);
framesToLabel = framesToLabel(framesToLabel>0 & framesToLabel<size(data_3D,1));
data_3D = data_3D(framesToLabel,:);
status = ones(1, numCam, numFrames);
framesToLabel = framesToLabel + start_sample;
handLabeled2D = NaN(num_keypoint,numCam,2,numFrames);

if isCOM ~= 1
    disp("Reproject 3D coordinates to 2D in each views...")
    [data_3D, handLabeled2D] = reproj_3d_to_view(data_3D, handLabeled2D, framesToLabel, videoResolution, cameraPoses, camParams, distort);
end

save('viewer-implanted.mat',"status","handLabeled2D","data_3D","cameraPoses","camParams","skeleton","imageSize","framesToLabel")


%%
function [data_3D, handLabeled2D] = reproj_3d_to_view( ...
    data_3D, handLabeled2D, framesToLabel, videoResolution, cameraPoses, camParams, distort)
    X_index = 1:3:size(data_3D,2);
    for i = 1:length(camParams) % Iterate through each camera views
        orientation = cameraPoses.Orientation{i};
        translation = camParams{i}.t;
        focalLength = [camParams{i}.K(1,1), camParams{i}.K(2,2)];
        prpPoint = [camParams{i}.K(3,1), camParams{i}.K(3,2)];
        RD = camParams{i}.RDistort;
        TD = camParams{i}.TDistort;
        intrinsics = cameraIntrinsics(focalLength,prpPoint,videoResolution,RadialDistortion=RD,TangentialDistortion=TD);
        tformVal = rigidtform3d(orientation,translation);
        for k = 1:length(framesToLabel) % Iterate through each frames to label
            currentX = data_3D(k,X_index);
            currentY = data_3D(k,X_index+1);
            currentZ = data_3D(k,X_index+2);
            currentData3d = [currentX ; currentY; currentZ]';
            currentData2d = world2img(currentData3d,tformVal,intrinsics,ApplyDistortion=distort);
            handLabeled2D(:,i,:,k) = currentData2d;
        end
    end
    data_3D(:,:) = NaN; % Intentionally nullifying 3D data to force Label3D to rely ONLY on manually corrected 2D labels for triangulation.
    disp("Transformation finished!")
end