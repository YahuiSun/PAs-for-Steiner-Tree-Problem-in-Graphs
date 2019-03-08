% merge part target into part mini

function [part,PV,map]=Function_4(part,PV,map,target,mini)


for i=1:PV(target)
    in=0; % 1 means vertex map(target,i) is already in part mini
    for j=1:PV(mini)
        if map(mini,j)==map(target,i)
            in=1;
        end
    end
    if in==0 % prevent vertex repetition error
        [PV,map]=Function_2(part,PV,map,map(target,i),mini); % include vertex map(target,i) to part mini
    end
end

interMap=zeros(part-1,max(PV));
interPV=zeros(part-1,1);
a=0;
for i=1:part
    if i~=target
        a=a+1;
        for j=1:PV(i)
            interMap(a,j)=map(i,j);
        end
        interPV(a)=PV(i);
    else
        ;
    end
end

clear map;
map=interMap;
PV=interPV;
part=part-1;

