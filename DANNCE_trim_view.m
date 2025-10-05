clear all;

folder = "SD-20250910-c55toe1-5cam";
cwd = "D:\Project\SDANNCE-Models\666-6CAM\"+folder;
cd(cwd)

%%
finalViews = 5;
excludedViews = 5;

%%

if ~isnumeric(finalViews)
    error('Input argument finalViews must be numeric.');
end

if ~isvector(excludedViews) || ~isnumeric(excludedViews) || any(excludedViews <= 0)
    error('excludedViews must be a vector of positive integers.');
end

matfiles = dir('*_dannce.mat');

if isempty(matfiles)
    warning('No *_dannce.mat files found in folder.');
    return;
end

for m = 1:length(matfiles)
    matname = matfiles(m).name;
    fprintf('Processing: %s\n', matname);

    currentmat = load(matname);
    curmatvars = fieldnames(currentmat);
    isDannce = ismember('labelData', curmatvars);
    initialViews = length(currentmat.camnames);

    if initialViews < finalViews
        error('File %s has only %d views, but finalViews = %d. Cannot reduce further.', ...
              matname, initialViews, finalViews);
    end

    if isempty(excludedViews)
        viewsToKeep = 1:finalViews;
    else
        allViews = 1:initialViews;
        allViews(excludedViews) = [];
        viewsToKeep = allViews;
    end

    camnames = currentmat.camnames(1,1:length(viewsToKeep));
    params = currentmat.params(viewsToKeep,1);
    sync = currentmat.sync(viewsToKeep,1);

    if isDannce
        handLabeled2D = currentmat.handLabeled2D(:,viewsToKeep,:,:);
        labelData = currentmat.labelData(viewsToKeep,1);
    end

    if isDannce
        save(matname,"camnames","handLabeled2D","labelData","params","sync");
    else
        save(matname,"camnames","params","sync");
    end
    fprintf('%s saved!\n', matname)

end
