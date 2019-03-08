clear all; clc;
% INPUT: partitioned graph (at least 2 parts)
% OUTPUT: heuristic SMT result got by PPO2


tic;
% find PO_SMT result in each subset

% PO parameter
I=1e0;
kk=500;  % inner iteration times
cutoff=1e-3;   % cutoff value of D
alpha=0.122;
sigma=1.0;
% End optimization parameter
Timelimit=3600*1; % Timelimit for each subset optimization
MinWhole=100; % the minimum whole calculation time 
Ratio=15;                 EndRatio=1/Ratio; % the minimum have got should be in the first EndRatio part of the optimization



load Result_Partition_diw0234_v0_a1_T5_p5;  % input_graph
name='diw0234';
optimal=1996;  % Steiner minimum tree length



% optimization
fprintf(['There are ', num2str(part), ' parts.'])
fprintf(['\n'])
% fprintf(['\n'])
% for i=1:part
%     fprintf(['Part ',num2str(i), ' is being optimized.\n'])
%     if sum(foodpoint(i,1:PV(i)))==1 % only one terminal in the subset
%         POset(i,1:PV(i),1:PV(i))=0; % only the single terminal remined
%     else
%         [POset(i,1:PV(i),1:PV(i))]=Function_1(PV(i),pset(i,1:PV(i),1:PV(i)),pL(i,1:PV(i),1:PV(i)),foodpoint(i,1:PV(i)),I,kk,cutoff,alpha,sigma,Timelimit,MinWhole,EndRatio); 
%     end
%     fprintf(['Part ',num2str(i), ' has been optimized.\n'])
%     fprintf(['\n'])
% end
% save(['POset_', name, '_P', num2str(part),'_kk',num2str(kk),'_MinWhole',num2str(MinWhole),'_Ratio',num2str(Ratio)], 'POset'); % save POset
% fprintf(['\n'])
load Result_MSTprocessed_POset;   POset=newPOset;
% end
Time_optimization=toc;



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
Heuristic=0; % SMT result
for i=1:(N-1)
    for j=(i+1):N
        Heuristic=Heuristic+result_set(i,j)*L(i,j);
    end
end
% end

% print a new graph
SET=sparse(result_set);
[S, C] = graphconncomp(SET); % prepare to get the new smaller graph
newN=S; % vertex number in new graph
%
sizeN=zeros(newN,1); % number of old vertices included in the new vertex
for i=1:N
    sizeN(C(i))=sizeN(C(i))+1;
end
%
indexN=zeros(newN,max(sizeN)); % index of included vertices
ai=zeros(newN,1);
for i=1:N
    ai(C(i))=ai(C(i))+1;
    indexN(C(i),ai(C(i)))=i;
end
%
newset=zeros(newN,newN);
newL=M*ones(newN,newN);
for i=1:newN
    for j=i:newN
        largeset=0;
        smallL=M;
        for m=1:sizeN(i)
            for n=1:sizeN(j)
                largeset=max(set(indexN(i,m),indexN(j,n)),largeset);
                smallL=min(L(indexN(i,m),indexN(j,n)),smallL);
            end
        end
        newset(i,j)=largeset; newset(j,i)=newset(i,j);
        newL(i,j)=smallL; newL(j,i)=newL(i,j);
    end
end
%
new_foodpoint=zeros(newN,1); % foodpoint index for new graph
for i=1:newN
    for j=1:sizeN(i)
        new_foodpoint(i)=max(new_foodpoint(i),vertex(indexN(i,j)));
    end
end
%


% SPH connection
[solution,SPHset]=Function_5(newN,newset,newL,new_foodpoint); % SPH function
Heuristic=Heuristic+solution; % the PPO2 solution





% result calculation and output

fprintf(['Heuristic Solution= ', num2str(Heuristic),'\n'])
fprintf(['Deviation= ', num2str((Heuristic-optimal)/optimal*100), '%%'])
fprintf('\n')
fprintf('\n')


save(['Result_PPO_', name, '_P', num2str(part),'_kk',num2str(kk),'_MinWhole',num2str(MinWhole),'_Ratio',num2str(Ratio), '_D', num2str(ceil((Heuristic-optimal)/optimal*100))]);
% end


