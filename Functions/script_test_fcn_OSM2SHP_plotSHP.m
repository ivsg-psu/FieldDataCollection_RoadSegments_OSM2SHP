%% script_test_fcn_OSM2SHP_plotSHP

% REVISION HISTORY:
%
% 2026_01_27 by Aneesh Batchu, abb6486@psu.edu
% - wrote the code originally

% TO-DO:
%
% 2026_01_27 by Aneesh Batchu, abb6486@psu.edu
% - Update the script to the new format
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

%% DEMO case: Plotting State College roads

figNum = 10001;
titleString = sprintf('DEMO case: Plotting State College roads');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Shape file string of PA highways 
shapeFileString = "state_college_roads.shp";

% Call the function
geospatial_table = fcn_OSM2SHP_plotSHP(shapeFileString, figNum);

% Assertions
% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));
assert(isequal(class(geospatial_table), 'table'))


%% DEMO case: Plotting PA highways  

figNum = 10002;
titleString = sprintf('DEMO case: Plotting PA highways');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Shape file string of PA highways 
shapeFileString = "PA_highways.shp";

% Call the function
geospatial_table = fcn_OSM2SHP_plotSHP(shapeFileString, figNum);

% Assertions
% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));
assert(isequal(class(geospatial_table), 'table'))


%% DEMO case: Plotting all PA roads

figNum = 10003;
titleString = sprintf('DEMO case: Plotting all PA roads');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Shape file string of PA highways 
shapeFileString = "PA_ALL_roads.shp";

% Call the function
geospatial_table = fcn_OSM2SHP_plotSHP(shapeFileString, figNum);

% Assertions
% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));
assert(isequal(class(geospatial_table), 'table'))

