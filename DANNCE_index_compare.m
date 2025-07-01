clear all

folder = "SD-20250605B";

cd("D:\Project\SDANNCE-Models\555-5CAM\" + folder)
fname = "SDANNCE\predict00\vis\frame0-29999_Camera1,2,3,4_marked_frames.json";

load(folder + ".mat")
sampleID = labelData{1}.data_sampleID;

fid = fopen(fname);
raw = fread(fid, inf);
data = jsondecode(char(raw'));
fclose(fid);

redundant_idx = NaN(1,length(sampleID));
for i = 1:length(sampleID)
    if ismember(sampleID(i),data)
        redundant_idx(i) = sampleID(i);
    end
end
redundant_idx = rmmissing(redundant_idx);

