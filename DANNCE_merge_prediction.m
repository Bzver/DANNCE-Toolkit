clear all;

cwd = "D:\Project\SDANNCE-Models\555-5CAM\SD-20250605M\SDANNCE\predict00";
cd(cwd)

matfiles = dir("save_data_AVG*.mat");
matfiles = matfiles(~cellfun(@isempty, regexp({matfiles.name}, "save_data_AVG\d+\.mat")));
[~, sorted_idx] = sort(str2double(extractBetween({matfiles.name}, "_AVG", ".mat")));
matfiles = matfiles(sorted_idx);

for m = 1:length(matfiles)
    currentMat = load(matfiles(m).name);
    if ~exist('data','var')
        data = currentMat.data;
        p_max = currentMat.p_max;
        pred = currentMat.pred;
        sampleID = currentMat.sampleID;
    else
        data = cat(1, data, currentMat.data);
        p_max = cat(1, p_max, currentMat.p_max);
        pred = cat(1, pred, currentMat.pred);
        sampleID = cat(2, sampleID, currentMat.sampleID);
    end
end

if ~exist("merged","dir")
    mkdir("merged")
end
savename = "merged/save_data_AVG0.mat";

savedvars = ["data","p_max","pred","sampleID"];
allvars = whos;

[~, idx] = ismember(savedvars, {allvars.name});

fprintf("Successfully merged all predictions:\n")
for i = 1:length(idx)
    varInfo = allvars(idx(i));
    fprintf("%s: %s\n", varInfo.name, mat2str(varInfo.size));
end

save(savename,savedvars{:});