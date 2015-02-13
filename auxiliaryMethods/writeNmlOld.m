function writeNmlOld( ksw_fname, ksw_skeleton )

% MB: Added some stuff for backwards compability, maybe merger back to
% github?

% WRITENML: Write Knossos or Oxalis skeletons in Matlab as a .nml file
%   
%   The function has the following arguments:
%       KSW_FNAME: Give the full path of the file in which you want to
%           write the data, e.g. 'E:\knossos_skeleton.nml'
%       KSW_SKELETON: Give the name of the cell array containing the
%           skeleton(s), e.g. tracing in the Matlab workspace.
%       
%   => writeNml( 'E:\knossos_skeleton.nml', tracing )
%

% version 1.01   Martin Zauser   comments are saved if available in the skeleton as a huge string 
% version 1.02   Martin Zauser   comments are saved from NodesAsStruct attribute 
% version 1.03   Martin Zauser   thingIDs and nodeIds corrected
%                                   (ID from nodesNumDataAll/nodesAsStruct instead of a sequential number) 
% version 1.04   Martin Zauser   renamed to writeNml (former: writeKnossosNml),
%                                    output message informs about data source (nodes / nodesNumDataAll)
% version 1.05   Martin Zauser   writeNml terminates correctly in case nodesNumDataAll does not exist
%                                    or is empty
% version 1.06   Martin Zauser   branchpoint output is now available
% version 1.07   Martin Zauser   name attribute of thing element is provided in output file

    % print version on the screen
    %fprintf( 'This is writeNml version 1.07\n' );

    % Open the file, if it already exists, overwrite the contents.
    fid = fopen( ksw_fname, 'w' );
    
    % The .nml format is an ASCII file, thus human readable.
    fprintf( fid, '<?xml version=\"1.0\"?>\n' );
    fprintf( fid, '<things>\n' );

    % If ksw_skeleton{1}.parameters is a structure array, continue.
    if isfield( ksw_skeleton{1}, 'parameters')
        
        % Read out the necessary information.
        ksw_experimentName = ksw_skeleton{1}.parameters.experiment.name;
        ksw_scale = ksw_skeleton{1}.parameters.scale;
        ksw_offset = ksw_skeleton{1}.parameters.offset;
        if isfield(ksw_skeleton{1}.parameters, 'time')
            ksw_time = ksw_skeleton{1}.parameters.time.ms;
        end
        if isfield(ksw_skeleton{1}.parameters, 'activeNode')
            ksw_activeNode = ksw_skeleton{1}.parameters.activeNode.id;
        end
        if isfield(ksw_skeleton{1}.parameters, 'editPosition')
            ksw_editPosition = ksw_skeleton{1}.parameters.editPosition;
        end
        
        % Write the parameters into the file.
        fprintf( fid, '\t<parameters>\n\t\t<experiment name=\"%s\"/>\n\t\t<scale x=\"%s\" y=\"%s\" z=\"%s\"/>\n\t\t<offset x=\"%s\" y=\"%s\" z=\"%s\"/>', ...
        ksw_experimentName, ksw_scale.x, ksw_scale.y, ksw_scale.z, ...
        ksw_offset.x, ksw_offset.y, ksw_offset.z );
        
        if exist('ksw_time', 'var')
            fprintf( fid, '\n\t\t<time ms=\"%s\"/>', ksw_time);
        end
        if exist('ksw_activeNode', 'var')
            fprintf( fid, '\n\t\t<activeNode id=\"%s\"/>', ksw_activeNode);
        end
        if exist('ksw_editPosition', 'var')
            fprintf( fid, '\n\t\t<editPosition x=\"%s\" y=\"%s\" z=\"%s\"/>', ...
                ksw_editPosition.x, ksw_editPosition.y, ksw_editPosition.z );
        end
        fprintf( fid, '\n\t</parameters>\n');
        clear( 'ksw_experimentName', 'ksw_scale', 'ksw_offset', 'ksw_time', 'ksw_activeNode', 'ksw_editPosition');
    end
    
    % Necessary if multiple skeletons exist.
    kl_totalNodeC = 0;
    
    % reset variables for data source message
    thing1_available = 0;
    thing2_available = 0;
    thing1_start = 0;
    thing1_end = 0;
    thing2_start = 0;
    thing2_end = 0;
    
    % Determine the number of different skeletons and go over each one.
    for kl_thingC = 1 : size( ksw_skeleton, 2 )
        
        % Start with writing the skeleton ("thing") id into the file.
        fprintf( fid, '\t<thing id=\"%d\"', ksw_skeleton{kl_thingC}.thingID );
            % Write name attribute if available
            if isfield( ksw_skeleton{kl_thingC}, 'name' ) && ~isempty( ksw_skeleton{kl_thingC}.name ) 
                fprintf( fid, ' name=\"%s\"', ksw_skeleton{kl_thingC}.name );
            end
	   % Write color attribute(s) if available
            if isfield( ksw_skeleton{kl_thingC}, 'color' ) 
                fprintf( fid, ' color.r=\"%d\" color.g=\"%d\" color.b=\"%d\" color.a=\"%d\"', ksw_skeleton{kl_thingC}.color(1), ksw_skeleton{kl_thingC}.color(2), ksw_skeleton{kl_thingC}.color(3), ksw_skeleton{kl_thingC}.color(4));
            end

        fprintf( fid, '>\n' );
        % Write the nodes of the skeleton into the file.
        fprintf( fid, '\t\t<nodes>\n' );
        
        if isfield( ksw_skeleton{kl_thingC}, 'nodesNumDataAll' ) && ~isempty( ksw_skeleton{kl_thingC}.nodesNumDataAll ) 
            
            ksw_nodeList = ksw_skeleton{kl_thingC}.nodesNumDataAll;
            if size(ksw_nodeList,2) == 6
                ksw_nodeList(:,7) = ksw_nodeList(:,6);
                ksw_nodeList(:,8) = ksw_nodeList(:,6);
            end

            for ksw_c = 1 : size( ksw_nodeList, 1 )
                fprintf( fid, '\t\t\t<node id=\"%d\" radius=\"%.6f\" x=\"%d\" y=\"%d\" z=\"%d\" inVp=\"%d\" inMag=\"%d\" time=\"%d\"/>\n', ...
                    ksw_skeleton{kl_thingC}.nodesNumDataAll( ksw_c, 1 ), ...
                    ksw_nodeList( ksw_c, 2 ), ksw_nodeList( ksw_c, 3 ), ...
                    ksw_nodeList( ksw_c, 4 ), ksw_nodeList( ksw_c, 5 ), ksw_nodeList( ksw_c, 6 ), ...
                    ksw_nodeList( ksw_c, 7 ), ksw_nodeList( ksw_c, 8 ) );
            end
            % get data source information
            if thing1_available == 0
                thing1_start = ksw_skeleton{kl_thingC}.thingID;
                thing1_end = ksw_skeleton{kl_thingC}.thingID;
                thing1_available = 1;
            else
                if ksw_skeleton{kl_thingC}.thingID < thing1_start
                    thing1_start = ksw_skeleton{kl_thingC}.thingID;
                end
                if ksw_skeleton{kl_thingC}.thingID > thing1_end
                    thing1_end = ksw_skeleton{kl_thingC}.thingID;
                end
            end
            
        else
          
            ksw_nodeList = ksw_skeleton{kl_thingC}.nodes;
        
            % Write each node successively into the file.
            for ksw_c = 1 : size( ksw_nodeList, 1 )
                fprintf( fid, '\t\t\t<node id=\"%d\" radius=\"%.6f\" x=\"%d\" y=\"%d\" z=\"%d\"/>\n', ...
                    str2double( ksw_skeleton{kl_thingC}.nodesAsStruct{ksw_c}.id ), ...
                    ksw_nodeList( ksw_c, 4 ), ksw_nodeList( ksw_c, 1 ), ...
                    ksw_nodeList( ksw_c, 2 ), ksw_nodeList( ksw_c, 3 ) );
            end
            % get data source information
            if thing2_available == 0
                thing2_start = ksw_skeleton{kl_thingC}.thingID;
                thing2_end = ksw_skeleton{kl_thingC}.thingID;
                thing2_available = 1;
            else
                if ksw_skeleton{kl_thingC}.thingID < thing2_start
                    thing2_start = ksw_skeleton{kl_thingC}.thingID;
                end
                if ksw_skeleton{kl_thingC}.thingID > thing2_end
                    thing2_end = ksw_skeleton{kl_thingC}.thingID;
                end
            end

        end
               
        fprintf( fid, '\t\t</nodes>' );
        
        % Start with writing the edges into the file. If the matrix does
        % not exist or is empty, simply write 'edges' into the file.
        if ~isfield( ksw_skeleton{kl_thingC}, 'edges' ) || isempty( ksw_skeleton{kl_thingC}.edges )
            fprintf( fid, '\n\t\t<edges/>' );
        
        % If edges is a structure array, write the edges successively into
        % the file.
        else
            fprintf( fid, '\n\t\t<edges>\n' );
            
            if isfield( ksw_skeleton{kl_thingC}, 'nodesNumDataAll' ) && ~isempty( ksw_skeleton{kl_thingC}.nodesNumDataAll ) 
                for ksw_ec = 1 : size( ksw_skeleton{kl_thingC}.edges, 1 )
                    fprintf( fid, '\t\t\t<edge source=\"%d\" target=\"%d\"/>\n', ...
                        ksw_skeleton{kl_thingC}.nodesNumDataAll( ksw_skeleton{kl_thingC}.edges( ksw_ec, 1 ), 1), ...
                        ksw_skeleton{kl_thingC}.nodesNumDataAll( ksw_skeleton{kl_thingC}.edges( ksw_ec, 2 ), 1) );
                end
            else
                for ksw_ec = 1 : size( ksw_skeleton{kl_thingC}.edges, 1 )
                    fprintf( fid, '\t\t\t<edge source=\"%s\" target=\"%s\"/>\n', ...
                        ksw_skeleton{kl_thingC}.nodesAsStruct{ ksw_skeleton{kl_thingC}.edges( ksw_ec, 1 ) }.id, ...
                        ksw_skeleton{kl_thingC}.nodesAsStruct{ ksw_skeleton{kl_thingC}.edges( ksw_ec, 2 ) }.id );
                end
            end
            
            fprintf( fid, '\t\t</edges>' );
        end

        % Change kl_totalNodeC to let the node id start at the right number
        % if multiple skeletons exist.
        kl_totalNodeC = kl_totalNodeC + size( ksw_nodeList, 1 );
        fprintf( fid, '\n\t</thing>\n' );
    end
    
    % print data source information
    % -----------------------------
    if thing1_available ~= 0
        fprintf( 'Data source (thing %d', thing1_start );
        if thing1_end ~= thing1_start
            fprintf( '-%d', thing1_end );
        end
        fprintf( '): nodesNumDataAll -> id,radius,x,y,z,inVp,inMap,time\n' );
    end
    if thing2_available ~= 0
        fprintf( 'Data source (thing %d', thing2_start );
        if thing2_end ~= thing2_start
            fprintf( '-%d', thing2_end );
        end
        fprintf( '): nodesAsStruct -> id  /  nodes -> radius,x,y,z\n' );
    end

    % version 1.06
    % Write branchpoints (all branchpoints are attached to the first cell element)
    if isfield( ksw_skeleton{1}, 'branchpoints' ) && ~isempty( ksw_skeleton{1}.branchpoints )
        fprintf( fid, '\t<branchpoints>\n' );
        for ksw_c = 1 : size( ksw_skeleton{1}.branchpoints, 1 )
            fprintf( fid, '\t\t<branchpoint id=\"%d\"/>\n', ...
                    ksw_skeleton{1}.branchpoints( ksw_c ) );
        end
        fprintf( fid, '\t</branchpoints>\n' );
    end

