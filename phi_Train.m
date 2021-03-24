clear;

InitBreach;

k=0.1;
c=8;

num_train = 9;

addpath model/
addpath spec/

mdl = 'Train';
Br = BreachSimulinkSystem(mdl);

Br.Sys.tspan = 0:.01: 50;

input_gen.type = 'UniStep';
input_gen.cp = 10;
Br.SetInputGen(input_gen);

%for nsi = 1:num_train
%    Br.SetParam(strcat('M_', num2str(nsi)), 80);
%end

for nsi = 1:num_train
    Br.SetParamRanges(strcat('M_', num2str(nsi)), [80 120]);
end

for cpi = 0:input_gen.cp-1
    u_sig = strcat('u_u', num2str(cpi));
    Br.SetParamRanges({u_sig},[-20 20]);
end

phi = STL_Formula('phi1','alw_[0,50](Z_1[t] > Z_2[t] and Z_2[t] > Z_3[t] and Z_3[t] > Z_4[t] and Z_4[t] > Z_5[t] and Z_5[t] > Z_6[t]) and Z_6[t] > Z_7[t] and Z_7[t] > Z_8[t]');

IterNum = 1;

total_time = 0.0;
succ_iter = 0;
succ_trial = 0;
obj_best = [];
num_sim = [];

for n = 0:IterNum-1
    
    falsif_pb = FalsificationProblem(Br, phi);
    falsif_pb.max_time = 200;
    %falsif_pb.max_obj_eval = 20;
    falsif_pb.setup_solver('cmaes');
    falsif_pb.solve();
    
    
    if falsif_pb.obj_best < 0
       total_time = total_time + falsif_pb.time_spent;
       succ_iter = succ_iter + falsif_pb.nb_obj_eval;
       succ_trial = succ_trial + 1; 
    end
    obj_best = [obj_best; falsif_pb.obj_best]
    num_sim = [num_sim; falsif_pb.nb_obj_eval]
    
    
end

aver_time = total_time/succ_trial
aver_succ_iter = succ_iter/succ_trial
succ_trial

