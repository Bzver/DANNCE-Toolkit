clear all;

folder = "D:\Project\SDANNCE-Models\555-5CAM\SD-20250605M";

%%

files = dir(fullfile(folder, '*_Label3D_dannce.mat'));
matfiles = {files.name};

for k = 1:length(matfiles)
    matfile = fullfile(folder, matfiles{k});
    load(matfile);
    
    [rows, cols] = size(labelData{1}.data_3d);
    bp = cols / 3;
    
    COM = nan(rows,3);
    for i = 1:3  % data_3d is (x1, x2, x3, x4, y1, ..., z1, z2, z3, z4)
        COM(:, i) = mean(labelData{1}.data_3d(:, bp*(i-1)+1:bp*i), 2);
    end
    
    for i = 1:length(labelData)
        labelData{i}.data_3d = COM;
    end
    
    save(matfile.replace("_Label3D_dannce", "_COM_dannce"), "camnames", "labelData", "params", "sync")
    disp("Successful processed " + matfile)
end