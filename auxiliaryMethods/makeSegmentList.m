function listS=makeSegmentList(nml,overWriteEdges,emphasizeNodes)

a=cell(1);
a{1,1}=nml;
if overWriteEdges
    a{1,1}.edges=zeros(size(a{1,1}.nodes,1)-1,2);
    for i=1:size(a{1,1}.edges,1)
        if emphasizeNodes
            a{1,1}.edges(i,:)=[1,i+1];
        else
            a{1,1}.edges(i,:)=[i,i+1];
        end
    end
end

conM=zeros(size(a{1,1}.nodes,1));
for ii=a{1,1}.edges'
    if ii(1)>0&&ii(2)>0
        conM(ii(1),ii(2))=1;
    end
end
conM=conM+conM';
sconM=sum(conM);
sconM(sconM>1)=0;
startP= find(sconM);
directionP=find(conM(:,startP(1)));
listS=n2hR(a{1,1},conM,startP(1),directionP);
end

function y=n2hR(aa,conM,oldNode,newNode)
y=cell(1);
y{1}=[oldNode,aa.nodes(oldNode,:)];
while(true)
    y{1}=[y{1};[newNode,aa.nodes(newNode,:)]];
    switch sum(conM(:,newNode))
        case 1 %terminate segment
            break;
        case 2 %continue segment
            listN=find(conM(:,newNode));
            if listN(1)==oldNode
                oldNode=newNode;
                newNode=listN(2);
            else
                oldNode=newNode;
                newNode=listN(1);
            end
        otherwise %make child segments
            listN=find(conM(:,newNode))';
            for nodeIt=listN
                if nodeIt~=oldNode
                    y=[y; n2hR(aa,conM,newNode,nodeIt)];
                end
            end
            break;
    end
end
end
