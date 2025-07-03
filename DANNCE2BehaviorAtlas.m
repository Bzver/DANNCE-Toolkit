clear all;

filepath = "D:\Project\SDANNCE-Models\555-5CAM\SD-20250605B\DANNCE\predict00\merged";

cd(filepath)
load("save_data_AVG0.mat")
expression = 'SD-([^\\]+)';
tokens = regexp(filepath, expression, 'tokens');
if isempty(tokens)
    tokens = "demo";
end
newfilename = "SD-"+ tokens +"_Data3d.mat";

frames = size(pred,1);
bodyparts = size(pred,4);
coords3d = NaN(frames,3*bodyparts);

for i = 1:bodyparts
    for k = 1:3
        coords3d(:,(i-1)*3+k) = pred(:,1,k,i);
    end
end

save(newfilename,"coords3d")