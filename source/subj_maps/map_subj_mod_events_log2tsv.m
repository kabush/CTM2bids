%%========================================
%%========================================
%%
%% Keith Bush, PhD (2020)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%% Co-authors: Ivan Messias (2019)
%%             Kevin Fialkowski (2019)
%%
%%========================================
%%========================================

%% Initialize log section
logger(['************************************************'],proj.path.logfile);
logger([' Map Subj-level Modulate Event files from Logs  '],proj.path.logfile);
logger(['************************************************'],proj.path.logfile);

%% ========================================
%% This script merges three independent logs created
%% during the CTM real-time processing.
%% ========================================

%% Load in path data
load('proj.mat');

%% Create the subjects to be analyzed (possible multiple studies)
subjs = load_subjs(proj);

%% Load subject design info 
subj_dsgn = [proj.path.design,'CTM_subjs.csv'];

%% ========================================
%% Preprocess fMRI of each subject in subjects list 
%% ========================================
for i = 1:numel(subjs)

    %%  Assign file paths
    design_path = proj.path.mod_design;  %raw design
    log_path = proj.path.log;  %log
    tmp_path = [proj.path.code,'tmp/'];
    
    %% extract subject info
    subj_study = subjs{i}.study;
    name = subjs{i}.name;

    %% ========================================
    %% Run 1
    %% ========================================
    run_id = 1;
    logger([subj_study,':',name,' (Run ',num2str(run_id),')'],proj.path.logfile);

    %% Call mod_log2tsv (as in the id but pass in the design loaded above) 
    [mod1_log_table] = mod_log2tsv(proj,subj_study,name,run_id);
    file_name = ['sub-',name,'_task-modulate1_events.tsv'];
    func_path = [proj.path.data,'sub-',name,'/func/'];
    writetable(mod1_log_table,fullfile(func_path,file_name),'FileType','text','Delimiter','\t');

    %% ========================================
    %% Run 2
    %% ========================================
    run_id = 2;
    logger([subj_study,':',name,' (Run ',num2str(run_id),')'],proj.path.logfile);

    %% Call mod_log2tsv (as in the id but pass in the design loaded above) 
    [mod2_log_table] = mod_log2tsv(proj,subj_study,name,run_id);
    mod2_log_table
    if(~isempty(mod2_log_table))
        
        file_name = ['sub-',name,'_task-modulate2_events.tsv'];
        func_path = [proj.path.data,'sub-',name,'/func/'];
        writetable(mod2_log_table,fullfile(func_path,file_name),'FileType','text','Delimiter','\t');
        
    end

end


