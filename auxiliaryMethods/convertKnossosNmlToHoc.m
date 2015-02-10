function y=convertKnossosNmlToHoc(a,filename,overWriteEdges,overWriteThickness,emphasizeNodes,useSplines,resolution)

for i=1:size(a,2)
    if ~isempty(a{i}.nodes)
        a_sorted=sortrows([a{i}.nodes (1:size(a{i}.nodes,1))'],3);
        cast(a_sorted(end,:),'uint16')
        a{i}.nodes(a_sorted(end,5),4)=1000;
        listS=makeSegmentList(a{i},overWriteEdges,emphasizeNodes);
        fid=fopen([filename num2str(i, '%.4i') '.hoc'], 'w+');
        fprintf(fid,'/* created with convertKnossosNmlToHoc.m */\n');
        for ii=1:size(listS,1)
            y=listS{ii,1}(:,5);
            %     if y(1)==1.5
            %         y(1)=1;
            %     end
            %     if y(end)==1.5;
            %         y(end)=1;
            %     end
            x=1:size(y,1);
            xx=find(y-1.5);
            yy=y(y~=1.5);
            if size(xx,1)<1
                xx=[1 2];
                yy=[27 27];

            else if size(xx,1)<2
                    if xx(1)==x(1)
                        xx=[xx x(end)];
                        yy=[yy 27];
                    else
                        xx=[x(1) xx];
                        yy=[27 yy];
                    end
                end
            end
            y=interp1(xx,yy,x);
            if useSplines
                listS{ii,1}(:,5)=y;
            end
            if overWriteThickness
                listS{ii,1}(:,5)=100;
            end

            fprintf(fid,'\n{create adhoc%i}\n',ii);
            fprintf(fid,'{access adhoc%i}\n',ii);
            for jj=1:ii-1
                if listS{jj,1}(1,1)==listS{ii,1}(1,1)
                    fprintf(fid,'{connect adhoc%i(0), adhoc%i(0)}\n',ii,jj);
                    break;
                end
                if listS{jj,1}(end,1)==listS{ii,1}(1,1)
                    fprintf(fid,'{connect adhoc%i(1), adhoc%i(0)}\n',ii,jj);
                    break;

                end

            end
            fprintf(fid,'{nseg = 1}\n');
            fprintf(fid,'{strdef color color = "White"}\n');
            fprintf(fid,'{pt3dclear()}\n');
            for jj=listS{ii,1}'
                fprintf(fid,'{pt3dadd(%f,%f,%f,%f)}\n',jj(2)*resolution(1),jj(3)*resolution(2),jj(4)*resolution(3),jj(5)*mean(resolution));
            end
        end
        fclose(fid);
    end
end

end

