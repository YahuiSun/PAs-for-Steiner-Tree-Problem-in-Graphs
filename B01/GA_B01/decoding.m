%%%%%%% Decoding 
%  Decoding computes fitting values for individuals.


function pop=decoding(pop,stringlength,dimension,foodpoint,L) 
popsize=size(pop,1); 
for i=1:popsize  
    pop(i,dimension*stringlength+1)=funname(pop(i,1:dimension*stringlength),foodpoint,L); %  the redundant row is the fitness value
end 


%%%%%%%%%%%  fitness

function y=funname(x,foodpoint,L) 

N=size(foodpoint);
i=0;
for j=1:N
    if foodpoint(j)==0
        i=i+1;
        if x(i)==1
            foodpoint(j)=1;
        end
    end
end
M=sum(foodpoint); 
num=zeros(M,1); 
i=0;
for j=1:N
    if foodpoint(j)==1
        i=i+1;
        num(i)=j;% the ith MST points is the num(ith) foodpoint
    end
end
newL=zeros(M);
for i=1:M
    for j=1:M
        newL(i,j)=L(num(i),num(j));
    end
end

LL=sparse(newL);
[S, C] = graphconncomp(LL);
if S>1
    y=S*1e4;  
else
    
for i=1:M
    for j=i:M
        newL(i,j)=0; %length matrix: weights of the edges are all nonzero entries in the lower triangle of the N-by-N sparse matrix
    end
end
newL=sparse(newL);
[tree, pred]=graphminspantree(newL);
[i,j,s]=find(tree);
y=sum(s);

end




