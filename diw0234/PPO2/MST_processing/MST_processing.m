clc; clear all;

load Result_Partition_diw0234_v0_a1_T5_p5
load POset_diw0234_P5_kk500_MinWhole100_Ratio15;

X=size(POset);
newPOset=zeros(X(1),X(2),X(3));

for i=1:X(1)
    % process POset(i,:,:)
    N=X(2);
    solution_set=zeros(N);
    for j=1:N
        for k=1:N
            solution_set(j,k)=POset(i,j,k);
        end
    end
    Length=zeros(N);
    for j=1:N
        for k=1:N
            Length(j,k)=pL(i,j,k);
        end
    end
    initial_set=zeros(N);
    for j=1:N
        for k=1:N
            initial_set(j,k)=pset(i,j,k);
        end
    end
    [post_set]=Function_SMTpost(N,solution_set,Length,initial_set);
    for j=1:N
        for k=1:N
            newPOset(i,j,k)=post_set(j,k);
        end
    end
end

save(['Result_MSTprocessed_POset'], 'newPOset'); % save POset




