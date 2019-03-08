clc; clear all;

load Result_PPO_diw0234_P5_kk500_MinWhole100_Ratio15_D2;

[post_set]=Function_SMTpost(newN,SPHset,newL,newset);

Heuristic=Heuristic-solution; % the cost that have been merged in the new terminals
for i=1:newN
    for j=i:newN
        Heuristic=Heuristic+post_set(i,j)*newL(i,j);
    end
end

% result calculation and output
fprintf(['Heuristic Solution= ', num2str(Heuristic),'\n'])
fprintf(['Deviation= ', num2str((Heuristic-optimal)/optimal*100), '%%'])
fprintf('\n')
fprintf('\n')