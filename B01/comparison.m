clc; clear all;


load GA_B01;
load PO_B01;
load DPSO_B01;
name='B01';

%  comparison of different algorithms' function evaluation

% make fe_PO shorter
for i=1:kk
    if EDGE(i)==EDGE(kk)
        new_kk=i; % the new kk
        break;
    end
end
fepo=0;
for i=1:fe_PO
    if mod(i,kk)>=1 & mod(i,kk)<=new_kk
        fepo=fepo+1;
        new_fit_PO(fepo)=fit_PO(i);
    end
end
fe_PO=fepo;
fit_PO=new_fit_PO;
for i=1:fe_PO
    fit_PO(i)=min(fit_PO(1:i));
end
%

fe_PO
fe_GA
fe_PSO

% make tham have the same length in axis x
max1=max(fe_GA,fe_PO);
max=max(max1,fe_PSO);
if fe_GA<max   % GA
    for i=fe_GA:max
        fit_GA(i)=fit_GA(fe_GA);
    end
    fe_GA=max;
end
if fe_PSO<max   % GA
    for i=fe_PSO:max
        fit_PSO(i)=fit_PSO(fe_PSO);
    end
    fe_PSO=max;
end
if fe_PO<max  % PO
    for i=fe_PO:max
        fit_PO(i)=fit_PO(fe_PO);
    end
    fe_PO=max;
end


plot(1:fe_GA,fit_GA,'r','LineWidth',2)  %  LineWidth=1 by default
grid on;
hold on;
plot(1:fe_PO,fit_PO,'b','LineWidth',2)
hold on;
plot(1:fe_PSO,fit_PSO,'g','LineWidth',2)

legend('GA','PO','DPSO');
xlabel('Function Evaluation','FontSize',12); %  FontSize=10 by default
ylabel(['Fitness of Instance ',name],'FontSize',12);