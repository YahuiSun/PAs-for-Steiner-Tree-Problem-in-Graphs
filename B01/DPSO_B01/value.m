
% calculate the value of each particle

function y=value(foodpoint,L,x)

a=size(x);
xSize=a(1);% population size 
Dim=a(2); % particle dimension
y=zeros(xSize,1); % fitness/value

N=size(foodpoint); % total num of vertex

for w=1:xSize % num of particles
    i=0;
    for j=1:N
        if foodpoint(j)==0
            i=i+1;
            if x(w,i)==1 % selected Steiner points
                foodpoint(j)=1;
            end
        end
    end
    M=sum(foodpoint); % size of MST
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
            newL(i,j)=L(num(i),num(j)); % MST graph
        end
    end
    
    LL=sparse(newL);
    [S,C]=graphconncomp(LL);
    if S>1
        y(w)=S*1e4;   
    else
        for i=1:M
            for j=i:M
                newL(i,j)=0; %length matrix: weights of the edges are all nonzero entries in the lower triangle of the N-by-N sparse matrix
            end
        end
        newL=sparse(newL);
        [tree,pred]=graphminspantree(newL);
        [i,j,s]=find(tree);
        y(w)=sum(s);
    end
end
