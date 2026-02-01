%% script_test_fcn_OSM2SHP_plotSHP

% REVISION HISTORY:
%
% 2026_01_27 by Aneesh Batchu, abb6486@psu.edu
% - wrote the code originally
% 
% 2026_02_01 by Aneesh Batchu, abb6486@psu.edu
% - In script_test_fcn_OSM2SHP_plotSHP
%   % * Update the script to the new format (Demos, Tests, Fastmode, Bugs)
% - In script_test_fcn_OSM2SHP_plotSHP
%   % * Added assertion tests for the table output (type, size, and values)


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
geospatial_table = fcn_OSM2SHP_plotSHP(shapeFileString, (figNum));

% Assertions
assert(isequal(class(geospatial_table), 'table'))
assert(isequal(size(geospatial_table), [7130,29]))

requiredVars = ["Shape","highway","id","timestamp","length"];
assert(all(ismember(requiredVars, geospatial_table.Properties.VariableNames)));

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

%% TEST case: Plotting PA highways  

figNum = 20001;
titleString = sprintf('TEST case: Plotting PA highways');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Shape file string of PA highways 
shapeFileString = "PA_highways.shp";

% Call the function
geospatial_table = fcn_OSM2SHP_plotSHP(shapeFileString, (figNum));

% Assertions
assert(isequal(class(geospatial_table), 'table'))
assert(isequal(size(geospatial_table), [61523,41]))

requiredVars = ["Shape","highway","id","timestamp","length"];
assert(all(ismember(requiredVars, geospatial_table.Properties.VariableNames)));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% TEST case: Plotting all PA roads

figNum = 20002;
titleString = sprintf('TEST case: Plotting all PA roads');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Shape file string of PA highways 
shapeFileString = "PA_ALL_roads.shp";

% Call the function
geospatial_table = fcn_OSM2SHP_plotSHP(shapeFileString, (figNum));

% Assertions
assert(isequal(class(geospatial_table), 'table'))
assert(isequal(size(geospatial_table), [1385186, 41]))

requiredVars = ["Shape","highway","id","timestamp","length"];
assert(all(ismember(requiredVars, geospatial_table.Properties.VariableNames)));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

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

fig_num = 80001;
fprintf(1,'Figure: %.0f: FAST mode, empty fig_num\n',fig_num);
figure(fig_num); close(fig_num);

% Shape file string of state college highways 
shapeFileString = "state_college_roads.shp";

% Call the function
geospatial_table = fcn_OSM2SHP_plotSHP(shapeFileString, ([]));

% Assertions
assert(isequal(class(geospatial_table), 'table'))

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==fig_num));

%% Basic fast mode - NO FIGURE, FAST MODE

fig_num = 80002;
fprintf(1,'Figure: %.0f: FAST mode, empty fig_num\n',fig_num);
figure(fig_num); close(fig_num);

% Shape file string of PA highways 
shapeFileString = "state_college_roads.shp";

% Call the function
geospatial_table = fcn_OSM2SHP_plotSHP(shapeFileString, (-1));

% Assertions
assert(isequal(class(geospatial_table), 'table'))

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==fig_num));

%% Compare speeds of pre-calculation versus post-calculation versus a fast variant

fig_num = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',fig_num);
figure(fig_num); close(fig_num);

% Shape file string of PA highways
shapeFileString = "state_college_roads.shp";

Niterations = 10;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations

    % Call the function
    geospatial_table = fcn_OSM2SHP_plotSHP(shapeFileString, ([]));

end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on
tic;

for ith_test = 1:Niterations

    % Call the function
    geospatial_table = fcn_OSM2SHP_plotSHP(shapeFileString, (-1));

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
assert(isequal(class(geospatial_table), 'table'))

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==fig_num));

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

    fig_num = 90001;
    fprintf(1,'Figure: %.0f:Bug case\n',fig_num);
    figure(fig_num); close(fig_num);

    % Shape file string of PA highways
    shapeFileString = 5;

    % Call the function
    geospatial_table = fcn_OSM2SHP_plotSHP(shapeFileString, (figNum));

    % Assertions
    assert(isequal(class(geospatial_table), 'table'))

    % Make sure plot opened up
    assert(isequal(get(gcf,'Number'),figNum));

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

