%%%%%%%  randomly produces an encoded original population
%%%  Pop: a matrix whose every row indicates an individual and the total number of rows is denoted as popsize

function pop=encoding(popsize,stringlength,dimension) 
pop=round(rand(popsize,dimension*stringlength+1)); %  the redundant row is the fitness value