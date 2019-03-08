%%%%%%%%%%%  cross-over 
%   Randomly choosing two individuals from pop, and changing the bits of the same section of the two individuals. 
%   two functions written which complete the course of mutation by change the part of the binary strings of the chosen individuals


function new_pop=cross_over(pop,popsize,stringlength,dimension) 
match=round(rand(1,popsize)*(popsize-1))+1;   %  random integer between 1 and popsize
for i=1:popsize 
    [child1,child2]=cross_running(pop(i,:),pop(match(i),:),stringlength,dimension); 
     new_pop(2*i-1:2*i,:)=[child1;child2]; %  crossover new_pop(i,:) and new_pop(match(i),:) into new_pop(2*i-1,:) and new_pop(2*i,:), this size of new_pop is doubled from pop
end 



function [child1,child2]=cross_running(parent1,parent2,stringlength,dimension) 
cpoint=round((stringlength-1)*rand(1,dimension))+1; %  random integer between 1 and stringlength  (use this number to cut each parent_string into 2 parts)
for j=1:dimension  
     child1((j-1)*stringlength+1:j*stringlength)=[parent1((j-1)*stringlength+1:(j-1)*stringlength+cpoint(j)) parent2((j-1)*stringlength+cpoint(j)+1:j*stringlength)];
     child2((j-1)*stringlength+1:j*stringlength)=[parent2((j-1)*stringlength+1:(j-1)*stringlength+cpoint(j)) parent1((j-1)*stringlength+cpoint(j)+1:j*stringlength)]; 
    % each child_string is made of 1 part of parent1 and 1 part of parent2
end