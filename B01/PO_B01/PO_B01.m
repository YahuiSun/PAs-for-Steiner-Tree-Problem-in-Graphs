clear all; 
clc;

%%%%%%%%%%%%%%%%%%%%%%%%% Physarum Optimization constructs a network    (one sink, many sources)
load data_b01;
name='PO_B01';
optimal=82;  %%% optimal length

fe_PO=0; % function evaluation
N=data(1,1); % vertex number
edge_num=data(2,1); 
terminal_num=data(edge_num+6,1);
foodpoint=zeros(N,1);
for i=(edge_num+7):(edge_num+terminal_num+6)
    terminal=data(i,1);
    foodpoint(terminal)=1;
end
foodnum=sum(foodpoint); 
%%%
food=zeros(foodnum,1);
r=0;
for i=1:N
      if foodpoint(i)==1
          r=r+1;
          food(r)=i;  %%%%%%  the num r food is the num i vertice
      end
end
%%%%%%%%%%%%%
success=0; %%% success time
solution=optimal+1;

%%%%%%%%%%%%define flux
I=1e0;  %%%%%
kk=150;  %%% inner iteration times
cutoff=1e-3;   %%%% cutoff value of D
%%%%% evolution of conductivity
alpha=0.122;
sigma=1.0;
%%%%%length matrix, set matrix, initial conductivity matrix
v=1e4; %%% long distance
L=v*ones(N,N);%%%
set=zeros(N,N);%%%%%sets of adjacent points.   1 means it's adjacent, 0 means not
D=zeros(N,N);
edgevalue=ones(N,N);
for i=3:(edge_num+2)
    L(data(i,1),data(i,2))=data(i,3); L(data(i,2),data(i,1))=data(i,3);
    set(data(i,1),data(i,2))=1; set(data(i,2),data(i,1))=1;
    D(data(i,1),data(i,2))=1; D(data(i,2),data(i,1))=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reduction tests
% [Rset,RL,foodpoint,EdgeBefore,EdgeAfter,FoodB,FoodA,STedge,N,fuseL]=Reduction(solution,foodpoint,set,L);
Rset=set; RL=L; fuseL=0;
Time1=toc;
% foodnum=sum(foodpoint);
% %%%
% food=zeros(foodnum,1);
% r=0;
% for i=1:N
%       if foodpoint(i)==1
%           r=r+1;
%           food(r)=i;  %%%%%%  the num r food is the num i vertice
%       end
% end
%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
whole=0;
while success==0
    whole=whole+1   %%  iteration time

set=Rset; L=RL; D=set;
%%%%%%%%%%%%%%%%%%%%%%%%whether a vertex exist
exist=ones(N,1); %%%%%%%%%%%% 1 means exist, 0 means not

%%% iteration of D and P
for k=1:kk  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
NUM=zeros(N,1);
%%%%%%%%%%%%%% whether a vertex exist
linknum=zeros(N,1);  %% how many tubes linked to a certain vertex
for i=1:N
    for j=1:N
        if set(i,j)==1
            linknum(i)=linknum(i)+1;
        end
    end
    if linknum(i)==0
        exist(i)=0;
    end
end
vertex=sum(exist);  %%% number of existing vertex

%%%%%%%%%%%%%%%%%%%%%%%%%%% unequal possibility 3
adjacentlength=zeros(foodnum,1);
for i=1:foodnum
     for j=1:N
          if set(food(i),j)==1
              adjacentlength(i)=adjacentlength(i)+L(food(i),j);
          end
     end
end
[B,ind]=sort(adjacentlength);   %%%  ascending order,  B is the ordered vector, ind is the intex
TotalAdjacent=0;
for i=1:foodnum
    TotalAdjacent=TotalAdjacent+B(i);
end
sumad=zeros(foodnum,1);
for i=1:foodnum
    for j=1:i
        sumad(i)=sumad(i)+B(j);
    end
end
random=ceil(rand(1)*TotalAdjacent);
if random<=sumad(1)
    sink=food(ind(foodnum)); luck=ind(foodnum);