%    % version 1.01   comments are saved if available in the skeleton as a huge string 
%    % Write the comments in commentsString into the file (current version of saving)
%    if iscell( ksw_skeleton{1}.commentsString )
%        fprintf( fid, ksw_skeleton{1}.commentsString{1} );
%        fprintf( fid, '\n' );
%    end

    % version 1.02   comments are saved from NodesAsStruct attribute 
    % Write the comments in nodesAsStruct into the file
    % first run: get ids of comments
    numberOfComments = 0;
    for kl_thingC = 1 : size( ksw_skeleton, 2 )
        for ksw_c = 1 : size( ksw_skeleton{kl_thingC}.nodesAsStruct, 2 )
            if ~strcmp( ksw_skeleton{kl_thingC}.nodesAsStruct{ksw_c}.comment, '' )
                if numberOfComments == 0
                    % create first comment
                    commentIds = [str2double(ksw_skeleton{kl_thingC}.nodesAsStruct{ksw_c}.id) kl_thingC ksw_c];
                else
                    % append following comments
                    commentIds = vertcat( commentIds, [str2double(ksw_skeleton{kl_thingC}.nodesAsStruct{ksw_c}.id) kl_thingC ksw_c] );
                end
                numberOfComments = numberOfComments + 1;
            end
        end
    end
    % second run: store ids
    fprintf( fid, '\t<comments>\n' );
    if numberOfComments > 0
        % sort comments by node id
        commentIdsSorted = sortrows(commentIds, 1);
        for comments_c = 1 : numberOfComments
            fprintf( fid, '\t\t<comment node=\"%d\" content=\"%s\"/>\n', ...
                commentIdsSorted( comments_c, 1 ), ...
                ksw_skeleton{commentIdsSorted( comments_c, 2 )}.nodesAsStruct{commentIdsSorted( comments_c, 3 )}.comment );
        end
    end
    fprintf( fid, '\t</comments>\n' );

