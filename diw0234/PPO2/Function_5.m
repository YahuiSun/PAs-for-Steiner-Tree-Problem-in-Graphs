%%%%  SPH function
function [solution,set]=Function_5(newN,newset,newL,new_foodpoint)





N=newN; % vertex number
 
terminal_num=sum(new_foodpoint);
foodpoint=new_foodpoint;
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
L=zeros(N,N);
for i=1:N
    for j=1:N
        L(i,j)=newset(i,j)*newL(i,j);
    end
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















