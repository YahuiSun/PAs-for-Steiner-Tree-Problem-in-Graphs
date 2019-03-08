% Input: a graph described by distance matrix. 
% Output: several partition graphs described by distance matrix.
clear all; clc;


vertex2vertex=0; % 1 means this partition process will calculate the shortest path from vertex to vertex, 0 means terminal to terminal
add_SP=1; % 1 means it will add the shortest path when merging 2 subsets

TARGET=5; % target partition number  the result may be bigger or smaller, but it can't be bigger than terminal_num
d=1.5; % partition imbalance parameter 
% notes
% it's better to part graph into 100-vertex graphs. Large graph needs special PO parameters  
% end


load data_diw0234;  % input_graph
name='diw0234';




M=1e7; % big value
[N,edge_num,terminal_num,vertex,terminal,L,set]=Function_3(data,M); % make graph 
% vertex=zeros(N,1); % 1 means it's terminal, 0 means not
% terminal(r)=i;  % the num r terminal is the num i vertice


tic;
% initial partition: one terminal to one subset
include=zeros(N,1); % 1 means this vertex is already in the partition
part=terminal_num; % partition number
PV=ones(part,1); % vertex number in each part.
map=zeros(part,1); % decide the included vertex's place in the inital graph
for i=1:terminal_num
    map(i,1)=terminal(i); % the 1st vertex in part i is the vertex terminal(i) in the inital graph
    include(terminal(i))=1; % all terminals have been included to the partition
end
% end


% pseudo-include all vertices to the partition (keep subsets connected)
while sum(include)<N
    fprintf(['Including Percentage ',num2str(sum(include)/N*100), '%%\n']) % completion percentage of this inclusion part
    need=N-sum(include); % number of vertex need to include
    distance=M*ones(need,part); % shortest distance from each non-included vertex to each part
    a=0;
    DIS=zeros(need,1);
    for i=1:N
        if include(i)==0 % check N0.i vertex's distance to partition
            a=a+1; 
            DIS(a)=i; % the NO.a non-included vertex is the NO.i vertex
            for j=1:part % check vertex i's distance to each part
                for k=1:PV(j) % check vertex i's distance to each vertex in part j
                    distance(a,j)=min(distance(a,j),L(i,map(j,k))); % % shortest distance from non-included vertex i to part j
                end
            end
        end
    end
    if need==1 % [x y]=min(distance) has different meaning depends on whether "distance" is a matrix or vector
        [x y]=min(distance); % x is the minimum of each column, and y is the colomn index of these colomn minimums
        XX=1; Y=y;
        X=DIS(XX);
    else
        [x y]=min(distance); % x is the minimum of each column, and y is the row index of these colomn minimums
        [m n]=min(x); % m is the minimum, and n is the colomn index of the minimum
        XX=y(n); Y=n;
        X=DIS(XX);
    end
    
    % include vertex X to part Y
    if PV(Y)<N*d/TARGET & x<M  % only truely include vertex X when part Y is not too big or too far
        [PV,map]=Function_2(part,PV,map,X,Y);% include vertex X to part Y
    else % pseudo-inclusion
        ;
    end;
    include(X)=1; % update include data
end
% end


