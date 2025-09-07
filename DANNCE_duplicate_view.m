clear all;

folder = "SD-20250605M-4cam";
cwd = "D:\Project\SDANNCE-Models\4CAM-3D-2ETUP\"+folder;
cd(cwd)

%%

finalViews = 4;

%%

if ~isnumeric(finalViews)
    error('Input argument finalViews must be numeric.');
end

matfiles = dir('*_dannce.mat');

for m = 1:length(matfiles)
    matname = matfiles(m).name;
    currentmat = load(matname);
    curmatvars = fieldnames(currentmat);
    isDannce = ismember('labelData', curmatvars);
    if isDannce
        initialViews = length(currentmat.camnames);
        if initialViews > finalViews
            camnames = currentmat.camnames(1,1:finalViews);
            handLabeled2D = currentmat.handLabeled2D(:,1:finalViews,:,:);
            labelData = currentmat.labelData(1:finalViews,1);
            params = currentmat.params(1:finalViews,1);
            sync = currentmat.sync(1:finalViews,1);
        elseif initialViews < finalViews
            disp("2 B implemented LOL")
        else
            disp("wat")
        end
        save(matname,"camnames","handLabeled2D","labelData","params","sync");
        disp(matname+" saved!")
    end
end
