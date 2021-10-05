%%========================================
%%========================================
%%
%% Keith Bush, PhD (2020)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%%========================================
%%========================================


%% Load in path data
load('proj.mat');

%% Initialize log section
logger(['************************************************'],proj.path.logfile);
logger([' Characterizing Age|Sex|Task Design|Params of Subjects'],proj.path.logfile);
logger(['************************************************'],proj.path.logfile);

%% ----------------------------------------
%% load subjs
subjs = load_subjs(proj);

participant_id = cell(numel(subjs),1);
age = cell(numel(subjs),1);
sex = cell(numel(subjs),1);
group = cell(numel(subjs),1);
design = cell(numel(subjs),1);
mod1 = cell(numel(subjs),1);
mod2 = cell(numel(subjs),1);
sham_rpt = cell(numel(subjs),1);
sham_cnf = cell(numel(subjs),1);
zemg = cell(numel(subjs),1);
resp = cell(numel(subjs),1);
error = cell(numel(subjs),1);

%% ----------------------------------------
%% iterate over study subjects
for i = 1:numel(subjs)

    %% extract subject info
    subj_study = subjs{i}.study;
    name = subjs{i}.name;
    id = subjs{i}.id;

    %% debug
    logger([subj_study,':',name],proj.path.logfile);

    try

        %% Load subject's sex, group, and coding error information
        demo = readtable([proj.path.raw_data,proj.path.demo,'/',subj_study,'.csv']);
        id = find(strcmp(demo.ID,name)~=0);
        participant_id{i} = name;
        age{i} = demo.Age(id);
        if(demo.Type(id)==1)
            sex{i} = 'M';
        else
            sex{i} = 'F';
        end
        group{i} = 'control';


    catch 
        disp(['  Error: could not load file(s)']);
    end

    %% load file for sham/norm determination
    file = [proj.path.design,'CTM_subjs.csv'];
    subj_table = readtable(file);
    
    id_str = [subj_study,'_',name];
    subj_row = subj_table(strcmp(subj_table.ID,id_str),:);
    
    design{i} = char(subj_row.Dsgn);
    mod1{i} = char(subj_row.Run1);
    mod2{i} = char(subj_row.Run2);
    sham_rpt{i} = num2str(subj_row.A1);
    sham_cnf{i} = num2str(subj_row.A2);
    zemg{i} = num2str(subj_row.zEMG);
    resp{i} = num2str(subj_row.Resp);
    error{i} = num2str(subj_row.Err);

end

result = table(participant_id,age,sex,group,design,mod1,mod2,sham_rpt,sham_cnf,zemg,resp,error);

path = [proj.path.data];
filename = 'participants.tsv';
writetable(result,fullfile(path,filename),'FileType','text','Delimiter','\t');