%     % Write the comments into the file (new version of saving). The node count
%     % in the comments and the node id will match even with multiple tracings.
%     if iscell( ksw_skeleton{kl_thingC}.commentsString )
%         
%         kl_totalNodeC = 0;
%         fprintf( fid, '\t<comments>\n' );
%         
%         % Go over all the tracings.
%         for kl_thingC = 1 : size( ksw_skeleton, 2 )
%             
%             % Extract each single comment and write it into a cell array.
%             ksw_comments = ksw_skeleton{1}.commentsString{1}( 17 : ( end - 15) );
%             ksw_comments = regexp( ksw_comments, '<\w+ [^<]*/>', 'match' );
%             
%             for ksw_c = 1 : size( ksw_comments , 2)
%                 
%                 % Extract the node id from the comments string.
%                 ksw_nodeId = regexp( ksw_comments{ksw_c}, '"\d+"', 'match' );
%                 ksw_nodeId = str2double( ksw_nodeId{1}( 2 : ( end - 1 ) ) );
%                 
%                 % Convert the node id into the current one.
%                 if ksw_nodeId ~= 1    
%                     ksw_nodeId = size( ksw_skeleton{kl_thingC}.nodes, 1 ) - ( ksw_nodeId - 2 );
%                     ksw_nodeId = ksw_nodeId + kl_totalNodeC;                    
%                 end
%                 
%                 if ksw_nodeId == 1 && kl_totalNodeC ~= 0
%                    ksw_nodeId = kl_totalNodeC + 1; 
%                 end
%                 
%                 % Extract the comment from whole comments string.
%                 ksw_comment = regexp( ksw_comments{ksw_c}, '"[ a-z????A-Z???]+"', 'match' );
%                 
%                 % Write the comment into the file.
%                 if ~isempty(ksw_comment)
%                     fprintf( fid, '\t\t<comment node=\"%d\" content=%s/>\n',...
%                         ksw_nodeId, ksw_comment{1} );
%                 end
%                 
%             end
%             
%             % Increase kl_totalNodeC analogously.
%             kl_totalNodeC = kl_totalNodeC + size( ksw_skeleton{kl_thingC}.nodes, 1 );
%         end 
%         
%         fprintf( fid, '\t</comments>\n' );
%     end
%     
%     % Write the comments into the file (old version of saving)
%     if isfield( ksw_skeleton{1}, 'comments' )
%         fprintf( fid, '\t<comments>\n' );
%         
%         for kl_cc = 1 : size( ksw_skeleton{1}.comments, 1 )
%             fprintf( fid, '\t\t<comment node=\"%d\" content=\"%s\"/>\n', ...
%                  ksw_skeleton{1}.comments{ kl_cc, 1 }, ksw_skeleton{1}.comments{ kl_cc, 2 } );
%         end
%         
%         fprintf( fid, '\t</comments>\n' );
%     end
    
    % Write the last line, then close the file. 
    fprintf( fid, '</things>\n' );
    fclose( fid );
    
    % Print on the screen.
    fprintf( 'Done writing!\n' );
    
end
