function LLSegmentsInView_cellArray = fcn_OSM2SHP_plotNetworkAtLocation(LLSegments_cellArray, mapCenter, zoomLevel, varargin)
%% fcn_OSM2SHP_plotNetworkAtLocation
% 
% This code extracts network graph given the LL and Segment IDs of a
% network.
% 
% FORMAT:
%
%       LLSegmentsInView_cellArray = fcn_OSM2SHP_plotNetworkAtLocation(LLSegments_matrix, (figNum))
%
% INPUTS:
% 
%      LLSegments_cellArray: a cell array containing
%
%            [Latitude Longitude SegmentNumber] 
%
%      for each segment.
%
%      mapCenter: the LL coordinates as [1 x 2] vector representing the
%      center of the view
%
%      zoomLevel: the zoomLevel to use
% 
%      (OPTIONAL INPUTS)
%
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      LLSegmentsInView_cellArray: a cell array that includes only segments
%      within the current view
%
% DEPENDENCIES:
%
%      
%
% EXAMPLES:
%
%       See the script:
%
%       script_test_fcn_OSM2SHP_plotNetworkAtLocation.m 
%
%       for a full test suite.
%
% This function was written on 2026_03_14 by Sean Brennan, sbrennan@psu.edu
% Questions or comments? sbrennan@psu.edu


% REVISION HISTORY:
%
% 2026_03_14 by Sean Brennan, sbrennan@psu.edu
% - In fcn_OSM2SHP_plotNetworkAtLocation
%   % * Wrote the code originally
%
% 2026_03_18 by Sean Brennan, sbrennan@psu.edu
% - In fcn_OSM2SHP_plotNetworkAtLocation
%   % * Fixed bug where empty colors threw errors
%
% 2026_03_19 by Sean Brennan, sbrennan@psu.edu
% - In fcn_OSM2SHP_plotNetworkAtLocation
%   % * Added small black dot to middle of plotted point, to see path
%   %   % points
% 
% 2026_06_06 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_OSM2SHP_plotNetworkAtLocation
%   % * Moved this function from PennDOTSHP to OSM2SHP

% TO-DO:
%
% 2026_03_14 bySean Brennan, sbrennan@psu.edu
% - Add DebugTools options to check the inputs


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 4; % The largest Number of argument inputs to the function
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
    debug_figNum = []; 
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
        narginchk(3,MAX_NARGIN);
    end
end


% Check to see if user specifies figNum?
flag_do_plots = 1; % Default is show plots
figNum = [];
if (0==flag_max_speed) && (MAX_NARGIN == nargin) 
    temp = varargin{end};
    if ~isempty(temp)
        figNum = temp;
        flag_do_plots = 1;
    end
end

