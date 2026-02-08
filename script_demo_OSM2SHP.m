
%% Introduction to and Purpose of the Code
% This is the explanation of the code that can be found by running
%       script_demo_OSM2SHP.m
% This is a script to demonstrate the functions within the OSM2SHP code
% library. This code repo is typically located at:
%   https://github.com/ivsg-psu/FieldDataCollection_RoadSegments_OSM2SHP
%
% If you have questions or comments, please contact Aneesh Batchu at
% abb6486@psu.edu or Sean Brennan at sbrennan@psu.edu
%
% The purpose of the code is to generate shape (.shp) files from OSM
% (.osm.pbf) files and geoplot the shape files.

% REVISION HISTORY:
% 
% 2026_01_27 by Aneesh Batchu, abb6486@psu.edu
% - Wrote the code originally
% 
% 2026_01_29 by Sean Brennan, sbrennan@psu.edu
% - In this main script:
%   % * Updated install flags to allow full reset option
%   % * Updated global variables to OSM2SHP instead of LAPS
%   % * Updated shapefile to use data already in Data folder (not PennDOT)
%   % * Updated zoom and mapcenter definitions to put image centered on
%   %   % intersection at Reber
%
% 2026_01_31 by Sean Brennan, sbrennan@psu.edu
% - In fcn_OSM2SHP_loadShapeFile
%   % * fixed global flags from DEBUGTOOLS to OSM2SHP
%   % * added input checking 
%   % * added Documents folder
%   % * shut off demo plotting of PA highways and PA_all_roads (data does
%   %   % not exist)
% 
% 2026_02_01 by Aneesh Batchu, abb6486@psu.edu
% - Wrote a function "fcn_OSM2SHP_convertUTCToDatetime"to convert  
%   % shapefile timestamps stored in geospatial_table into human/computer  
%   % readable formats and wrote a script to test the function 
% - Added "fcn_INTERNAL_checkRequiredLargeDataFiles" to check if an user
%  % has downloaded all required files
% - In script_test_fcn_OSM2SHP_loadShapeFile
%   % * Update the script to the new format (Demos, Tests, Fastmode, Bugs)
% - In script_test_fcn_OSM2SHP_loadShapeFile
%   % * Added assertion tests for the table output (type, size, and values)
% - Updated ReadME.md file
%
% 2026_02_02 by Sean Brennan, sbrennan@psu.edu
% - In this main demo code:
%   % * Fixed fcn_INTERNAL_checkRequiredLargeDataFiles to find files even
%   %   % if not installed in root of LargeData, for example if installed in
%   %   % subfolders of the same folder or within the Data folder.
%   % * Fixed fprintf statements to include correct designator for terminal
%   %   % so that it is now: fprintf(1,"Stuff...");
%
% 2026_02_02 by Aneesh Batchu, abb6486@psu.edu
% - Renamed "fcn_OSM2SHP_plotSHP" to "fcn_OSM2SHP_loadShapeFile"
% - Tested repo for release (Line 177)
%  % * Passed all tests  
%
% (new release)
% 
% 2026_02_03 by Aneesh Batchu, abb6486@psu.edu
% - Wrote function "fcn_OSM2SHP_extractLLFromGeospatialTable" and the
%  % corresponding script is also added. 
% - Tested repo for release (Line 177)
%  % * Passed all tests 
%
% 2026_02_07 by Sean Brennan, sbrennan@psu.edu
% - In fcn_OSM2SHP_extractLLFromGeospatialTable 
%   % * Added plotting in debugging area to show both types fo data
% - In script_test_fcn_OSM2SHP_extractLLFromGeospatialTable 
%   % * Fixed bug where figure open assertion was incorrect (DEMO 10001)
% - In script_demo_OSM2SHP
%   % * Fixed bug where check for data files would ALWAYS pass, even if
%   %   % files were missing
%   % * Tested repo for release, passed all tests

% TO-DO:
%  
% 2026_02_07 by Sean Brennan, sbrennan@psu.edu
% - In fcn_OSM2SHP_extractLLFromGeospatialTable
%   % There's a bug in the function where the unique LLA values are being
%   % reordered in a weird way, causing plots to jump back/forth on same
%   % segments. See Demo case 1

%% Instructions to create LargeData folder
%
% Create a directory named "LargeData" inside the ExtremaRoadEdge (main)
% directory.
%
% Navigate to:
% OneDrive/IVSG/GitHubMirror/FieldDataCollection/RoadSegments/OSM2SHP/LargeData
% 
% Download "PA_ALL_roads.zip", "PA_highways.zip" and
% "pennsylvania-260125.osm.pbf"
% 
% Copy above three items into your this repo's LargeData folder
% 
% Unzip "PA_ALL_roads.zip" and "PA_highways.zip"  
% 
% Copy all the files in the unzipped folder to LargeData folder before
% running the script


%% Make sure we are running out of root directory
st = dbstack; 
thisFile = which(st(1).file);
[filepath,name,ext] = fileparts(thisFile);
cd(filepath);

