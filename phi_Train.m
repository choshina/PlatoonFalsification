clear;

InitBreach;

k=0.1;
c=8;

num_train = 5;
fixedM = true;

cpt = 10;
Mrange = [800 1200];
Urange = [-80 80];
%X0basis = [8.5 3]; %compute x0

max_trials = 1;

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

%xtmp = 0 - X0basis(1);
%for xi = 2:num_train
%    Br.SetParam(strcat('X0_', num2str(xi)), xtmp);
%    xtmp = 2*xtmp - X0basis(2);
%end


for cpi = 0:input_gen.cp-1
    u_sig = strcat('u_u', num2str(cpi));
    Br.SetParamRanges({u_sig}, Urange);
end



for i = 2:2
    
    stlid = strcat('train', num2str(num_train), num2str(i));
    stlf = strcat('spec/', stlid, '.stl');
    STL_ReadFile(stlf);
    %phi = STL_Formula('phi1','alw_[0,50](Z_1[t] > Z_2[t] and Z_2[t] > Z_3[t] and Z_3[t] > Z_4[t] and Z_4[t] > Z_5[t] and Z_5[t] > Z_6[t]) and Z_6[t] > Z_7[t] and Z_7[t] > Z_8[t]');

    

    succ = [];
    obj_best = [];
    num_sim = []; 
    total_time = [];
    counts = [];
    
    c = 0;
    time = 0;
    sims = 0;
    while true
        c = c + 1;
        
        falsif_pb = FalsificationProblem(Br, eval(strcat('tr', num2str(num_train), num2str(i))));
        falsif_pb.max_time = 200;
        falsif_pb.setup_solver('cmaes');
        falsif_pb.solve();

        time = time + falsif_pb.time_spent;
        sims = sims + falsif_pb.nb_obj_eval;
        if falsif_pb.obj_best < 0
           succ = [succ; 1];
           counts = [counts; c];
           %obj_best = [obj_best; falsif_pb.obj_best];
           num_sim = [num_sim; sims];
           total_time = [total_time; time];
           break;
        end
        
        if c == max_trials
            succ = [succ; 0];
            counts = [counts; -1];
            %obj_best
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
