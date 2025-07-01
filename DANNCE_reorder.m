clear all;

cd('D:\Project\SDANNCE-Models\20250526')
newOrder = struct('K',1,'RDistort',1,'TDistort',1,'r',1,'t',1);

matfiles = dir('*.mat');
for m = 1:length(matfiles)
    matname = matfiles(m).name;
    currentmat = load(matname);
    curmatvars = fieldnames(currentmat);
    isDannce = ismember('camnames', curmatvars);
    if isDannce
        camNum = length(currentmat.camnames);
        for i = 1:camNum
            currentmat.params{i} = orderfields(currentmat.params{i},newOrder);
        end
        save(matname, '-struct', 'currentmat');
    end
end