clear all;

cd 'D:\Repository\Label3D'
%%
ChosenOne = '20250526_224308_Label3D.mat';
skeletonFile = 'skeletons/rat16';
framesToLabel = 1:100:29998;
numCam = 5;

isChosenOne = 0;
isFinetuning = 0;
isConserveData = 0;

%%
if isChosenOne == 1
    hostname = ChosenOne;
elseif isFinetuning == 1
    hostname = 'viewer-implanted.mat';
elseif numCam == 4
    hostname = 'viewer-host.mat';
elseif numCam == 5
    hostname = 'viewer-host-5cam.mat';
end

load(hostname);

skeleton = load(skeletonFile);

numFrames = length(framesToLabel);
numBodyparts = length(skeleton.joint_names);

data_2D = zeros(numFrames, 2*numBodyparts, numCam);
data_2D_index = [2:3:3*numBodyparts+1 3:3:3*numBodyparts+1];
data_2D_index = sort(data_2D_index);

for i = 1:numCam
    fileName = sprintf('cam%d.csv', i);
    if isfile(fileName)
        fprintf('Reading %s...\n', fileName);
        cur_cam_data = readmatrix(fileName);
        cur_cam_data_filtered = cur_cam_data(framesToLabel,data_2D_index);
        data_2D(:, :, i) = cur_cam_data_filtered;
    else
        fprintf('%s... not found, skipping\n', fileName);
    end
end
data_2D_permute = permute(data_2D, [2,3,1]);
data_2D_x = data_2D_permute(1:2:end,:,:);
data_2D_y = data_2D_permute(2:2:end,:,:);
data_2D_final = zeros(numBodyparts, numCam, 2, numFrames);
data_2D_final(:, :, 1, :) = data_2D_x;
data_2D_final(:, :, 2, :) = data_2D_y;
handLabeled2D = data_2D_final;
data_3D_labelled = data_3D(~all(isnan(data_3D), 2), :);
data_3D_new = NaN(numFrames,3*numBodyparts);

if length(data_3D_labelled) ~= numFrames
    if isConserveData == 1 && isChosenOne == 1
        data_3D_new(1:size(data_3D_labelled,1),:) = data_3D_labelled;
        print('Original 3D data conserved.')
    end
end

data_3D = data_3D_new;
status = 2*ones(1, numCam, numFrames);

save('viewer-implanted.mat',"status","handLabeled2D","data_3D","cameraPoses","camParams","skeleton","imageSize","framesToLabel")