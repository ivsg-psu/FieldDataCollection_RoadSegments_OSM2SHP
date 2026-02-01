%% script_test_fcn_OSM2SHP_convertUTCToDatetime

% REVISION HISTORY:
%
% 2026_02_01 by Aneesh Batchu, abb6486@psu.edu
% - wrote the code originally

% TO-DO:
%
% 2026_01_27 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_OSM2SHP_plotSHP
%   % * Update the script to the new format (Demos, Tests, Fastmode, Bugs)
% 
% 2026_01_31 by Sean Brennan, sbrennan@psu.edu
% - In script_test_fcn_OSM2SHP_plotSHP
%   % * Add assertion tests for the table output (type, size, and values)

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

%% DEMO case: Convert the timestamp of OSM State College roads from UTC format to date time format

figNum = 10001;
titleString = sprintf('DEMO case: Convert the timestamp of OSM State College roads from UTC format to date time format');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

% Shape file string of PA highways 
shapeFileString = "state_college_roads.shp";

% Create a geospatial table
geospatial_table = fcn_OSM2SHP_plotSHP(shapeFileString, -1);

% Call the function
date_time = fcn_OSM2SHP_convertUTCToDatetime(geospatial_table, (figNum)); 

% Assertions
assert(isequal(class(date_time), 'datetime'))
assert(isequal(length(geospatial_table.timestamp(:,1)), length(date_time(:,1))))

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));
