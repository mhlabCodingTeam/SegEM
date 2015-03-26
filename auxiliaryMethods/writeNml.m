function writeNml( ksw_fname, ksw_skeleton )

% *******************************************************************************************************
% * writeNml.m                 NML creator for Knossos and webKnossos (Oxalis)                          *
% * Copyright 2013, 2014, 2015 Max Planck Institute for Brain Research, Frankfurt/Main                  *
% * Version 1.11               Martin Zauser                                                            *
% *******************************************************************************************************


% WRITENML: Write Knossos or webKnossos (Oxalis) skeletons in Matlab as a .nml file
%   
%   The function has the following arguments:
%       KSW_FNAME: Give the full path of the file in which you want to
%           write the data, e.g. 'E:\knossos_skeleton.nml'
%       KSW_SKELETON: Give the name of the cell array containing the
%           skeleton(s), e.g. tracing in the Matlab workspace.
%       
%   => writeNml( 'E:\knossos_skeleton.nml', tracing )
%

% version 1.01               Martin Zauser   comments are saved if available in the skeleton as a huge string 
% version 1.02               Martin Zauser   comments are saved from nodesAsStruct attribute
% version 1.03               Martin Zauser   thingIDs and nodeIds corrected
%                                               (ID from nodesNumDataAll/nodesAsStruct instead of a sequential number) 
% version 1.04               Martin Zauser   renamed to writeNml (former: writeKnossosNml),
%                                                output message informs about data source (nodes / nodesNumDataAll)
% version 1.05               Martin Zauser   writeNml terminates correctly in case nodesNumDataAll does not exist
%                                                or is empty
% version 1.06               Martin Zauser   branchpoint output is now available
% version 1.07               Martin Zauser   name attribute of thing element is provided in output file
% version 1.08               Martin Zauser   nodesAsStruct attribute can be cell or matrix struct 
% version 1.09               Martin Zauser   bugfix: empty comments are now allowed
% version 1.10               Martin Zauser   works also for simple skeletons without nodesAsStruct 
% version 1.11   24.03.2015  Martin Zauser   adaption for e2006 (parameters time, activeNode and editPosition optional)

    % print version on the screen
    fprintf( 'This is writeNml version 1.11, Copyright 2015 MPI for Brain Research, Frankfurt.\n' );

    % Open the file, if it already exists, overwrite the contents.
    fid = fopen( ksw_fname, 'w' );

    % The .nml format is an ASCII file, thus human readable.
    fprintf( fid, '<?xml version=\"1.0\"?>\n' );
    fprintf( fid, '<things>\n' );

    % If ksw_skeleton{1}.parameters is a structure array, continue.
    if isfield( ksw_skeleton{1}, 'parameters' )

        % Read out the necessary information and write the parameters into the output file
        ksw_experimentName = ksw_skeleton{1}.parameters.experiment.name;
        ksw_scale = ksw_skeleton{1}.parameters.scale;
        ksw_offset = ksw_skeleton{1}.parameters.offset;
        fprintf( fid, '\t<parameters>\n\t\t<experiment name=\"%s\"/>\n\t\t<scale x=\"%s\" y=\"%s\" z=\"%s\"/>\n\t\t<offset x=\"%s\" y=\"%s\" z=\"%s\"/>', ...
                      ksw_experimentName, ksw_scale.x, ksw_scale.y, ksw_scale.z, ksw_offset.x, ksw_offset.y, ksw_offset.z );
        clear( 'ksw_experimentName', 'ksw_scale', 'ksw_offset');

        % optional parameters
        if isfield( ksw_skeleton{1}.parameters, 'time' )
            ksw_time = ksw_skeleton{1}.parameters.time.ms;
            fprintf( fid, '\n\t\t<time ms=\"%s\"/>', ksw_time );
            clear( 'ksw_time' );
        end
         if isfield( ksw_skeleton{1}.parameters, 'activeNode' )
            ksw_activeNode = ksw_skeleton{1}.parameters.activeNode.id;
            fprintf( fid, '\n\t\t<activeNode id=\"%s\"/>', ksw_activeNode );
            clear( 'ksw_activeNode' );
        end
        if isfield( ksw_skeleton{1}.parameters, 'editPosition' )
            ksw_editPosition = ksw_skeleton{1}.parameters.editPosition;
            fprintf( fid, '\n\t\t<editPosition x=\"%s\" y=\"%s\" z=\"%s\"/>', ksw_editPosition.x, ksw_editPosition.y, ksw_editPosition.z );
            clear( 'ksw_editPosition' );
        end

        % Write end tag into the file.
        fprintf( fid, '\n\t</parameters>\n' );
    end

    % Necessary if multiple skeletons exist.
    kl_totalNodeC = 0;

    % reset variables for data source message and for nodesAsStruct
    thing1_available = 0;
    thing2_available = 0;
    thing1_start = 0;
    thing1_end = 0;
    thing2_start = 0;
    thing2_end = 0;
    nodesAsStructExists = 0;
    nodesAsStructIsCell = 0;
    % reset ID offset
    nodeIDoffset = 0;
    % time base is available (default)
    time_base = 1;

    % Determine the number of different skeletons and go over each one.
    for kl_thingC = 1 : size( ksw_skeleton, 2 )

        % Check if nodesAsStruct exists
        nodesAsStructExists = 0;
        if isfield( ksw_skeleton{kl_thingC}, 'nodesAsStruct' ) && ~isempty( ksw_skeleton{kl_thingC}.nodesAsStruct )
            nodesAsStructExists = 1;
        end
        
        % Check if nodesAsStruct is a cell or a matrix struct (check property of first tree)
        if kl_thingC == 1
            if nodesAsStructExists
                nodesAsStructIsCell = iscell( ksw_skeleton{1}.nodesAsStruct );
            end
        end

        % get tree ID
        if isfield( ksw_skeleton{kl_thingC}, 'thingID' ) && ~isempty( ksw_skeleton{kl_thingC}.thingID ) 
            thingID = ksw_skeleton{kl_thingC}.thingID;
        else
            thingID = kl_thingC;
        end

        % Start with writing the skeleton ("thing") id into the file.
        fprintf( fid, '\t<thing id=\"%d\"', thingID );
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

            % write node list into file (include time if it is available)
            if size( ksw_nodeList, 2 ) > 7
                % time is available
                for ksw_c = 1 : size( ksw_nodeList, 1 )
                    fprintf( fid, '\t\t\t<node id=\"%d\" radius=\"%.6f\" x=\"%d\" y=\"%d\" z=\"%d\" inVp=\"%d\" inMag=\"%d\" time=\"%d\"/>\n', ...
                        ksw_skeleton{kl_thingC}.nodesNumDataAll( ksw_c, 1 ), ...
                        ksw_nodeList( ksw_c, 2 ), ksw_nodeList( ksw_c, 3 ), ...
                        ksw_nodeList( ksw_c, 4 ), ksw_nodeList( ksw_c, 5 ), ksw_nodeList( ksw_c, 6 ), ...
                        ksw_nodeList( ksw_c, 7 ), ksw_nodeList( ksw_c, 8 ) );
                end
                time_base = 1;
            else
                % time is not available => set time value to zero
                for ksw_c = 1 : size( ksw_nodeList, 1 )
                    fprintf( fid, '\t\t\t<node id=\"%d\" radius=\"%.6f\" x=\"%d\" y=\"%d\" z=\"%d\" inVp=\"%d\" inMag=\"%d\" time=\"%d\"/>\n', ...
                        ksw_skeleton{kl_thingC}.nodesNumDataAll( ksw_c, 1 ), ...
                        ksw_nodeList( ksw_c, 2 ), ksw_nodeList( ksw_c, 3 ), ...
                        ksw_nodeList( ksw_c, 4 ), ksw_nodeList( ksw_c, 5 ), ksw_nodeList( ksw_c, 6 ), ...
                        ksw_nodeList( ksw_c, 7 ), 0 );
                end
                time_base = 0;
            end
            % get data source information
            if thing1_available == 0
                thing1_start = thingID;
                thing1_end = thingID;
                thing1_available = 1;
            else
                if thingID < thing1_start
                    thing1_start = thingID;
                end
                if thingID > thing1_end
                    thing1_end = thingID;
                end
            end

        else

            ksw_nodeList = ksw_skeleton{kl_thingC}.nodes;

            % Write each node successively into the file.
            %   write only if nodesAsStruct exists
            %   if nodesAsStruct is a cell use ...nodesAsStruct{ksw_c}...
            %                    otherwise use ...nodesAsStruct(ksw_c)...
            if ~nodesAsStructExists
                for ksw_c = 1 : size( ksw_nodeList, 1 )
                    % write nodes (all four parameters are zero => node is empty and will not be written)
                    if (ksw_nodeList( ksw_c, 1 ) ~= 0) || (ksw_nodeList( ksw_c, 2 ) ~= 0) || ...
                       (ksw_nodeList( ksw_c, 3 ) ~= 0) || (ksw_nodeList( ksw_c, 4 ) ~= 0)
                        fprintf( fid, '\t\t\t<node id=\"%d\" radius=\"%.6f\" x=\"%d\" y=\"%d\" z=\"%d\" inVp=\"0\" inMag=\"0\" time=\"0\"/>\n', ...
                            ksw_c + nodeIDoffset, ...
                            ksw_nodeList( ksw_c, 4 ), ksw_nodeList( ksw_c, 1 ), ...
                            ksw_nodeList( ksw_c, 2 ), ksw_nodeList( ksw_c, 3 ) );
                    end
                end
            else
                if nodesAsStructIsCell
                    for ksw_c = 1 : size( ksw_nodeList, 1 )
                        fprintf( fid, '\t\t\t<node id=\"%d\" radius=\"%.6f\" x=\"%d\" y=\"%d\" z=\"%d\"/>\n', ...
                            str2double( ksw_skeleton{kl_thingC}.nodesAsStruct{ksw_c}.id ), ...
                            ksw_nodeList( ksw_c, 4 ), ksw_nodeList( ksw_c, 1 ), ...
                            ksw_nodeList( ksw_c, 2 ), ksw_nodeList( ksw_c, 3 ) );
                    end
                else
                    for ksw_c = 1 : size( ksw_nodeList, 1 )
                        fprintf( fid, '\t\t\t<node id=\"%d\" radius=\"%.6f\" x=\"%d\" y=\"%d\" z=\"%d\"/>\n', ...
                            str2double( ksw_skeleton{kl_thingC}.nodesAsStruct(ksw_c).id ), ...
                            ksw_nodeList( ksw_c, 4 ), ksw_nodeList( ksw_c, 1 ), ...
                            ksw_nodeList( ksw_c, 2 ), ksw_nodeList( ksw_c, 3 ) );
                    end
                end
            end
            % get data source information
            if thing2_available == 0
                thing2_start = thingID;
                thing2_end = thingID;
                thing2_available = 1;
            else
                if thingID < thing2_start
                    thing2_start = thingID;
                end
                if thingID > thing2_end
                    thing2_end = thingID;
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

            if ~nodesAsStructExists
                for ksw_ec = 1 : size( ksw_skeleton{kl_thingC}.edges, 1 )
                    fprintf( fid, '\t\t\t<edge source=\"%d\" target=\"%d\"/>\n', ...
                        ksw_skeleton{kl_thingC}.edges( ksw_ec, 1 ) + nodeIDoffset, ...
                        ksw_skeleton{kl_thingC}.edges( ksw_ec, 2 ) + nodeIDoffset);
                end
            else
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
            end

            fprintf( fid, '\t\t</edges>' );
        end

        % Change kl_totalNodeC to let the node id start at the right number
        % if multiple skeletons exist.
        kl_totalNodeC = kl_totalNodeC + size( ksw_nodeList, 1 );
        fprintf( fid, '\n\t</thing>\n' );

        % calculate ID offset (only necessary if nodesAsStruct and therefore single IDs do not exist)
        nodeIDoffset = nodeIDoffset + size( ksw_nodeList, 1 );
    end

    % Check if nodesAsStruct of the first tree exists
    %  => for writing comments the existence of nodesAsStruct of the first tree iss essential
    nodesAsStructExists = 0;
    if isfield( ksw_skeleton{kl_thingC}, 'nodesAsStruct' ) && ~isempty( ksw_skeleton{1}.nodesAsStruct )
        nodesAsStructExists = 1;
    end

    % print data source information
    % -----------------------------
    if thing1_available ~= 0
        fprintf( 'Data source (thing %d', thing1_start );
        if thing1_end ~= thing1_start
            fprintf( '-%d', thing1_end );
        end
        if time_base
            fprintf( '): nodesNumDataAll -> id,radius,x,y,z,inVp,inMap,time\n' );
        else
            fprintf( '): nodesNumDataAll -> id,radius,x,y,z,inVp,inMap\n' );
        end
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

    % version 1.02   comments are saved from NodesAsStruct attribute 
    % Write the comments in nodesAsStruct into the file (if nodesAsStruct exists)
    % first run: get ids of comments
    numberOfComments = 0;
    % if nodesAsStruct is a cell use ...nodesAsStruct{ksw_c}...
    %                  otherwise use ...nodesAsStruct(ksw_c)...
    if nodesAsStructExists
        if nodesAsStructIsCell
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
        else
            for kl_thingC = 1 : size( ksw_skeleton, 2 )
                for ksw_c = 1 : size( ksw_skeleton{kl_thingC}.nodesAsStruct, 2 )
                    if ~strcmp( ksw_skeleton{kl_thingC}.nodesAsStruct(ksw_c).comment, '' )
                        if numberOfComments == 0
                            % create first comment
                            commentIds = [str2double(ksw_skeleton{kl_thingC}.nodesAsStruct(ksw_c).id) kl_thingC ksw_c];
                        else
                            % append following comments
                            commentIds = vertcat( commentIds, [str2double(ksw_skeleton{kl_thingC}.nodesAsStruct(ksw_c).id) kl_thingC ksw_c] );
                        end
                        numberOfComments = numberOfComments + 1;
                    end
                end
            end
        end
    end
    % write comments into file
    if numberOfComments == 0
        % no comments
        fprintf( fid, '\t<comments> </comments>\n' );
    else
        % sort comments by node id
        commentIdsSorted = sortrows(commentIds, 1);
        % second run: store ids
        fprintf( fid, '\t<comments>\n' );
        % if nodesAsStruct is a cell use ...nodesAsStruct{ksw_c}...
        %                  otherwise use ...nodesAsStruct(ksw_c)...
        if nodesAsStructExists
            if nodesAsStructIsCell
                for comments_c = 1 : numberOfComments
                    fprintf( fid, '\t\t<comment node=\"%d\" content=\"%s\"/>\n', ...
                        commentIdsSorted( comments_c, 1 ), ...
                        ksw_skeleton{commentIdsSorted( comments_c, 2 )}.nodesAsStruct{commentIdsSorted( comments_c, 3 )}.comment );
                end
            else
                for comments_c = 1 : numberOfComments
                    fprintf( fid, '\t\t<comment node=\"%d\" content=\"%s\"/>\n', ...
                        commentIdsSorted( comments_c, 1 ), ...
                        ksw_skeleton{commentIdsSorted( comments_c, 2 )}.nodesAsStruct(commentIdsSorted( comments_c, 3 )).comment );
                end
            end
        end
        fprintf( fid, '\t</comments>\n' );
    end

    % Write the last line, then close the file. 
    fprintf( fid, '</things>\n' );
    fclose( fid );

    % Print message onto screen.
    fprintf( 'Done writing!\n' );

end
