clear all; 
clc;

data=xlsread('b01.xlsx');
name='GA_B01';
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



popsize=10; %  popsize: population size
dimension=1;%  dimension: individual size
stringlength=N-foodnum;% stringlength: element size 
pm=0.2;             %  the probability of mutation  better to be around 0.2

tic;
pop=encoding(popsize,stringlength,dimension); 
pop=decoding(pop,stringlength,dimension,foodpoint,L); % include the fitness
[choice_number,choice_k]=min(pop(:,stringlength*dimension+1)); % the maximal fitness and its num
choice=pop(choice_k,:);  % inital best solution ever found
fe_GA=0; % function evalution
while success==0;
    new_pop=cross_over(pop,popsize,stringlength,dimension); % cross_over produces the new pop
    pop=mutation(new_pop,stringlength,dimension,pm); % mutation
    pop=decoding(pop,stringlength,dimension,foodpoint,L); 
    [number,k]=min(pop(:,stringlength*dimension+1)); 
    if choice_number>number 
        choice_number=number;  % best solution ever found
        choice_k=k; 
        choice=pop(choice_k,:); 
    end
    pop=selection(pop,popsize,stringlength,dimension); % selection of pop
    [number,m]=max(pop(:,stringlength*dimension+1)); 
    pop(m,:)=choice; % the fittest replaces the weakest
    
    fe_GA=fe_GA+1; % function evalution
    if choice_number>totalL
        fit_GA(fe_GA)=totalL; % fitness
    else
        fit_GA(fe_GA)=choice_number; % fitness
    end
    
    
    choice_number
    if choice_number==optimal
        success=1;
    end
end
Time=toc
save(name);  %%%%  save data

plot(1:fe_GA,fit_GA)
grid on;









