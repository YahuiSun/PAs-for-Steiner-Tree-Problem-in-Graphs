   clear all; clc;
% INPUT: partitioned graph (at least 2 parts)
% OUTPUT: heuristic SMT result got by Partition-based PO algorithm


tic;
% find PO_SMT result in each subset
Vertex2Vertex=1; % 1 means it calculates the shortest path from vertex to vertex when connecting subsets, 0 means terminal to terminal

% PO parameter
I=1e0;
kk=500;  % inner iteration times
cutoff=1e-3;   % cutoff value of D
alpha=0.122;
sigma=1.0;
% End optimization parameter
Timelimit=3600*2; % Timelimit for each subset optimization
MinWhole=100; % the minimum whole calculation time 
Ratio=10;                 EndRatio=1/Ratio; % the minimum have got should be in the first EndRatio part of the optimization



load Result_Partition_diw0234_v0_a1_T20_p20;  % input_graph
name='diw0234';
optimal=1996;  % Steiner minimum tree length



% optimization
fprintf(['There are ', num2str(part), ' parts.'])
fprintf(['\n'])
fprintf(['\n'])
for i=1:part
    fprintf(['Part ',num2str(i), ' is being optimized.\n'])
    if sum(foodpoint(i,1:PV(i)))==1 % only one terminal in the subset
        POset(i,1:PV(i),1:PV(i))=0; % only the single terminal remined
    else
        [POset(i,1:PV(i),1:PV(i))]=Function_1(PV(i),pset(i,1:PV(i),1:PV(i)),pL(i,1:PV(i),1:PV(i)),foodpoint(i,1:PV(i)),I,kk,cutoff,alpha,sigma,Timelimit,MinWhole,EndRatio); 
%         % move out disconnected part
%         check=zeros(PV(i),1); % 1 means this vertex is connected in the main part
%         for m=1:PV(i)
%             if vertex(map(i,m))==1
%                 check(m)=1;
%             end
%         end
%         change=1;
%         while change==1
%             c_1=sum(check);
%             for m=1:PV(i)
%                 if check(m)==1
%                     for n=1:PV(i)
%                         if POset(i,m,n)==1
%                             check(n)=1;
%                         end
%                     end
%                 end
%             end
%             c_2=sum(check);
%             if c_1==c_2
%                 change=0; % all vertices in the main part have been checked.
%             end
%         end
%         for m=1:PV(i)
%             for n=1:PV(i)
%                 if check(m)==0 & check(n)==0
%                     POset(i,m,n)=0; % move out disconnected part
%                 end
%             end
%         end
%         % end
    end
    fprintf(['Part ',num2str(i), ' has been optimized.\n'])
    fprintf(['\n'])
end
save(['POset_', name, '_P', num2str(part),'_kk',num2str(kk),'_MinWhole',num2str(MinWhole),'_Ratio',num2str(Ratio)], 'POset'); % save POset
fprintf(['\n'])
% end
Time_optimization=toc;

% load ; % load POset, if there is a POset data

% % draw the PO result by hand
% i=6;
% for j=1:PV(i)
%     for k=j:PV(i)
%         if POset(i,j,k)==1
%             fprintf(['(', num2str(j), ', ', num2str(k), ')\n']);
%         end
%     end
% end
% %


% % check PO result
% fprintf(['In PO result\n'])
% for i=1:part
%     error=0;
%     ll=zeros(PV(i));
%     for j=1:PV(i)
%         for k=1:PV(i)
%             if POset(i,j,k)==1 && pL(i,j,k)==M
%                 error=error+1;
%             end
%         end
%     end
%     if error==0
%        fprintf(['In Part ', num2str(i), ' no inexistent edge has been created\n'])
%     else
%        fprintf(['In Part ' num2str(i),', ', num2str(error),' inexistent edges have been created\n'])
%     end
% end
% fprintf(['\n'])
% % end


% print PO_result into the result
result_set=zeros(N,N);
for i=1:part
    for j=1:PV(i)
        for k=j:PV(i)
            if POset(i,j,k)==1
                result_set(map(i,j),map(i,k))=1; result_set(map(i,k), map(i,j))=1;
            end
        end
    end
end
% end


