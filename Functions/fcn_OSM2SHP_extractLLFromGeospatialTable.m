function [LLSegments_matrix, LLSegments_cellArray] = fcn_OSM2SHP_extractLLFromGeospatialTable(geospatialTable, varargin)
%% fcn_OSM2SHP_extractLLFromGeospatialTable
% 
% This code extracts latitude–longitude vertex coordinates from each
% OpenStreetMap road segment stored in a geospatial table, removes
% duplicate vertices within individual segments, and concatenates all
% segment coordinates into a single array separated by NaN rows for easy
% downstream processing.
% 
% FORMAT:
%
%       [LLCoordinate_allSegments, LL_allSegments_cell] = fcn_OSM2SHP_extractLLFromGeospatialTable(geospatialTable, (figNum))
%
% INPUTS:
% 
%      geospatialTable: A geospatial table is a structured dataset—similar
%      to a traditional database table or spreadsheet—that includes
%      specialized columns for geographic information.
%
%      (OPTIONAL INPUTS)
%
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      LLCoordinate_allSegments: [N x 2] matrix of LL coordinates of all
%      road segments in a geospatial table 
% 
%      LL_allSegments_cell: Cell array of LL coordinates of all
%      road segments in a geospatial table 
%
% DEPENDENCIES:
%
%      
%
% EXAMPLES:
%
%       See the script:
%
%       script_test_fcn_OSM2SHP_extractLLFromGeospatialTable.m 
%
%       for a full test suite.
%
% This function was written on 2026_02_03 by Aneesh Batchu
% Questions or comments? abb6486@psu.edu or snb10@psu.edu


% REVISION HISTORY:
%
% 2026_02_03 by Aneesh Batchu, abb6486@psu.edu
% - Wrote the code originally
%
% 2026_02_07 by Sean Brennan, sbrennan@psu.edu
% - In fcn_OSM2SHP_extractLLFromGeospatialTable 
%   % * Added plotting in debugging area to show both types fo data
% 
% 2026_02_09 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_OSM2SHP_extractLLFromGeospatialTable
%   % * Added 'stable' to unique function to preserve order and maintain
%   %   % uniqueness.
%   % * But, commented out the line with unique function and wrote a line
%   %   % without the unique function. Repeated coordinates are 
%   %   % intentionally preserved in road segment geometries to maintain
%   %   % multi-part connectivity and vertex ordering, or because 
%   %   % a road segment may revisit the same location 
%   %   % (e.g., loops or self-intersections).