if isempty(figNum)
	temp_h = figure;
	figNum = get(temp_h,'Number');
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
	% Open an empty geoplot and zoom into location
	LLdata = [];
	plotFormat = [];
	fcn_plotRoad_plotLL((LLdata), (plotFormat), (figNum));
	set(gca, 'MapCenter', mapCenter, 'zoomLevel', zoomLevel);

	% Pull out ONLY data in this view
	h_gca = gca;
	latLims = get(h_gca,'LatitudeLimits');
	lonLims = get(h_gca,'LongitudeLimits');

	Nsegments = length(LLSegments_cellArray);

	NSegmentsInThisView = 0;
	flagThisSegmentInView = false(Nsegments,1);
	for ith_segment = 1:Nsegments
		try
			locationsInThisSegment = LLSegments_cellArray{ith_segment}(:,1:2);
		catch
			error('Unknown problem encountered where index was out of bounds');
		end

		if ...
				any(locationsInThisSegment(:,1)>=latLims(1)) && ...
				any(locationsInThisSegment(:,1)<=latLims(2)) && ...
				any(locationsInThisSegment(:,2)>=lonLims(1)) && ...
				any(locationsInThisSegment(:,2)<=lonLims(2))

			NSegmentsInThisView = NSegmentsInThisView+1;
			flagThisSegmentInView(ith_segment) = true;
		end
	end

	LLSegmentsInView_cellArray = LLSegments_cellArray(flagThisSegmentInView);
	LLSegmentsInView_matrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(LLSegmentsInView_cellArray,(-1));

	% Find first and last row indices
	nanRows = find(isnan(LLSegmentsInView_matrix(:,1)));
	firstRows = [1; nanRows(1:end-1)+1];
	lastRows = (nanRows-1);


	% Plot these segments
	plotFormat.Color = [0 0.7 0];
	plotFormat.Marker = '.';
	plotFormat.MarkerSize = 20;
	plotFormat.LineStyle = '-';
	plotFormat.LineWidth = 3;
	plotFormat.DisplayName = 'OSM2';

	% Get the colorOrder
	ax = gca;
	colorOrder = ax.ColorOrder;
	Ncolors = size(colorOrder,1);

	segmentNumber = LLSegmentsInView_matrix(:,3);
	colorIndex = mod(segmentNumber-1,Ncolors)+1;
	LLIdata = [LLSegmentsInView_matrix(:,1:2) colorIndex];

	if 1==1
		segmentNumber = LLSegmentsInView_matrix(firstRows,3);
		colorIndexSegmentOnly = mod(segmentNumber-1,Ncolors)+1;

		clear h_plot
		clear plotFormat
		plotFormat.Marker = '.';
		plotFormat.LineStyle = '-';

		h_plot = nan(Ncolors,1);
		for ith_color = 1:Ncolors
			thisSegments = colorIndexSegmentOnly==ith_color;
			plotData_cellArray = LLSegmentsInView_cellArray(thisSegments);
			plotData_matrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(plotData_cellArray);

			if ~isempty(plotData_matrix)
				plotFormat.Color = colorOrder(ith_color,:);
				plotFormat.MarkerSize = (Ncolors-1)*5+20 - (ith_color-1)*5;
				plotFormat.LineStyle = '-';
				plotFormat.LineWidth = 3 + (Ncolors-1)*2 - (ith_color-1)*2;
				h_plot(ith_color) = fcn_plotRoad_plotLL(plotData_matrix(:,1:2), (plotFormat), (figNum));
			end
		end
	else
		[h_plot, indiciesInEachPlot]  = fcn_plotRoad_plotLLI(LLIdata, (plotFormat),  (colorOrder), (figNum)); %#ok<ASGLU>
    end

    % Plot small dot points
    clear plotFormat
    plotFormat.Marker = '.';
    plotFormat.LineStyle = 'none';
    plotFormat.Color = [0 0 0];
    plotFormat.MarkerSize = 5;
    plotFormat.HandleVisibility = 'off';
	fcn_plotRoad_plotLL(LLSegmentsInView_matrix(:,1:2), (plotFormat), (figNum));



	% Plot first points as large green
	clear plotFormat
	plotFormat.Color = [0 1 0];
	plotFormat.Marker = '.';
	plotFormat.MarkerSize = 50;
	plotFormat.LineStyle = '-';
	plotFormat.LineWidth = 1;
	temp = [LLIdata(firstRows,1:2), LLIdata(firstRows+1,1:2), [nan nan].*LLIdata(firstRows,1:2)];
	xdata = temp(:,[1 3 5]);
	plottingX = reshape(xdata',[],1);
	ydata = temp(:,[2 4 6]);
	plottingY = reshape(ydata',[],1);
	fcn_plotRoad_plotLL([plottingX plottingY], (plotFormat), (figNum));

	% Plot last points as smaller red
	plotFormat.Color = [1 0 0];
	plotFormat.Marker = '.';
	plotFormat.LineStyle = 'none';
	plotFormat.MarkerSize = 10;
	fcn_plotRoad_plotLL((LLIdata(lastRows,1:2)), (plotFormat), (figNum));

	%% Number the segments?
	if 1==1
		NsegmentsInView = length(LLSegmentsInView_cellArray);
		locations = nan(NsegmentsInView,2);
		textNames = strings(NsegmentsInView,1);


		colorsEachSegment = colorIndex(firstRows,:);

		for ith_segment = 1:NsegmentsInView
			locationsInThisSegment = LLSegmentsInView_cellArray{ith_segment}(:,1:2);
			thisSegmentNumber = LLSegmentsInView_cellArray{ith_segment}(1,3);

			% Find the location to plot
			NrowsThisSegment = size(locationsInThisSegment,1);
			if NrowsThisSegment>4
				% Find middle-most row. Use this to label segment location.
				middleIndex = floor(NrowsThisSegment/2);
				locations(ith_segment,:) = locationsInThisSegment(middleIndex,1:2);
			else
				% Take average
				locations(ith_segment,:) = mean(locationsInThisSegment(:,1:2),1,'omitmissing');
			end

			% Define the text to show
			textNames(ith_segment,:) = sprintf('%.0f',thisSegmentNumber);

			% % Find color used for segment plotting, and save it. It is
			% % used later for putting text labels on.
			% minDist = inf;
			% for ith_plot = 1:length(h_plot)
			% 	latData = get(h_plot(ith_plot),'LatitudeData')';
			% 	minStart = min(abs(latData-locationsInThisSegment(1,1)));
			% 	minEnd = min(abs(latData-locationsInThisSegment(end,1)));
			% 	thisMin = minStart+minEnd;
			% 	if thisMin<minDist
			% 		minDist = thisMin;
			% 		colorsUsed(NSegmentsInThisView,:) = get(h_plot(ith_plot),'Color');
			% 	end
			% end
		end

		% % Match colorsUsed to colorOrder list
		% for ith_color = 1:size(colorOrder,1)
		% 	matchedIndices = all(colorsUsed==colorOrder(ith_color,:),2);
		% 	colorIndexUsed(matchedIndices,1) = ith_color;
		% end
		colorIndexUsed = colorsEachSegment;

		h_axis = gca;
		h_axis.Clipping = 'on';
		% h_axis.ClippingStyle = 'rectangle';

		if 1==0
			% Black text
			text(locations(:,1), locations(:,2), textNames, 'FontSize', 8, 'Color', [0 0 0], 'BackgroundColor',[1 1 1], ...
				'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle','Clipping','on');

		else
			% Text color matches segment color
			for ith_color = 1:Ncolors
				thisColorIndices = find(colorIndexUsed==ith_color);
				textColor = colorOrder(ith_color,:);
				thisLocations = locations(thisColorIndices,:);
				thisTexts = textNames(thisColorIndices,:);
				text(thisLocations(:,1), thisLocations(:,2), thisTexts, 'FontSize', 8, 'Color', textColor, 'BackgroundColor',[1 1 1], ...
					'HorizontalAlignment', 'left', 'VerticalAlignment', 'top','Clipping','on');
			end
		end

	end
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
