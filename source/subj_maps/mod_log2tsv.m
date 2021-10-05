%%========================================
%%========================================
%%
%% Keith Bush (2020)
%% Univ. of Arkansas for Medical Sciences
%% Brain Imaging Research Center (BIRC)
%%
%%========================================
%%========================================

function [log_table] = mod_log2tsv(proj,subj_study,name,run_id)


% ----------------------------------------
% Load the top-level logfile (stims and fb trials)
stim = load_mod_logfile(proj,subj_study,name,run_id,'logfile',2);
fb = load_mod_logfile(proj,subj_study,name,run_id,'feedback',1);

log_table = table();

if(~isempty(stim) && ~isempty(fb))

    % states
    mod_state_log = table2array(stim(:,3));
    fb_state_log = table2array(fb(:,3));
    
    % times
    mod_time_log = table2array(stim(:,4));
    fb_time_log = table2array(fb(:,6));
    
    % fb values
    tcp_samples_log = table2array(fb(:,4));
    
    % set sim parameters
    max_time = mod_time_log(end);
    dt = 0.001;
    t = 0;
    Nbuff = 7;
    Tscan = 2*310;
    
    % initialize simulation of experiment
    mod_cnt = 1;
    fb_cnt = 1;
    mod_state = mod_state_log(mod_cnt);
    mod_time = mod_time_log(mod_cnt);
    fb_state = fb_state_log(fb_cnt);
    fb_time = fb_time_log(fb_cnt);
    
    mod_event = 0;
    fb_event = 0;
    
    fb_aro = []
    fb_val = []
    
    avg_aro = 0;
    avg_val = 0;
    
    first_goal = 1;
    rest_cnt = 0;
    keep_state = 1;
    show_feedback = 0;
    
    log_cnt = 1;
    trial_type = 'str';
    
    % simulate
    while(t <= (max_time+dt))
        
        %% Update mod state & time
        if(t>mod_time)
            
            mod_event = 1;
            
        end
        
        %% Update fb state & time
        if(t>fb_time)
            
            fb_event = 1;
            
        end
        
        
        if(mod_event || fb_event)
            
            
            % advance appropriate log file
            if(mod_event)
                
                if(first_goal)
                    avg_aro = 0.0;
                    avg_val = 0.0;
                end
                
                switch(mod_state)
                  case 5
                    first_goal = 1;
                    fb_aro = [];
                    fb_val = [];
                    rest_cnt = rest_cnt + 1;
                    
                    % Skip 2nd rest
                    if(rest_cnt==2)
                        keep_state = 0;
                    end
                    trial_type = 'rest';
                  case 15
                    trial_type = 'feel';
                  case 30
                    trial_type = 'finish';
                  case 60
                    trial_type = 'fb_v_pos';
                    show_feedback = 1;
                    first_goal = 0;
                  case 65
                    trial_type = 'fb_v_neg';
                    show_feedback = 1;
                    first_goal = 0;
                  case 70
                    trial_type = 'fb_a_pos';
                    show_feedback = 1;
                    first_goal = 0;
                  case 75
                    trial_type = 'fb_a_neg';
                    show_feedback = 1;
                    first_goal = 0;
                end
                
                
                if(keep_state)
                    % ----------------------------------------
                    % Output states at changepoint
                    % [mod_cnt,mod_time,mod_state,avg_aro,avg_val]                
                    trial_type_log{log_cnt} = trial_type;
                    onset_log{log_cnt} = mod_time;
                    if(show_feedback)
                        fb_val_log{log_cnt} = sprintf('%.3f',avg_val);
                        fb_aro_log{log_cnt} = sprintf('%.3f',avg_aro);
                        show_feedback=0;
                    else
                        fb_val_log{log_cnt} = 'n/a';
                        fb_aro_log{log_cnt} = 'n/a';
                    end
                    
                    log_cnt = log_cnt + 1;
                end
                
                
                %iterate
                mod_cnt = mod_cnt + 1;
                
                % record current state/time
                if(mod_cnt<=numel(mod_state_log))
                    mod_state = mod_state_log(mod_cnt);
                    mod_time = mod_time_log(mod_cnt);   
                end     
                
                % reset event
                mod_event = 0;
                keep_state = 1;
                
            else
                
                % ----------------------------------------
                % Handle processing of New TCP Sample 
                tcp_sample = tcp_samples_log(fb_cnt);
                
                aro = mod(tcp_sample,100) - 50;
                tcp_hi_order = tcp_sample - mod(tcp_sample,100);
                val = tcp_hi_order/100 - 50;
                aro = aro/50;
                val = val/50;
                
                % Preprend
                fb_aro = [aro,fb_aro];
                fb_val = [val,fb_val];
                
                % Take average of 1st Nbuff values
                if(numel(fb_aro)>Nbuff)
                    avg_aro = mean(fb_aro(1:Nbuff));
                    avg_val = mean(fb_val(1:Nbuff));
                    % Average all values (buffer not full)
                else
                    avg_aro = mean(fb_aro);
                    avg_val = mean(fb_val);
                end
                
                %iterate
                fb_cnt = fb_cnt + 1;
                
                % record current state/time
                fb_state = fb_state_log(fb_cnt);
                fb_time = fb_time_log(fb_cnt);        
                
                % reset event
                fb_event = 0;
                
            end
            
        end
        
        t = t+dt;
        
    end
    
    %construct state duration times
    for i=1:(numel(onset_log)-1)
        duration_log{i} = onset_log{i+1}-onset_log{i};
    end
    duration_log{numel(onset_log)} = Tscan-onset_log{numel(onset_log)};
    
    %format numbers
    for i=1:numel(onset_log)
        onset_log_str{i} = sprintf('%.3f',onset_log{i});
        duration_log_str{i} = sprintf('%.3f',duration_log{i});
    end
    
    
    onset = onset_log_str';
    duration = duration_log_str';
    trial_type = trial_type_log';
    fb_valence = fb_val_log';
    fb_arousal = fb_aro_log';
    log_table = table(onset,...
                      duration,...
                      trial_type,...
                      fb_valence,...
                      fb_arousal);
    
end