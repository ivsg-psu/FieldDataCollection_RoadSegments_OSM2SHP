 %% script_test_fcn_OSM2SHP_plotNetworkAtLocation

% REVISION HISTORY:
%
% 2026_03_16 by Sean Brennan, sbrennan@psu.edu
% - In script_test_fcn_OSM2SHP_plotNetworkAtLocation
%   % * Wrote the code originally
%

% TO-DO:
% 

%% Set up the workspace

close all

%% Code demos start here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____                              ____   __    _____          _
%  |  __ \                            / __ \ / _|  / ____|        | |
%  | |  | | ___ _ __ ___   ___  ___  | |  | | |_  | |     ___   __| | ___
%  | |  | |/ _ \ '_ ` _ \ / _ \/ __| | |  | |  _| | |    / _ \ / _` |/ _ \
%  | |__| |  __/ | | | | | (_) \__ \ | |__| | |   | |___| (_) | (_| |  __/
%  |_____/ \___|_| |_| |_|\___/|___/  \____/|_|    \_____\___/ \__,_|\___|
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Demos%20Of%20Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEMO figures start with 1

close all;
fprintf(1,'Figure: 1XXXX: DEMO cases\n');

%% DEMO case: Plot OSM2 network around Altoona only

figNum = 10001;
titleString = sprintf('DEMO case: Plot OSM network around Altoona only');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

sourceDataFileName = 'OSM_LLcoordinates';
sourceDataFilePath = fullfile(pwd,'LargeData',cat(2,sourceDataFileName,'.mat'));
if exist(sourceDataFilePath,'file')
    load(sourceDataFilePath,'OSM_LLSegments_cellArray');
else
	error('Unable to find load file:\n\t%s\n. Run main demo script to produce this.\n',sourceDataFilePath);
end

mapCenter = [40.4453 -78.4351]; 
zoomLevel = 14.625;

% Call the function
fcn_OSM2SHP_plotNetworkAtLocation(OSM_LLSegments_cellArray, mapCenter, zoomLevel, figNum);

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));


%% Test cases start here. These are very simple, usually trivial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  _______ ______  _____ _______ _____
% |__   __|  ____|/ ____|__   __/ ____|
%    | |  | |__  | (___    | | | (___
%    | |  |  __|  \___ \   | |  \___ \
%    | |  | |____ ____) |  | |  ____) |
%    |_|  |______|_____/   |_| |_____/
%
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST figures start with 2

close all;
fprintf(1,'Figure: 2XXXXXX: TEST mode cases\n');

%% TEST case: Extract the LL coordinates of OSM PA highway road segments   

figNum = 20001;
titleString = sprintf('TEST case: Extract the LL coordinates of OSM PA highway road segments');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);





%% Fast Mode Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ______        _     __  __           _        _______        _
% |  ____|      | |   |  \/  |         | |      |__   __|      | |
% | |__ __ _ ___| |_  | \  / | ___   __| | ___     | | ___  ___| |_ ___
% |  __/ _` / __| __| | |\/| |/ _ \ / _` |/ _ \    | |/ _ \/ __| __/ __|
% | | | (_| \__ \ |_  | |  | | (_) | (_| |  __/    | |  __/\__ \ |_\__ \
% |_|  \__,_|___/\__| |_|  |_|\___/ \__,_|\___|    |_|\___||___/\__|___/
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Fast%20Mode%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FAST Mode figures start with 8

close all;
fprintf(1,'Figure: 8XXXXXX: TEST mode cases\n');
%% Basic example - NO FIGURE

figNum = 80001;
fprintf(1,'Figure: %.0f: FAST mode, empty figNum\n',figNum);
figure(figNum); close(figNum);

% Shape file string of PA highways 
shapeFileString = "state_college_roads.shp";

% Create a geospatial table
geospatial_table = fcn_OSM2SHP_loadShapeFile(shapeFileString, -1);

% Call the function
[LLCoordinate_allSegments, LL_allSegments_cell] = fcn_OSM2SHP_plotNetworkAtLocation(geospatial_table, ([]));

% Assertions
assert(length(LLCoordinate_allSegments(:,1)) > size(geospatial_table, 1)); 
assert(isequal(length(LL_allSegments_cell), size(geospatial_table, 1)));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%% Basic fast mode - NO FIGURE, FAST MODE

figNum = 80002;
fprintf(1,'Figure: %.0f: FAST mode, empty figNum\n',figNum);
figure(figNum); close(figNum);

% Shape file string of PA highways 
shapeFileString = "state_college_roads.shp";

% Create a geospatial table
geospatial_table = fcn_OSM2SHP_loadShapeFile(shapeFileString, -1);

% Call the function
[LLCoordinate_allSegments, LL_allSegments_cell] = fcn_OSM2SHP_plotNetworkAtLocation(geospatial_table, (-1));

% Assertions
assert(length(LLCoordinate_allSegments(:,1)) > size(geospatial_table, 1)); 
assert(isequal(length(LL_allSegments_cell), size(geospatial_table, 1)));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%% Compare speeds of pre-calculation versus post-calculation versus a fast variant

figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum); close(figNum);

% Shape file string of PA highways
shapeFileString = "state_college_roads.shp";

% Create a geospatial table
geospatial_table = fcn_OSM2SHP_loadShapeFile(shapeFileString, -1);

Niterations = 5;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations

    % Call the function
    [LLCoordinate_allSegments, LL_allSegments_cell] = fcn_OSM2SHP_plotNetworkAtLocation(geospatial_table, ([]));

end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;

for ith_test = 1:Niterations

    % Call the function
    [LLCoordinate_allSegments, LL_allSegments_cell] = fcn_OSM2SHP_plotNetworkAtLocation(geospatial_table, (-1));

end
fast_method = toc;

% Plot results as bar chart
figure(373737);
clf;
hold on;

X = categorical({'Normal mode','Fast mode'});
X = reordercats(X,{'Normal mode','Fast mode'}); % Forces bars to appear in this exact order, not alphabetized
Y = [slow_method fast_method ]*1000/Niterations;
bar(X,Y)
ylabel('Execution time (Milliseconds)')

% Assertions
assert(length(LLCoordinate_allSegments(:,1)) > size(geospatial_table, 1)); 
assert(isequal(length(LL_allSegments_cell), size(geospatial_table, 1)));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%% BUG cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ____  _    _  _____
% |  _ \| |  | |/ ____|
% | |_) | |  | | |  __    ___ __ _ ___  ___  ___
% |  _ <| |  | | | |_ |  / __/ _` / __|/ _ \/ __|
% | |_) | |__| | |__| | | (_| (_| \__ \  __/\__ \
% |____/ \____/ \_____|  \___\__,_|___/\___||___/
%
% See: http://patorjk.com/software/taag/#p=display&v=0&f=Big&t=BUG%20cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All bug case figures start with the number 9

% close all;
% fprintf(1,'Figure: 9XXXXXX: TEST mode cases\n');

%% BUG

%% Fail conditions
if 1==0

    %% Should thrown an error as the shapeFileString should be a character 'shapeFileString'

    figNum = 90001;
    fprintf(1,'Figure: %.0f:Bug case\n',figNum);
    figure(figNum); close(figNum);

end

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

