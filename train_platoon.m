function [V,dis]=train_platoon()
%init
target=350;
V = 350.0 * ones(1,4);
dis=6.5 * ones(1,4);
m=100 * ones(1,4);
target_speed=350 * ones(1,4);
dis(1,1)=300;
breaking_dis=6.5;
A=1.5;
B=-1.5;
h=0.05;
k=0.1;
c=8;
%acc=1,dec=0
act=0;
%comp
fprintf('%d %d %d %d \n',V(1,1),V(1,2),V(1,3),V(1,4));
while(true)
%leader
dis(1,1)=leader_dis(V(1,1),dis(1,1));
V(1,1)=leader_v(V(1,1),act,dis(1,1),breaking_dis,A,B,h,target,target_speed(1,1));
%second
dis(1,2)=singaltrain_dis(dis(1,2),V(1,1),V(1,2));
V(1,2)=singaltrain_v(6.5,dis(1,2),V(1,1),V(1,2),m(1,1),m(1,2),k,c);
%other
dis(1,3)=singaltrain_dis(dis(1,3),V(1,2),V(1,3));
V(1,3)=singaltrain_v(dis(1,2),dis(1,3),V(1,2),V(1,3),m(1,2),m(1,3),k,c);
dis(1,4)=singaltrain_dis(dis(1,4),V(1,3),V(1,4));
V(1,4)=singaltrain_v(dis(1,3),dis(1,4),V(1,3),V(1,4),m(1,3),m(1,4),k,c);
fprintf('%f %f %f %f \n',V(1,1),V(1,2),V(1,3),V(1,4));
fprintf('%f %f %f %f \n',dis(1,1),dis(1,2),dis(1,3),dis(1,4));
%fprintf('%f %f \n',V(1,1),target_speed(1,1));
pause(1);
end
end

function [v]=leader_v(v,act,dis,breaking_dis,A,B,h,target,target_speed)
%global target;
if(dis>breaking_dis)
    target_speed=target;
else
    target_speed=target_speed_com(target_speed,dis,breaking_dis,target);
end
if(act==1)
    v=v+((target_speed-v)/3600)*A-h;
else if(act==0)
    v=v+((target_speed-v)/3600)*B-h;
    end
end
if(v>=350)
    v=350;
end
if(v<=0)
    v=0;
end
end

function [dis]=leader_dis(v,dis)
dis=dis-v/3600;
end

function [target_speed]=target_speed_com(target_speed,dis,breaking_dis,target)
if(dis>breaking_dis)
    target_speed=target;
else
    target_speed=target_speed-(target_speed*target_speed)/(dis*2);
end
end

function [v] = singaltrain_v(x_p,x,v_p,v,m_p,m,k,c)%列车速度计算
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
v=v+(k/m_p)*x_p-(k/m)*x+(c/m_p)*v_p-(c/m)*v;
if(v>350)
    v=350;
end
if(v<=0)
    v=0;
end
end

function [dis]=singaltrain_dis(dis,v_p,v)
dis=dis+(v-v_p)/3600;
end

