% include vertex X to part Y

function [PV,map]=Function_2(part,PV,map,X,Y)

in=0;
for m=1:PV(Y)
    if X==map(Y,m)
        in=1;
    end
end
if in==0 % prevent vertex repetition error
    PV(Y)=PV(Y)+1; % one more vertex in part Y
    % update map data
    interMap=zeros(part,max(PV));
    for i=1:part
         for j=1:PV(i)
              if i==Y & j==PV(i)
                  interMap(i,j)=X; % decide the new vertex's place in the inital graph
              else
                  interMap(i,j)=map(i,j); % replicate old map data
              end
         end
    end
    clear map;
    map=interMap; % update map data
    % end
end
