function output = readNml( fname, keepNodeAsStruct )

% READNML: Read .nml files from Knossos or Oxalis into Matlab
%   
%   The function has the following arguments:
%       FNAME: Give the complete path of the file you want to read as a
%           string, e.g. 'E:\e_k0563\ribbons\skeleton_seeds\All_ek0563_Skeletons\ek0563-seed0001-khaase.002.nml'
%       KEEPNODEASSTRUCT: Optional! Standard version is 1. The numbers 0 or 1 indicate
%           whether the nodes should be saved as a struct additionally.
%       
%   => readNml( 'E:\e_k0563\ribbons\skeleton_seeds\All_ek0563_Skeletons\ek0563-seed0001-khaase.002.nml', 1 )
%

    % changes:
    % matches .nml format on (27/02/2010)
    % loads all tags per node (28/06/2010)
    % reads Oxalis .nml files (19/01/2013)
    % bugfix: transpose matrix for single edges (12/03/2013)

    % general functions for XML parsing
    % read elements
    function elements = get_xml_elements( content, element_name )
        elements = regexp( content, strcat( '<', element_name, '([\s][^>/]*)?/>|<', element_name, '([\s][^>]*)?>.*?</', element_name, '>' ), 'match' );
    end
    % read element string and remove leading and trailing spaces
    function element_string = get_xml_element_as_string( content, element_name )
        element_string = regexp( content, strcat( '<', element_name, '([\s][^>]*)?>([\s]*)[^\s].*</', element_name, '>' ), 'match' );
        element_string = regexprep( element_string, strcat( '<[/]?', element_name, '([\s][^>]*)?>' ), '' );
        element_string = strtrim( element_string );
    end
    % read subelements of a given element into struct
    function element_struct = get_xml_element_as_struct( content, element_name )
        element_string = regexp( content, strcat( '<', element_name, '>.*</', element_name, '>' ), 'match' );
        element_string = regexprep( element_string, strcat( '<[/]?', element_name, '>' ), '' );
        elements = regexp( element_string{1}, '<\w+ [^<]*/>|<\w+ [^<]*></\w+>', 'match' );
        element_struct = struct();
        % write all elements in a struct.
        for count_elements = 1 : size( elements, 2 )
            element_name = strrep( regexp( elements{ count_elements }, '<\w+', 'match' ), '<','' );
            attribute_string = regexp( elements{ count_elements }, '(\w+)=([^\s/>]+)', 'match' );
            for count_attributes = 1 : size( attribute_string, 2 )
                attribute = regexp( attribute_string{ count_attributes }, '=', 'split' );
                element_struct.( element_name{1} ).( attribute{1} ) = strrep( attribute{2}, '"', '' );
            end
        end
    end
    % get attribute string of an element
    function attribute_string = get_xml_attributes_as_string( content, element_name )
        element_string = regexp( content, strcat( '<', element_name, '[\s].*?/?>' ), 'match' );
        attribute_string = strtrim( regexprep( element_string, strcat( '<', element_name, '[\s]|/>$|>$' ), '' ) );
        attribute_string = attribute_string{1};
    end
    % get a specific attribute of an element
    % method: find string from element name to given attribute value, then remove string from elementname to attribute name, result: attribute value
    function attribute = get_xml_attribute( content, element_name, attibute_name )
        element_and_attribute = regexp( content, strcat( '<', element_name, '[\s].*?', attibute_name, '.*?=[\s]*".*?"[\s/>]|', ...
                                                         '<', element_name, '[\s].*?', attibute_name, '.*?=[\s]*''.*?''[\s/>]'), 'match' );
        attribute_with_apostrophes = strtrim( regexprep( element_and_attribute, strcat( '<', element_name, '[\s].*?', attibute_name, '.*?=[\s]*' ), '' ) );
        attribute_with_leading_apostrophe = regexprep( attribute_with_apostrophes, '"$|''$|">$|''>$|"/$|''/$', '' );
        attribute = regexprep( attribute_with_leading_apostrophe, '^"|^''', '' );
    end


    % ---------------------------------
    %        MAIN FUNCTION
    % ---------------------------------
    % If no path is given, open the console to select a file.
    if nargin < 1
        fname = '';
        [filename, pathname] = uigetfile;
        if filename ~= 0        
            fname = fullfile( pathname, filename );
        end
    end
    
    % Save nodes as struct if not indicated otherwise
    if nargin < 2
        keepNodeAsStruct = 1;
    end
    
    % Load the whole .nml file into Matlab as a huge string
    if ~isempty( fname )
        fid = fopen( fname, 'r' );
        content = fscanf( fid, '%c' );
        fclose( fid );

        % read section PARAMETERS from content and split it into several separate cells and write parameters struct into output struct
        parameters = get_xml_element_as_struct( content, 'parameters');

        % write section COMMENTS from content into output struct
        commentsString = get_xml_element_as_string( content, 'comments');

        % read section THING from content
        thing = get_xml_elements( content, 'thing');
        
        output = cell(1, size( thing, 2 ));
        output{1}.parameters=parameters;
        output{1}.commentsString=commentsString;
        % Write all nodes and edges into the output struct 
        for count_thing = 1 : size( thing, 2 )
            
            % Write each node individually into a cell and fill up the
            % related space in the output struct with zeros
            %output{count_thing} = struct('nodes',[],'edges',[]);
            krk_theseNodes = get_xml_elements( thing{count_thing}, 'node');
            output{count_thing}.nodes = zeros( [size( krk_theseNodes, 2 ), 5] );
            
            % Write now each node successively into the output struct
            for krk_nc = 1 : size( krk_theseNodes, 2 )
                krk_thisNode = regexp( krk_theseNodes{krk_nc}, '\".+?\"', 'match');

                id     = str2double( get_xml_attribute( krk_theseNodes{krk_nc}, 'node', 'id' ) );
                radius = str2double( get_xml_attribute( krk_theseNodes{krk_nc}, 'node', 'radius' ) );
                x      = str2double( get_xml_attribute( krk_theseNodes{krk_nc}, 'node', 'x' ) );
                y      = str2double( get_xml_attribute( krk_theseNodes{krk_nc}, 'node', 'y' ) );
                z      = str2double( get_xml_attribute( krk_theseNodes{krk_nc}, 'node', 'z' ) );
                inVp   = str2double( get_xml_attribute( krk_theseNodes{krk_nc}, 'node', 'inVp' ) );
                inMag  = str2double( get_xml_attribute( krk_theseNodes{krk_nc}, 'node', 'inMag' ) );
                time   = str2double( get_xml_attribute( krk_theseNodes{krk_nc}, 'node', 'time' ) );

                output{count_thing}.nodes( krk_nc, : ) = [ id, radius, x, y, z ];

                krk_thisNodeTags = regexprep( regexp( get_xml_attributes_as_string( krk_theseNodes{krk_nc}, 'node' ), '[ =]', 'split' ), '["</>]', '' );

                % optionally write nodes also as struct into the output struct
                if keepNodeAsStruct > 0
                    output{count_thing}.nodesAsStruct{krk_nc} = struct( krk_thisNodeTags{1 : end} );
                end
                
                % Write only the numerical values of the nodes into a separate part of the output struct
                output{count_thing}.nodesNumDataAll( krk_nc, 1 : 8 ) = [ id, radius, x, y, z, inVp, inMag, time ];
                
                % In the first run, allocate the matrix for the numerical values with zeros
                if krk_nc == 1
                    output{count_thing}.nodesNumDataAll( size( krk_theseNodes, 2 ), 1) = 0;
                end
            end
            
            % Create an array with the property: a[node ID] = number of loop cycles,
            % equivalent to a[n] = max(a) - n + 2 for all but a[1] = 1
            krk_nodeIDconversion = zeros( size( krk_theseNodes, 2 ), 1 );
            krk_nodeIDconversion_all = zeros( size( krk_theseNodes, 2 ), 2 );
            
            for krk_nc = 1 : size( krk_theseNodes, 2 )
                krk_nodeIDconversion( output{count_thing}.nodes( krk_nc, 1 ) ) = krk_nc;
                krk_nodeIDconversion_all( output{count_thing}.nodes( krk_nc, 1 ), 1 : 2 ) = [count_thing, krk_nc];
            end

            % Write each edge individually into a cell and fill up the
            % related space in the output struct with zeros
            krk_theseEdges = get_xml_elements( thing{count_thing}, 'edge');
            output{count_thing}.edges = zeros( [size( krk_theseEdges, 2 ), 2] );
            
            % Write now each edge successively into the output struct
            for krk_nc = 1 : size( krk_theseEdges, 2 )
                source = str2double( get_xml_attribute( krk_theseEdges{krk_nc}, 'edge', 'source' ) );
                target = str2double( get_xml_attribute( krk_theseEdges{krk_nc}, 'edge', 'target' ) );
                output{count_thing}.edges( krk_nc, : ) =  [ source, target ];
            end

            % "Invert" the values of .edges
            % (if there is just 1 only egde matrix has to be transposed)
            if size(output{count_thing}.edges, 1) == 1
                output{count_thing}.edges = krk_nodeIDconversion( output{count_thing}.edges )';
            else
                output{count_thing}.edges = krk_nodeIDconversion( output{count_thing}.edges );
            end
            % Change the columns of the nodes matrix: Delete [1], put [2] to the end
            output{count_thing}.nodes = output{count_thing}.nodes( :, [3 : 5, 2] );

            output{count_thing}.thingID = str2double( get_xml_attribute( thing{count_thing}, 'thing', 'id' ) );

        end

        % Read the part BRANCHPOINTS from krk_contents
        output{1}.branchpointsString = get_xml_element_as_string( content, 'branchpoints');
        output{1}.branchpoints = [];        
        
        if ~isempty( output{1}.branchpointsString )
            % store id of the branchpoints
            branchpoints = get_xml_elements( content, 'branchpoint');
            for count_branchpoint = 1 : size( branchpoints, 2 )
                branchpoint_ids(count_branchpoint) = str2double( get_xml_attribute( branchpoints{count_branchpoint}, 'branchpoint', 'id' ) );
            end
            
            % Leave out the first cell, then "invert" the id of the branchpoints
            if length( branchpoint_ids ) > 1
                branchpoints_valid = branchpoint_ids( 2 : end );
                branchpoints_valid = branchpoints_valid( branchpoints_valid <= size( krk_nodeIDconversion_all, 1 ) );
                output{1}.branchpoints = krk_nodeIDconversion_all( branchpoints_valid, : );        
            end        
        end

    end
end