% TO-DO:
%
% 2026_02_03 by Aneesh Batchu, abb6486@psu.edu
% - Add DebugTools options to check the inputs
%
% 2026_02_07 by Sean Brennan, sbrennan@psu.edu
% - In fcn_OSM2SHP_extractLLFromGeospatialTable
%   % There's a bug in the function where the unique LLA values are being
%   % reordered in a weird way, causing plots to jump back/forth on same
%   % segments. See Demo case 1


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 2; % The largest Number of argument inputs to the function
flag_max_speed = 0;
if (nargin==MAX_NARGIN && isequal(varargin{end},-1))
    flag_do_debug = 0; %     % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; %     % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_OSM2SHP_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_OSM2SHP_FLAG_CHECK_INPUTS");
    MATLABFLAG_OSM2SHP_FLAG_DO_DEBUG = getenv("MATLABFLAG_OSM2SHP_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_OSM2SHP_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_OSM2SHP_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_OSM2SHP_FLAG_DO_DEBUG); 
        flag_check_inputs  = str2double(MATLABFLAG_OSM2SHP_FLAG_CHECK_INPUTS);
    end
end

% flag_do_debug = 1;

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
    debug_figNum = 999978; %#ok<NASGU>
else
    debug_figNum = []; %#ok<NASGU>
end

%% check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if 0 == flag_max_speed
    if flag_check_inputs == 1
        % Are there the right number of inputs?
        narginchk(1,MAX_NARGIN);


    end
end


% Check to see if user specifies figNum?
flag_do_plots = 0; % Default is to NOT show plots
if (0==flag_max_speed) && (MAX_NARGIN == nargin) 
    temp = varargin{end};
    if ~isempty(temp)
        figNum = temp;
        flag_do_plots = 1;
    end
end


%% Main code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tic
% Get shapes of all road segments
shapes_allSegments = geospatialTable.Shape;

% Extract the unique coordinates (latitude and longitude) from each road
% segment and save them in a cell array. 
% 
% Note: OSM polylines often contain repeated vertices (especially where
% segments join, or when data is simplified/edited).
% LL_allSegments_cell = arrayfun(@(ith_shape) ...
%     unique([ith_shape.InternalData.VertexCoordinate1(:), ith_shape.InternalData.VertexCoordinate2(:)], 'rows', 'stable'), ...
%     shapes_allSegments, ...
%     'UniformOutput', false);

LLSegments_cellArray_withEmpty = arrayfun(@(ith_shape) ...
    [ith_shape.InternalData.VertexCoordinate1(:), ith_shape.InternalData.VertexCoordinate2(:)], ...
    shapes_allSegments, ...
    'UniformOutput', false);

% Append the segment ID (the row number) onto each entry
LLSeg_allSegments_cell_withEmpty = fcn_INTERNAL_appendRowIndexColumn(LLSegments_cellArray_withEmpty);

if 1==1
	% Remove empty cell array entries
	mask = cellfun(@isempty, LLSeg_allSegments_cell_withEmpty);  % true for cells containing empty arrays
	LLSegments_cellArray = LLSeg_allSegments_cell_withEmpty(~mask);
else
	LLSegments_cellArray = LLSeg_allSegments_cell_withEmpty;
end

LLSegments_matrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(LLSegments_cellArray, (-1));

% % Seperate each road segment with NaN matrix 
% nan_matrix = [NaN NaN];
% 
% % Convert road segment cell array into matrix and append NaN matrix at the
% % end of each road segment. 
% LLCoordinate_allSegments = cell2mat( ...
%     cellfun(@(ith_segment) [ith_segment; nan_matrix], LLSegments_cellArray, 'UniformOutput', false) ...
% );
% % toc

% Additional comments:
% 
% % This code displays all field names including InternalData
% fieldnames(struct(geospatialTable.Shape(1)))

% % Uncomment to understand what is InternalData
% geoShapeRoadSegment_InternalData = geospatialTable.Shape(1).InternalData;
% 
% whos geoShapeRoadSegment_InternalData
% disp(geoShapeRoadSegment_InternalData)

%% Plot the results (for debugging)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_plots
	figure(figNum);

	subplot(1,2,1);

	plotFormat.Color = [0 0.7 0];
	plotFormat.Marker = '.';
	plotFormat.MarkerSize = 10;
	plotFormat.LineStyle = '-';
	plotFormat.LineWidth = 3;

	fcn_plotRoad_plotLL(LLSegments_matrix,(plotFormat),(figNum));

	% subplot(1,2,2);
	% % Get the colorOrder
	% ax = gca;
	% colorOrder = ax.ColorOrder;
	% Ncolors = size(colorOrder,1); 
	% LLIdata = [];
	% for ith_segment = 1:length(LLSegments_cellArray)
	% 	thisColorIndex = mod(ith_segment-1,Ncolors)+1;
	% 	thisLLdata = LLSegments_cellArray{ith_segment};
	% 	NthisLLdata = size(thisLLdata,1);
	% 	LLIdata = [LLIdata; nan nan nan; [thisLLdata thisColorIndex*ones(NthisLLdata,1)]]; %#ok<AGROW>
	% end
	% [h_plot, indiciesInEachPlot]  = fcn_plotRoad_plotLLI(LLIdata, (plotFormat),  (colorOrder), (figNum)); %#ok<ASGLU>


    subplot(1,2,2);
    % Get the colorOrder
    ax = gca;
    colorOrder = ax.ColorOrder;
    Ncolors = size(colorOrder,1);

    segmentNumber = LLSegments_matrix(:,3);
    colorIndex = mod(segmentNumber-1,Ncolors)+1;
    LLIdata = [LLSegments_matrix(:,1:2) colorIndex];
    [h_plot, indiciesInEachPlot]  = fcn_plotRoad_plotLLI(LLIdata, (plotFormat),  (colorOrder), (figNum)); %#ok<ASGLU>

    % temp = gca;
    % set(temp, 'MapCenter', [40.792665826872089 -77.863991325077109], 'ZoomLevel', 19);  % Intersection between South Atherton and W. College Ave

end

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function

%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§

function Cout = fcn_INTERNAL_appendRowIndexColumn(Cin)
% appendRowIndexColumn  Append a column equal to the cell row index
% Cout = appendRowIndexColumn(Cin)
% For each cell Cin{i,j} that contains a nonempty numeric or logical matrix M,
% Cout{i,j} = [M, repmat(i, size(M,1), 1)].
% Empty matrices are left as-is. Shape of the cell array is preserved.

if ~iscell(Cin)
    error('Input must be a cell array.');
end

[m,n] = size(Cin);
Cout = Cin; % preserve shape and default contents

for ith_cellRow = 1:m
    for jth_cellCol = 1:n
        M = Cin{ith_cellRow,jth_cellCol};
        if isempty(M)
            continue
        end
        if ~(isnumeric(M) || islogical(M))
            error('Cell (%d,%d) does not contain a numeric or logical matrix.', ith_cellRow, jth_cellCol);
        end
        r = size(M,1);
        % If M is a row vector (r==1) or has multiple rows this still works.
        newcol = repmat(ith_cellRow, r, 1);
        Cout{ith_cellRow,jth_cellCol} = [M, newcol];
    end
end
end