% make all connected vertices in optimization results as terminals
if Vertex2Vertex==1
    change=1;
    while change==1
        sumfood=sum(sum(foodpoint));
        for i=1:part
            for j=1:PV(i)
                for k=j:PV(i)
                    if POset(i,j,k)==1 & foodpoint(i,j)+foodpoint(i,k)>0
                        foodpoint(i,j)=1;
                        foodpoint(i,k)=1;
                    end
                end
            end
        end
        if sumfood==sum(sum(foodpoint))
            change=0;
        end
    end
end
% end



% connect subsets
connect=zeros(part,1); % 1 means this part has been connected

% 2 subsets are connected together at first
DIST=M;
SL=sparse(L);
for i=1:part
    fprintf(['Initial Connecting Percentage ',num2str(i/part*100), '%%']) % completion percentage of this part
    fprintf('\n')
    for j=1:PV(i)
        if foodpoint(i,j)==1
            for m=1:part
                if m~=i
                    for n=1:PV(m)
                        if foodpoint(m,n)==1
                            [dist,path,pred]=graphshortestpath(SL,map(i,j),map(m,n));
                            if dist<DIST
                                DIST=dist; % find the shortest distance between terminal j in part i and terminal n in part m
                                Target1=map(i,j);
                                Target2=map(m,n);
                                t1=i; t2=m;
                            end
                        end
                    end
                end
            end
        end
    end
end
connect(t1)=1; connect(t2)=1; 
if Target1~=Target2 % there may be same vertex in 2 subsets
    [dist,PATH,pred]=graphshortestpath(SL,Target1,Target2);
    xx=size(PATH); yy=xx(2);
    for i=1:yy-1
        result_set(PATH(i),PATH(i+1))=1;result_set(PATH(i+1),PATH(i))=1; % connect the shortest path
    end
end

Time_initial_connection=toc-Time_optimization;


% connect other subsets
while sum(connect)<part % connect all parts
    fprintf(['Connecting Percentage ',num2str(sum(connect)/part*100), '%%']) % completion percentage of this part
    fprintf('\n')
    DIST=M;
    for i=1:part % find the shortest path between terminals in connected parts and terminals in un-connected parts
        if connect(i)==1
            for j=1:PV(i)
                if foodpoint(i,j)==1
                    for m=1:part
                        if connect(m)==0
                            for n=1:PV(m)
                                if foodpoint(m,n)==1
                                    [dist,path,pred]=graphshortestpath(SL,map(i,j),map(m,n));
                                    if dist<DIST
                                        DIST=dist;
                                        Target1=map(i,j);
                                        Target2=map(m,n);
                                        t=m;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    connect(t)=1;
    if Target1~=Target2
        [dist,PATH,pred]=graphshortestpath(SL,Target1,Target2);
        xx=size(PATH); yy=xx(2);
        for i=1:yy-1
            result_set(PATH(i),PATH(i+1))=1;result_set(PATH(i+1),PATH(i))=1; % connect the shortest path
        end
    end
end

Time_connection=toc-Time_optimization-Time_initial_connection;
% end 


% check result
fprintf('\n')
error=0;
for i=1:N
    for j=i:N
        if result_set(i,j)==1 & L(i,j)==M
            error=error+1;
        end
    end
end
if error==0
   ;
else
   fprintf([num2str(error),' inexistent edges have been created\n'])
   fprintf('\n')
end

% LL=sparse(result_set);
% [S, C] = graphconncomp(LL);
% if S>1
%     fprintf(['Solution Disconnected!\n'])
%     fprintf('\n')
% else
%     ;
% end
% end


% result calculation and output
Heuristic=0; % SMT result
for i=1:(N-1)
    for j=(i+1):N
        Heuristic=Heuristic+result_set(i,j)*L(i,j);
    end
end
fprintf(['Heuristic Solution= ', num2str(Heuristic),'\n'])
fprintf(['Deviation= ', num2str((Heuristic-optimal)/optimal*100), '%%'])
fprintf('\n')
fprintf('\n')

% check whether all terminals have been included
degree=zeros(N,1);
for i=1:N
    for j=1:N
        if result_set(i,j)==1
            degree(i)=degree(i)+1;
        end
    end
end
for i=1:N
    if vertex(i)==1 & degree(i)==0
        fprintf(['Terminal ', num2str(i), ' has not been included\n'])
    end
end
% end




save(['Result_PPO_', name, '_P', num2str(part), '_V', num2str(Vertex2Vertex),'_kk',num2str(kk),'_MinWhole',num2str(MinWhole),'_Ratio',num2str(Ratio), '_D', num2str(ceil((Heuristic-optimal)/optimal*100))]);
% end



