% merge subsets
merge=0;
SL=sparse(L);
while merge==0 % merge subsets until the target partition number is met, or the subset-size-constraint is met
    [e mini]=min(PV); % mini is the smallest subset
    distance=M*ones(4,1); % shortest distance from mini to each other subset, the path is from distance(i,2) to distance(i,3) 
    Multi_PATH=zeros(part,N);
    for i=1:part
        if i~=mini % calculate the shortest distance from mini to each other subset
            for j=1:PV(mini) 
                if vertex2vertex==1 | vertex(map(mini,j))==1 % if slow_better==0, only check the distances between terminals
                    for k=1:PV(i)
                        if vertex2vertex==1 | vertex(map(i,k))==1 % only check the distances between terminals
                            [dist,path,pred]=graphshortestpath(SL,map(mini,j),map(i,k));
                            if dist<distance(1)
                                distance(1)=dist; % update the shortest distance from mini to each other subset.
                                distance(2)=i;
                                distance(3)=map(mini,j);
                                distance(4)=map(i,k);
                            end
                        end
                    end
                end
            end
        end
    end
    target=distance(2);  % target is the subset which needs to to merged with mini
    
    if part>TARGET & PV(mini)+PV(target)<N*d/TARGET
        
        if add_SP==1 % merge the shortest path into mini, making sure that all subsets are connected
            [dist,PATH,pred]=graphshortestpath(SL,distance(3),distance(4));
            xx=size(PATH); XX=xx(2);
            for i=1:XX
                in=0; % 1 means vertex i is already in mini
                for j=1:PV(mini)
                    if map(mini,j)==PATH(i)
                        in=1;
                    end
                end
                if in==0  % add vertex PATH(i) into the mini part, but PATH(i) can still in more than 2 parts, for example, it can be in a third part
                    [PV,map]=Function_2(part,PV,map,PATH(i),mini);  % include vertex PATH(i) to part mini
                end
            end
            % end
            clear PATH;
        end
        
        [part,PV,map]=Function_4(part,PV,map,target,mini); % merget target into mini
        
    elseif part>TARGET & PV(mini)+PV(target)>=N*d/TARGET
        merge=1; % stop the merge because mini+target is too big
    elseif part<=TARGET
        merge=2; % stop the merge because the TARGET is met
    end
    percentage=(1-(part-TARGET)/(terminal_num-TARGET))*100; % completion percentage of this merge part
    fprintf(['Merging Percentage ',num2str(percentage),'%%']) % completion percentage of this merge part
    fprintf('\n')
end
% end
Time_Partition=toc



% output subsets
part
PV
pL=M*ones(part,max(PV),max(PV));
pset=zeros(part,max(PV),max(PV));% sets of adjacent points. 1 means it's adjacent, 0 means not
for i=1:part % update pset, pL
    for j=1:PV(i)
        for k=1:PV(i)
            pset(i,j,k)=set(map(i,j),map(i,k)); % the set matrix of part i
            pL(i,j,k)=L(map(i,j),map(i,k)); % the length matrix of part i
        end
    end
end
foodpoint=zeros(part,max(PV));
for i=1:part
    for j=1:PV(i)
        if vertex(map(i,j))==1 % it's terminal
            foodpoint(i,j)=1; % the jth vertex in part i is terminal
        end
    end
end
%


% check PO result
for i=1:part
    error=0;
    ll=zeros(PV(i));
    tnum(i)=0;
    for x=1:PV(i)
        tnum(i)=tnum(i)+vertex(map(i,x));
    end
    fprintf(['Part ', num2str(i),', ', num2str(tnum(i)), ' terminals are included.'])
    for j=1:PV(i)
        for k=1:PV(i)
            if pset(i,j,k)==1
                ll(j,k)=pL(i,j,k);
            end
            if pset(i,j,k)==1 & pL(i,j,k)==M
                error=error+1;
            end
        end
    end
    LL=sparse(ll);
    [S, C] = graphconncomp(LL);
    if S>1
        fprintf([' Disconnected!'])
    else
        ;
    end
%     if error==0
%        fprintf(['In part ', num2str(i), ' no inexistent edge has been created\n'])
%     else
%        fprintf(['In part ' num2str(i),', ', num2str(error),' inexistent edges have been created\n'])
%     end
    fprintf('\n')
end

fprintf('\n')
fprintf(['There are totally ', num2str(sum(PV)), ' vertices included.\n'])
fprintf(['There are totally ', num2str(sum(tnum)), ' terminals included.\n'])

% check vertex repetition error
repetition=zeros(N,1); % appreciance time in partition of each vertex
for i=1:part
    for j=1:PV(i)
        repetition(map(i,j))=repetition(map(i,j))+1;
    end
end
repe_error=0; % repetition error number
for i=1:N
    if repetition(i)>1
        repe_error=repe_error+1;
    end
end
fprintf('\n')
fprintf(['There are ', num2str(repe_error), ' vertices have been repeatedly included.\n']) % by adding the shortest path, the vertex can be repeatedly included into several parts.
% end

t_exist=zeros(N,1); % 1 means this vertex has been included
for i=1:part
    for j=1:PV(i)
        t_exist(map(i,j))=1;
    end
end
for i=1:N
    if vertex(i)==1 & t_exist(i)==0
        fprintf(['Terminal ', num2str(i), ' has not been included.\n'])
    end
end


save(['Result_Partition_', name, '_v', num2str(vertex2vertex),'_a',num2str(add_SP),'_T',num2str(TARGET), '_p', num2str(part)]);
% end

















