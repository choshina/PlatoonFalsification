clear;

%addpath(genpath(...)) %the path of Breach
InitBreach;


%% Configurable parameters
k=0.1;
c=8;

% initial position of each train, X0_1 = 0;
% the number of X0 should be consistent with num_train
X0_2 = -10;
X0_3 = -25;
X0_4 = -44.8;
X0_5 = -69.2;


% mass of each train. 
% the number of M should be consistent with num_train
M_1 = 1000;
M_2 = 1000;
M_3 = 1000;
M_4 = 1000;
M_5 = 1000;


num_train = 5; % one out of [5, 10, 15, 20]
fixedM = true; % if true, M is fixed; otherwise M is within a range


Mrange = [1000 1200]; % the range of M
Urange = [-1 1]; % the range of U for lead train

%%
cpt = 10;

max_trials = 10;

addpath model/
addpath spec/

mdl = strcat('Train', num2str(num_train));
Br = BreachSimulinkSystem(mdl);

Br.Sys.tspan = 0:.01:50;

input_gen.type = 'UniStep';
input_gen.cp = cpt;
Br.SetInputGen(input_gen);


if fixedM == true
    for nsi = 1:num_train
        Br.SetParam(strcat('M_', num2str(nsi)), Mrange(1));
    end
else
    for nsi = 1:num_train
        Br.SetParamRanges(strcat('M_', num2str(nsi)), Mrange);
    end
end


for cpi = 0:input_gen.cp-1
    u_sig = strcat('u_u', num2str(cpi));
    Br.SetParamRanges({u_sig}, Urange);
end



for i = 1:3
    
    stlid = strcat('train', num2str(num_train), num2str(i));
    stlf = strcat('spec/', stlid, '.stl');
    STL_ReadFile(stlf);
    

    succ = [];
    obj_best = [];
    num_sim = []; 
    total_time = [];
    counts = [];
    
    cnt = 0;
    time = 0;
    sims = 0;
    while true
        cnt = cnt + 1;
        
        falsif_pb = FalsificationProblem(Br, eval(strcat('tr', num2str(num_train), num2str(i))));
        falsif_pb.max_time = 200;
        falsif_pb.setup_solver('cmaes');
        falsif_pb.solver_options.Seed = round(rem(now,1)*1000000);
        falsif_pb.solve();

        time = time + falsif_pb.time_spent;
        sims = sims + falsif_pb.nb_obj_eval;
        if falsif_pb.obj_best < 0
           succ = [succ; 1];
           counts = [counts; c];
           num_sim = [num_sim; sims];
           total_time = [total_time; time];
           break;
        end
        
        if cnt == max_trials
            succ = [succ; 0];
            counts = [counts; -1];
            num_sim = [num_sim; sims];
            total_time = [total_time; time];
            break;
        end
    end
    res = table(succ, counts, num_sim, total_time);
    filename =  strcat('results/', mdl, '_', stlid, '_', fixed(fixedM), '_', to_str(Mrange), '_', to_str(Urange), '_',  num2str(cpt), '.csv');
    writetable(res, filename,'Delimiter',';');
end

function str = to_str(r)
    str = strcat(num2str(r(1)), 'w', num2str(r(2)));
end

function str = fixed(f)
    if f
        str = 'fixed';
    else
        str = 'unfixed';
    end
end
