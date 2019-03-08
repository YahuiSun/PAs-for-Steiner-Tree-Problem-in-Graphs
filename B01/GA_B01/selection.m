%%%%%%%%%%%  selection

% Selection is the proceeding through which a new population is formed by choosing the individuals with greater 
% fitting values and eliminating the individuals with smaller fitting values. There are two strategies: the first 
% strategy is that maintaining the individuals with greatest fitting values into the next population; the second 
% strategy is that choosing the individuals to next population by bet ring arithmetic which guarantee direct ratio
% between chosen probability and fitting value of the individual



function selected=selection(pop,popsize,stringlength,dimension)

popsize_new=size(pop,1); 
r=rand(1,popsize); 
fitness=pop(:,dimension*stringlength+1); 

fitness=fitness/sum(fitness); 
fitness=cumsum(fitness); % cumsum(X) is a vector containing the cumulative sum of the elements of X
for i=1:popsize  % selection number is popsize (old popsize)
    for j=1:popsize_new 
        if r(i)<=fitness(j) % randomly select from the new_pop
            selected(i,:)=pop(j,:); 
            break; 
        end 
    end 
end 

% [B,ind]=sort(fitness);   %%%  ascending order,  B is the ordered vector, ind is the intex
% for i=1:popsize  % selection number is popsize (old popsize)
%      selected(i,:)=pop(ind(i),:); %  select the fittest population
% end