clear all;
dataDir = 'D:\Repository\Label3D';

%%
isDuplicate = 0;
isPointDuplicate = 0;
isEraser = 0;
isDestroyer = 1; % WARNING!!! BACKUP BEFORE USING!!!
isPointDestroy = 0;

%%
matFiles = dir(fullfile(dataDir, '*_Label3D.mat'));
if isempty(matFiles)
    error('No .mat files with the pattern *_Label3D.mat found in the specified directory.');
end

fileDates = NaT(length(matFiles), 1); % Initialize an array of Not-a-Time
filenameFormat = 'yyyyMMdd_HHmmss'; % Format of the date/time in your filename
for i = 1:length(matFiles)
    fileName = matFiles(i).name;
    try
        underscoreIdx = strfind(fileName, '_');
        if length(underscoreIdx) >= 2
            dateTimeStr = fileName(1 : underscoreIdx(2)-1);
            fileDates(i) = datetime(dateTimeStr, 'InputFormat', filenameFormat);
        else
            warning(['Could not parse date from filename: ', fileName]);
        end
    catch ME
        warning(['Error parsing date from filename: ', fileName, ' - ', ME.message]);
        fileDates(i) = NaT;
    end
end
[~, newestIdx] = max(fileDates);
newestFileName = fullfile(dataDir, matFiles(newestIdx).name);
load(newestFileName);
disp("Loading "+string(matFiles(newestIdx).name))

%%
if isDuplicate == 1
    fromFrame = floor(input('Enter the frame number you want to copy FROM: '));
    if isPointDuplicate == 0
        startFrame = floor(input('Enter the start of the frames you want to copy To: '));
        endFrame = floor(input('Enter the last of the frames you want to copy To: '));
        if startFrame <= 0
            startFrame = 1;
        end
        if endFrame > size(data_3D,1)
            endFrame = size(data_3D,1);
        end
        if startFrame >= endFrame
            error("Error: start frame needs to be smaller than end frame.")
        else
            data_3D(startFrame:endFrame,:) = repmat(data_3D(fromFrame, :),endFrame-startFrame+1,1);
            save(newestFileName, 'camParams', 'cameraPoses', 'data_3D', 'imageSize', 'skeleton', 'status', "handLabeled2D","framesToLabel");
        end
    else
        toFrame = floor(input('Enter the frame number you want to copy TO: '));
        if fromFrame >= 1 && fromFrame <= size(data_3D, 1) && ...
                toFrame >= 1 && toFrame <= size(data_3D, 1)
            data_3D(toFrame, :) = data_3D(fromFrame, :);
            disp(['Successfully copied frame ', num2str(fromFrame), ' of data_3D to frame ', num2str(toFrame), '.']);
        else
            disp('Error: Invalid frame number(s) for data_3D. Please ensure they are within the data range.');
        end
        if fromFrame >= 1 && fromFrame <= size(status, 3) && ...
                toFrame >= 1 && toFrame <= size(status, 3)
            status(:, :, toFrame) = status(:, :, fromFrame);
            disp(['Successfully copied frame ', num2str(fromFrame), ' of status to frame ', num2str(toFrame), '.']);
        else
            disp('Error: Invalid frame number(s) for status. Please ensure they are within the data range.');
        end
    end
    save(newestFileName, 'camParams', 'cameraPoses', 'data_3D', 'imageSize', 'skeleton', 'status', "handLabeled2D","framesToLabel");
elseif isEraser == 1
    startFrame = input('Enter the start of the frames you wish to erase: ');
    endFrame = input('Enter the end of the frames you wish to erase: ');
    if startFrame <= 0
        startFrame = 1;
    end
    if endFrame > size(data_3D,1)
        endFrame = size(data_3D,1);
    end
    if startFrame >= endFrame
        error("Error: start frame needs to be smaller than end frame.")
    else
        data_3D(startFrame:endFrame,:) = NaN;
        save(newestFileName, 'camParams', 'cameraPoses', 'data_3D', 'imageSize', 'skeleton', 'status', "handLabeled2D","framesToLabel");
    end
elseif isDestroyer == 1
    if isPointDestroy == 0
        lastofFrame = floor(input('Enter the end of the frames you wish NOT to destroy: '));
        if lastofFrame > 1
            confirmation = input("About to destroy "+string(lastofFrame+1)+" frame onwards, confirm?( Type 'CONFIRM' to confirm )", 's');
            if strcmp(confirmation, 'CONFIRM')
                data_3D = data_3D(1:lastofFrame,:);
                status = status(:,:,1:lastofFrame);
                framesToLabel = framesToLabel(1:lastofFrame);
                handLabeled2D = handLabeled2D(:,:,:,1:lastofFrame);
                disp("Data after "+string(lastofFrame)+" frame are destroyed.")
                save(newestFileName, 'camParams', 'cameraPoses', 'data_3D', 'imageSize', 'skeleton', 'status', "handLabeled2D", "framesToLabel");
            else
                disp("Confirmation negative, mission aborted.")
            end
        else
            error("Error: illegal values in for lastofFrame.")
        end
    else
        killFrame = floor(input('Enter the the exact frame you wish to destroy: '));
        if 0 < killFrame && killFrame <= size(data_3D,1)
            confirmation = input("About to destroy frame"+string(killFrame)+", confirm?( Type 'CONFIRM' to confirm )", 's');
            if strcmp(confirmation, 'CONFIRM')
                data_3D(killFrame,:) = [];
                framesToLabel(killFrame) = [];
                handLabeled2D(:,:,:,killFrame) = [];
                status(:,:,killFrame) = [];
                disp("Frame "+string(killFrame)+"  is destroyed.")
                save(newestFileName, 'camParams', 'cameraPoses', 'data_3D', 'imageSize', 'skeleton', 'status', "handLabeled2D", "framesToLabel");
            else
                disp("Confirmation negative, mission aborted.")
            end
        else
            error("Error: illegal values in for lastofFrame.")
        end
    end
else
    disp("No changes have been made.")
end