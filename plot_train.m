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
M = [800 800 800 800 800];
U = [0.5 0.5 0.5 0.5 0.5 0.8 0.8 0.8 0.8 -0.8];


num_train = 5; % one out of [5, 10, 15, 20]


%%
cpt = 10;


addpath model/
addpath spec/

for nsi = 1:num_train
    eval(strcat('M_', num2str(nsi), '=', num2str(M(nsi))));
end

mdl = strcat('Train', num2str(num_train));
Br = BreachSimulinkSystem(mdl);

Br.Sys.tspan = 0:.01:50;

input_gen.type = 'UniStep';
input_gen.cp = cpt;
Br.SetInputGen(input_gen);



%for nsi = 1:num_train
%    Br.SetParam(strcat('M_', num2str(nsi)), M(nsi));
%end

for cpi = 0:cpt - 1
    u_sig = strcat('u_u', num2str(cpi));
    Br.SetParam({u_sig}, U(cpi + 1));
end

    
stlid = 'train52';
stlidid = 'tr52';
stlf = strcat('spec/', stlid, '.stl');
STL_ReadFile(stlf);



    
Br.Sim(0:.01:50);

robust = Br.CheckSpec(eval(stlidid))

Br.PlotSignals();

%Br.PlotRobustSat(phi,3);