%%% START OF STANDARD INSTALLER CODE %%%%%%%%%

%% Clear paths and folders, if needed
if 1==1
    clear flag_OSM2SHP_Folders_Initialized
end

if 1==0
    fcn_INTERNAL_clearUtilitiesFromPathAndFolders;
end

if 1==0
    % Resets all paths to factory default
    restoredefaultpath;
end

%% Install dependencies
% Define a universal resource locator (URL) pointing to the repos of
% dependencies to install. Note that DebugTools is always installed
% automatically, first, even if not listed:
clear dependencyURLs dependencySubfolders
ith_repo = 0;

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary';
dependencySubfolders{ith_repo} = {'Functions','Data'};

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_PlotRoad';
dependencySubfolders{ith_repo} = {'Functions','Data'};

%% Do we need to set up the work space?
if ~exist('flag_OSM2SHP_Folders_Initialized','var')
    
    % Clear prior global variable flags
    clear global FLAG_*

    % Navigate to the Installer directory
    currentFolder = pwd;
    cd('Installer');
    % Create a function handle
    func_handle = @fcn_DebugTools_autoInstallRepos;

    % Return to the original directory
    cd(currentFolder);

    % Call the function to do the install
    func_handle(dependencyURLs, dependencySubfolders, (0), (-1));

	% Does LargeData exist?
	if ~exist(fullfile(pwd,'LargeData'),'dir')
		mkdir('LargeData');
	end

    % Add this function's folders to the path
    this_project_folders = {...
        'Functions','Data','LargeData'};
    fcn_DebugTools_addSubdirectoriesToPath(pwd,this_project_folders)

    flag_OSM2SHP_Folders_Initialized = 1;
end

%%% END OF STANDARD INSTALLER CODE %%%%%%%%%

%% Set environment flags for input checking in Laps library
% These are values to set if we want to check inputs or do debugging
setenv('MATLABFLAG_OSM2SHP_FLAG_CHECK_INPUTS','1');
setenv('MATLABFLAG_OSM2SHP_FLAG_DO_DEBUG','0');

%% Set environment flags that define the ENU origin
% This sets the "center" of the ENU coordinate system for all plotting
% functions
% Location for Test Track base station
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.86368573');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-77.83592832');
setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','344.189');


%% Set environment flags for plotting
% These are values to set if we are forcing image alignment via Lat and Lon
% shifting, when doing geoplot. This is added because the geoplot images
% are very, very slightly off at the test track, which is confusing when
% plotting data
setenv('MATLABFLAG_PLOTROAD_ALIGNMATLABLLAPLOTTINGIMAGES_LAT','-0.0000008');
setenv('MATLABFLAG_PLOTROAD_ALIGNMATLABLLAPLOTTINGIMAGES_LON','0.0000054');

%% Test the repo
if 1==0
	fcn_DebugTools_testRepoForRelease('_OSM2SHP_');
end

%% Check if required files exist to run the demo script and script_test_all_functions

% Checks if required files exist
fcn_INTERNAL_checkRequiredLargeDataFiles


