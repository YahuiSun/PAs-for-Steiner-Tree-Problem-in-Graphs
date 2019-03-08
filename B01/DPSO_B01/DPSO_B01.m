clc;clear;

load data_b01;
name='DPSO_B01';
optimal=82;  %%% optimal length

N=data(1,1); % vertex number
edge_num=data(2,1); 
terminal_num=data(edge_num+6,1);
foodpoint=zeros(N,1);
for i=(edge_num+7):(edge_num+terminal_num+6)
    terminal=data(i,1);
    foodpoint(terminal)=1;
end
foodnum=sum(foodpoint); 

success=0; %%% success time
solution=optimal+1;


L=zeros(N,N);%%%
for i=3:(edge_num+2)
    L(data(i,1),data(i,2))=data(i,3); L(data(i,2),data(i,1))=data(i,3);
end
totalL=sum(sum(L))/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initial parameter
Dim=N-foodnum; % particle dimension
xSize=10;% population size 
R=2; % radius of neighbourhood
% c1=0.2; % parameter_previous best? used in the velocity function
% c2=0.5; % parameter_neighbourhood best
% c3=0.9; % parameter_global best
w=0.9; % velocity parameter  better to be a little smaller than 1
p=1e6;
% 
x=round(rand(xSize,Dim));% initial position of particles
v=rand(xSize,Dim);% initial velocity 
vmax=10; % limitation of v
xbest=zeros(xSize,Dim);% the previous best positions of particles
fxbest=p*ones(xSize,1);% the value of xbest
gbest=zeros(1,Dim);% the ever best position of the population
fgbest=p;% value of gbest
nbest=zeros(xSize,Dim); % the ever best position of the neighbourhood
fnbest=p*ones(xSize,1);% value of nbest
%
% iteration:
tic;
iter=0;
fe_PSO=0; % function evalution
while success==0
    iter=iter+1;
    y=value(foodpoint,L,x);% particle values (total length of tree, the smaller the better)
    for i=1:xSize
        if fxbest(i)>y(i)
            fxbest(i)=y(i);
            xbest(i,:)=x(i,:); 
        end % update the previous best positions and values of particles
    end
    if fgbest>min(fxbest)
        [fgbest,g]=min(fxbest);
        gbest=xbest(g,:);% update the ever best position and value of the population
    end
    GBEST(iter)=fgbest; % global best
    for i=1:xSize
        for j=1:xSize
            m=abs(i-j);
            if m>=1 & m<=R  % neighbourhood
                if fxbest(j)<fnbest(i)
                    fnbest(i)=fxbest(j);
                    nbest(i,:)=xbest(j,:);
                end
            elseif m>=xSize-R-2 & m<=xSize-1 % neighbourhood
                if fxbest(j)<fnbest(i)
                    fnbest(i)=fxbest(j);
                    nbest(i,:)=xbest(j,:);
                end
            end
        end
    end
    for i=1:xSize
        if x(i,:)==nbest(i,:)
            if rand(1)>0.9 % how often is the mutation
                x(i,:)=round(rand(1,Dim));% randomly change the position of particle which locates in the best ever position of the whole population.
            end
        end % this randomness is to prevent the optimization from lingering in a local-optima position 
    end
    v=v*w+rand().*(xbest-x)+rand().*(nbest-x)+rand().*(repmat(gbest,xSize,1)-x);% velocity
    for i=1:xSize
        for j=1:Dim
            if v(i,j)>vmax
                v(i,j)=vmax;
            elseif v(i,j)<-vmax
                v(i,j)=-vmax;
            end
            if rand(1)<1/(1+exp(-v(i,j))) % Sigmoid function
                x(i,j)=1;
            else 
                x(i,j)=0;
            end
        end
    end
    
    fe_PSO=fe_PSO+1; % function evalution
    if fgbest>totalL
        fit_PSO(fe_PSO)=totalL; % fitness
    else
        fit_PSO(fe_PSO)=fgbest; % fitness
    end
    
    fgbest
%     min_now=min(fxbest)
    
    if fgbest==optimal
        success=1;
    end
end
time=toc
save(name);  %%%%  save data
% 
% analysis
% Highest_value=fgbest
% Best_position=gbest

% plot(1:MaxIt,GBEST)
% grid on;
