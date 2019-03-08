% use input data to make graph

function [N,edge_num,terminal_num,vertex,terminal,L,set]=Function_3(data,M)

%
N=data(1,1); % vertex number
edge_num=data(2,1);  % edge number
terminal_num=data(edge_num+6,1); % terminal number
%

% terminal definition
vertex=zeros(N,1); % 1 means it's terminal, 0 means not
for i=(edge_num+7):(edge_num+terminal_num+6)
    t=data(i,1);
    vertex(t)=1;
end
terminal=zeros(terminal_num,1);
r=0;
for i=1:N
      if vertex(i)==1
          r=r+1;
          terminal(r)=i;  % the num r terminal is the num i vertice
      end
end
%

% length matrix, set matrix, initial conductivity matrix
L=M*ones(N,N);
set=zeros(N,N);% sets of adjacent points. 1 means it's adjacent, 0 means not
for i=3:(edge_num+2)
    L(data(i,1),data(i,2))=data(i,3); L(data(i,2),data(i,1))=data(i,3);
    set(data(i,1),data(i,2))=1; set(data(i,2),data(i,1))=1;
end
%