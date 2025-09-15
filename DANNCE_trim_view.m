clear all;

folder = "SD-20250910-c55toe1-4cam";
cwd = "D:\Project\SDANNCE-Models\666-6CAM\"+folder;
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
    initialViews = length(currentmat.camnames);
    if initialViews > finalViews
        camnames = currentmat.camnames(1,1:finalViews);
        params = currentmat.params(1:finalViews,1);
        sync = currentmat.sync(1:finalViews,1);
        if isDannce
            handLabeled2D = currentmat.handLabeled2D(:,1:finalViews,:,:);
            labelData = currentmat.labelData(1:finalViews,1);
        end
    else
        disp("Unimplemented")
    end
    if isDannce
        save(matname,"camnames","handLabeled2D","labelData","params","sync");
    else
        save(matname,"camnames","params","sync");
    end
    disp(matname+" saved!")

end
