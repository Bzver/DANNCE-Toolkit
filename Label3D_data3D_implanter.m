clear all;
cd 'D:\Repository\Label3D'

%%
numCam = 5;

start_frame = 4275;
step_size = 25;
max_frame = 5000;

videoResolution = [960, 540]; % Per view

confidence_threshold = 0; % 0 to 1
distort = true;

isCOM = 0;
isLowconf = 0;
isManual = 1;

%%
if numCam == 4
    hostname = 'viewer-host.mat';
elseif numCam == 5
    hostname = 'viewer-host-5cam.mat';
end
load(hostname);

if isManual == 1
    json_files = dir(fullfile('D:\Repository\Label3D','*_marked_frames.json'));
    json_file = json_files(1).name;
    fid = fopen(json_file);
    raw = fread(fid, inf);
    manual_frames = jsondecode(char(raw'));
    fclose(fid);
    max_frame = max(manual_frames);
end

if isCOM == 1
    load('com3d.mat')
    skeleton = load('skeletons/com');
    if max_frame > size(com,1)
        max_frame = size(com,1);
    end
    framesToLabel = start_frame:step_size:max_frame;
    data_3D = com;
else % Loading 3D data from prediction
    AVGfiles = dir(fullfile('D:\Repository\Label3D','save_data_AVG*.mat'));
    AVGfile = AVGfiles(1).name;
    load(AVGfile)
    start_sample = sampleID(1);
    skeleton = load('skeletons/rat16');
    numBodyparts = length(skeleton.joint_names);
    pred_sqz = squeeze(pred);
    data_3D = zeros(size(pred_sqz,1),3*numBodyparts);
    for j = 1:size(pred_sqz,3)
        for ok = 1:size(pred_sqz,2)
            data_3D(:,ok+3*(j-1)) = pred_sqz(:,ok,j);
        end
    end
    if max_frame > size(pred_sqz,1)
        max_frame = size(pred_sqz,1);
    end
    if isManual == 1
        framesToLabel = manual_frames';
    else
        FTL = start_frame:step_size:max_frame;
        p_max_slice = p_max(:,1,1);
        p_threshold = prctile(p_max_slice, 100*confidence_threshold);
        if isLowconf == 0
            threshold_idx_logic = (p_max_slice > p_threshold);
        else
            threshold_idx_logic = (p_max_slice < p_threshold);
        end
        p_threshold_idx = find(threshold_idx_logic);
        framesToLabel = intersect(FTL,p_threshold_idx);
        if isempty(framesToLabel)
            error("Error: No intersect found between confidence cutoff and frames to label! Readjust parameters.")
        end
    end
numFrames = length(framesToLabel);
end
data_3D = data_3D(framesToLabel,:);

status = 2*ones(1, numCam, numFrames);

framesToLabel = framesToLabel + start_sample;

handLabeled2D = NaN(numBodyparts,numCam,2,numFrames);

if isCOM ~= 1
    disp("Transformation 3D coordinates to 2D in each views...")
    X_index = 1:3:size(data_3D,2);
    for i = 1:numCam % Iterate through each camera views
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
data_3D(:,:) = NaN; % 3D data no longer needed
disp("Transformation finished!")
end

save('viewer-implanted.mat',"status","handLabeled2D","data_3D","cameraPoses","camParams","skeleton","imageSize","framesToLabel")