%% Start of Demo Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____ _             _            __   _____                          _____          _
%  / ____| |           | |          / _| |  __ \                        / ____|        | |
% | (___ | |_ __ _ _ __| |_    ___ | |_  | |  | | ___ _ __ ___   ___   | |     ___   __| | ___
%  \___ \| __/ _` | '__| __|  / _ \|  _| | |  | |/ _ \ '_ ` _ \ / _ \  | |    / _ \ / _` |/ _ \
%  ____) | || (_| | |  | |_  | (_) | |   | |__| |  __/ | | | | | (_) | | |___| (_) | (_| |  __/
% |_____/ \__\__,_|_|   \__|  \___/|_|   |_____/ \___|_| |_| |_|\___/   \_____\___/ \__,_|\___|
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Start%20of%20Demo%20Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Welcome to the demo code for the OSM2SHP library! Please read the Instructions')

%% fcn_OSM2SHP_loadShapeFile: Plots the roads in the shape file

figNum = 10001;
titleString = sprintf('fcn_OSM2SHP_loadShapeFile: Plots the roads in the shape file');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); 
clf;

% Shape file string of PA highways 
shapeFileString = "state_college_roads.shp";

% Call the function
geospatial_table = fcn_OSM2SHP_loadShapeFile(shapeFileString, figNum);

% % Use this to create "osm_standard" options for geobasemap
% name = "osm_standard";
% url = "https://a.tile.openstreetmap.org/${z}/${x}/${y}.png";
% attribution = "© OpenStreetMap contributors";
% addCustomBasemap(name, url, 'Attribution', attribution);
% geobasemap(name);

% geobasemap('osm_standard') % Plots the data (roads) on a OSM standard basemap

% geobasemap('satellite') % Options: 'streets-light', 'streets-dark', 'topographic', 'grayland', 'bluegreen', etc.
% temp = gca; 

%  set(temp, 'MapCenter', [40.826378084422814 -77.843653529278654],
%  'ZoomLevel', 22);  % - Highway

% set(temp, 'MapCenter', [40.792665826872089 -77.863991325077109], 'ZoomLevel', 19);  % Intersection between South Atherton and W. College Ave

% Assertions
assert(isequal(class(geospatial_table), 'table'))
assert(isequal(size(geospatial_table), [7130,29]))

requiredVars = ["Shape","highway","id","timestamp","length"];
assert(all(ismember(requiredVars, geospatial_table.Properties.VariableNames)));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% fcn_OSM2SHP_convertUTCToDatetime: Convert the timestamp of OSM State College roads from UTC format to date time format

figNum = 10002;
titleString = sprintf('fcn_OSM2SHP_convertUTCToDatetime: Convert the timestamp of OSM State College roads from UTC format to date time format');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

% Shape file string of PA highways 
shapeFileString = "state_college_roads.shp";

% Create a geospatial table
geospatial_table = fcn_OSM2SHP_loadShapeFile(shapeFileString, -1);

% Call the function
date_time = fcn_OSM2SHP_convertUTCToDatetime(geospatial_table, (figNum)); 

% Assertions
assert(isequal(class(date_time), 'datetime'))
assert(isequal(length(geospatial_table.timestamp(:,1)), length(date_time(:,1))))

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

%% fcn_OSM2SHP_extractLLFromGeospatialTable: Extract the LL coordinates of OSM State College road segments

figNum = 10003;
titleString = sprintf('fcn_OSM2SHP_extractLLFromGeospatialTable: Extract the LL coordinates of OSM State College road segments');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

% Shape file string of PA highways 
shapeFileString = "state_college_roads.shp";

% Create a geospatial table
geospatial_table = fcn_OSM2SHP_loadShapeFile(shapeFileString, -1);

% Call the function
[LLCoordinate_allSegments, LL_allSegments_cell] = fcn_OSM2SHP_extractLLFromGeospatialTable(geospatial_table, (figNum));

% Assertions
assert(length(LLCoordinate_allSegments(:,1)) > size(geospatial_table, 1)); 
assert(isequal(length(LL_allSegments_cell), size(geospatial_table, 1)));

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

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


%% function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
% Clear out the variables
clear global flag* FLAG*
clear flag*
clear path

% Clear out any path directories under Utilities
if ispc
    path_dirs = regexp(path,'[;]','split');
elseif ismac
    path_dirs = regexp(path,'[:]','split');
elseif isunix
    path_dirs = regexp(path,'[;]','split');
else
    error('Unknown operating system. Unable to continue.');
end

utilities_dir = fullfile(pwd,filesep,'Utilities');
for ith_dir = 1:length(path_dirs)
    utility_flag = strfind(path_dirs{ith_dir},utilities_dir);
    if ~isempty(utility_flag)
        rmpath(path_dirs{ith_dir})
    end
end

% Delete the Utilities folder, to be extra clean!
if  exist(utilities_dir,'dir')
    [status,message,message_ID] = rmdir(utilities_dir,'s');
    if 0==status
        error('Unable remove directory: %s \nReason message: %s \nand message_ID: %s\n',utilities_dir, message,message_ID);
    end
end

end % Ends fcn_INTERNAL_clearUtilitiesFromPathAndFolders


%% fcn_INTERNAL_checkRequiredLargeDataFiles

function fcn_INTERNAL_checkRequiredLargeDataFiles
% fcn_INTERNAL_checkRequiredLargeDataFiles
%
% Verifies that all required large data files exist directly inside the
% LargeData directory. 
%
% This function is intended to be called before running demo scripts or
% test suites that depend on external large data files.

% Path of LargeData directory
largeDataDirectory = fullfile(pwd, 'LargeData');

% Check that LargeData directory exists
if ~isfolder(largeDataDirectory)
    error('LargeData folder does not exist at: %s', largeDataDirectory);
end

fprintf(1,'\nChecking required files in LargeData directory:\n');

% List of required files (directly inside LargeData/)
requiredFiles = { ...
    'PA_ALL_roads.cpg', ...
    'PA_ALL_roads.dbf', ...
    'PA_ALL_roads.prj', ...
    'PA_ALL_roads.shp', ...
    'PA_ALL_roads.shx', ...
    'PA_highways.cpg', ...
    'PA_highways.dbf', ...
    'PA_highways.prj', ...
    'PA_highways.shp', ...
    'PA_highways.shx', ...
    };

% Check each required file
for nFile = 1:numel(requiredFiles)
    fileName = requiredFiles{nFile};
    
    % OLD --> doesn't work unless install is in EXACTLY right location:  
    % filePath = fullfile(largeDataDirectory, fileName);
    % if ~isfile(filePath)
    if ~exist(fileName,'file')
        fprintf(1,'-------------------------------- Read instructions to proceed ------------------------------\n');
        error('Missing required file: %s', requiredFiles{nFile});
        
    else
        fprintf(1, ' Found required file: %s\n', requiredFiles{nFile});
    end
end

fprintf(1, '\nAll required LargeData files exist.\n');

end % Ends fcn_INTERNAL_checkRequiredLargeDataFiles