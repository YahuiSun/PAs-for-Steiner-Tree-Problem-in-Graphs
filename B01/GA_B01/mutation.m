%%%%%% mutation 
%%%  For the individual to mutate, randomly choose the point to mutate, which means the bit of the individual encoded binary string, then change 0 to 1 and change 1 to 0



function new_pop=mutation(new_pop,stringlength,dimension,pm) 
new_popsize=size(new_pop,1); 
for i=1:new_popsize 
    if rand<pm  %  Pm is the probability of mutation and it is not great in nature
        mpoint=round(rand(1,dimension)*(stringlength-1))+1; %  random integer between 1 and stringlength 
        for j=1:dimension 
            new_pop(i,(j-1)*stringlength+mpoint(j))=1-new_pop(i,(j-1)*stringlength+mpoint(j)); % change one population: 0 to 1 and change 1 to 0
        end 
    end 
end 