else
    for i=2:foodnum
        if random>sumad(i-1) & random<=sumad(i)
            sink=food(ind(foodnum+1-i)); luck=ind(foodnum+1-i);
        end
    end
end

%%%%%%%%%%%%%%   calculate the pressure
A=zeros(vertex-1);  
g=0; 
for w1=1:N   
        if exist(w1)==1   %%% only calculate the existing vertice
            if w1==sink %%% neglect the vertex if it's the sink point
                ;
            else
                g=g+1; %% row number of A
                h=0; 
                NUM(w1)=g; %%%  record the row number's relationship with vertex number, which will be used when using pressure
                for w3=1:N  %%%%%%%  the vertex corresponds to the columes of A
                    if exist(w3)==1  %%% only calculate the existing point
                         if w3==sink(1)  %%% neglect the vertex if it's the sink point
                             ;
                         else
                                h=h+1; %% colume number of A
                                if w3==w1   %%%  the row vertex is the colume vertex
                                    for i=1:N
                                        if set(w1,i)==1
                                            A(g,h)=A(g,h)-D(w1,i)/L(w1,i);
                                        end
                                    end
                                else    %%%%   the row vertex is not the colume vertex
                                    if set(w1,w3)==1
                                        A(g,h)=D(w1,w3)/L(w1,w3);
                                    end
                                end
                         end
                    end
                end
            end
        end
end

X=zeros(vertex-1,1); 
%%%%%%%%%%%%% all foodpoints that are not sink are sources
for i=1:foodnum
    if i==luck
        ;
    else
        X(NUM(food(i)))=-I;
    end
end

P=A\X;

%%%%calculate the flux and update the conductivity
for i=1:N
    for j=1:N
    if set(i,j)==1 
        if i==sink
            Q(i,j)=D(i,j)/L(i,j)*(0-P(NUM(j)));
                D(i,j)=edgevalue(i,j)*(D(i,j)+alpha*abs(Q(i,j))-sigma*D(i,j));
                if D(i,j)<cutoff  
                  set(i,j)=0; set(j,i)=0;
                end
        end
        if j==sink
            Q(i,j)=D(i,j)/L(i,j)*(P(NUM(i))-0);
                D(i,j)=edgevalue(i,j)*(D(i,j)+alpha*abs(Q(i,j))-sigma*D(i,j));
                if D(i,j)<cutoff  
                  set(i,j)=0; set(j,i)=0;
                end
        end
        if i~=sink && j~=sink
            Q(i,j)=D(i,j)/L(i,j)*(P(NUM(i))-P(NUM(j)));
                D(i,j)=edgevalue(i,j)*(D(i,j)+alpha*abs(Q(i,j))-sigma*D(i,j));
                if D(i,j)<cutoff  
                  set(i,j)=0; set(j,i)=0;
                end
        end
    end
    end
end
fe_PO=fe_PO+1; % function evaluation
    Total_length=0;  %%%  total length of the network
    for i=1:N
        for j=i:N
            if set(i,j)==1
                Total_length=Total_length+L(i,j);
            end
        end
    end
    Total_length=Total_length+fuseL;
    fit_PO(fe_PO)=Total_length;




EDGE(k)=sum(sum(set))/2;  %%%  record the evolution
end  %%%% k iteration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
min(fit_PO)

if Total_length==min(fit_PO)
    MinSet=set;
    for i=1:N
        for j=1:N
           if set(i,j)==1
               edgevalue(i,j)=1.2;
           else 
               edgevalue(i,j)=0.8;
           end
        end
    end
end

Time=toc;  %%% record simulation time

if Total_length==optimal | Time>=86400 % 1 day or 24 hours
    success=success+1;
end

end   %%%%  whole iteration
success
%%%%%%%%%%%%%  Analysis

Time2=toc-Time1;  %%% record simulation time
Totaltime=Time1+Time2;
save(name);  %%%%  save data
Time1
Time2
Totaltime

plot(1:fe_PO,fit_PO)
grid on;

