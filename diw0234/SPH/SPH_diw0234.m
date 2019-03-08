%%%%  SPH
clear;clc; 

% GA constructs a network
load data_diw0234;
name='SPH_Result_diw0234';
optimal=1996;  % optimal length



N=data(1,1); % vertex number
edge_num=data(2,1); 
terminal_num=data(edge_num+6,1);
foodpoint=zeros(N,1);
for i=(edge_num+7):(edge_num+terminal_num+6)
    terminal=data(i,1);
    foodpoint(terminal)=1;
end
foodnum=sum(foodpoint); 
food=zeros(foodnum,1);
r=0;
for i=1:N
      if foodpoint(i)==1
          r=r+1;
          food(r)=i;  %  the num r food is the num i vertice
      end
end

% length matrix, set matrix
set=zeros(N,N); % heuristic solution
L=zeros(N,N);%%%
for i=3:(edge_num+2)
    L(data(i,1),data(i,2))=data(i,3); L(data(i,2),data(i,1))=data(i,3);
end
SL=sparse(L);
%

tic;
include=zeros(foodnum,1);% 1 means the foodpoint is included in the solution.
initial=round(rand(1)*(foodnum-1))+1; % the starting terminal #randomness, the result depends on it
include(initial)=1;

while sum(include)<foodnum
    shortest=1e8;
    add=0; % the terminal will be added into the solution
    spath=0; % shortest path
    for i=1:foodnum
        if include(i)==0 % search outside terminals
            for j=1:foodnum
                if include(j)==1 % search inside terminals
                    [dist,path,pred]=graphshortestpath(SL,food(i),food(j));
                    if dist<shortest
                        shortest=dist;
                        clear spath;
                        spath=path;
                        add=i;
                    end
                end
            end
        end
    end
    x=size(spath);
    x=x(2);
    for i=1:(x-1)
        set(spath(i),spath(i+1))=1;set(spath(i+1),spath(i))=1;
    end
    include(add)=1;
end

solution=0;
for i=1:N
    for j=i:N
        if set(i,j)==1
            solution=solution+L(i,j);
        end
    end
end
Time=toc
ratio=(solution-optimal)/optimal*100; % percentage

fprintf(['Deviation= ',num2str(ratio)])
fprintf('\n')

save(name);












