
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
% (.osm.pbf) files, extract the attributes from shape files and geoplot the
% shape files.

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
%
% (new release)
% 
% 2026_02_09 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_OSM2SHP_extractLLFromGeospatialTable
%   % * Added 'stable' to unique function to preserve order and maintain
%   %   % uniqueness.
%   % * But, commented out the line with unique function and wrote a line
%   %   % without the unique function. Repeated coordinates might be 
%   %   % intentionally preserved in road segment geometries to maintain
%   %   % multi-part connectivity and vertex ordering, or because 
%   %   % a road segment may revisit the same location 
%   %   % (e.g., loops or self-intersections).
%
% (new release)
% 
% 2026_06_06 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_OSM2SHP_stackCellArrayIntoMatrix
%   % * Copied this function to OSM2SHP from PennDOTSHP
% - In script_test_fcn_OSM2SHP_stackCellArrayIntoMatrix
%   % * Copied this function to OSM2SHP from PennDOTSHP
% - In fcn_OSM2SHP_plotNetworkAtLocation
%   % * Moved this function from PennDOTSHP to OSM2SHP
% - In script_test_fcn_OSM2SHP_plotNetworkAtLocation
%   % * Moved this function from PennDOTSHP to OSM2SHP
% - In script_demo_OSM2SHP
%   % * Copied the KD tree related sections function from PennDOTSHP to
%   OSM2SHP to generate OSM network KD tree. 


% TO-DO:
%  
% 2026_02_07 by Sean Brennan, sbrennan@psu.edu
% - In fcn_OSM2SHP_extractLLFromGeospatialTable
%   % There's a bug in the function where the unique LLA values are being
%   % reordered in a weird way, causing plots to jump back/forth on same
%   % segments. See Demo case 1

%% Instructions to create LargeData folder
%
% Create a directory named "LargeData" inside the OSM2SHP (main)
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

flag_loadDataFilesWhenPossible = true;
flag_exportFigures = false;

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

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% fcn_OSM2SHP_extractLLFromGeospatialTable: Extract the LL coordinates of PA OSM roads

figNum = 10004;
titleString = sprintf('fcn_OSM2SHP_extractLLFromGeospatialTable: Extract the LL coordinates of PA OSM roads');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

sourceDataFileName = 'OSM_geospatialTable';
sourceDataFilePath = fullfile(pwd,'LargeData',cat(2,sourceDataFileName,'.mat'));
if flag_loadDataFilesWhenPossible && exist(sourceDataFilePath,'file')
    load(sourceDataFilePath,'OSM_geospatialTable');
else
    % Load the data and create the data file
    fprintf(1,'\tLoading... (this will take about 20 seconds).\n');

    % Shape file string of PA highways
    shapeFileString = fullfile(pwd,'LargeData','OSM PA Highways Shpfile','PA_highways.shp');

    % Create a geospatial table
    OSM_geospatialTable = fcn_OSM2SHP_loadShapeFile(shapeFileString, (-1));

    % Save the results
    save(sourceDataFilePath,'OSM_geospatialTable');

end

sourceDataFileName = 'OSM_LLcoordinates';
sourceDataFilePath = fullfile(pwd,'LargeData',cat(2,sourceDataFileName,'.mat'));
if 1==1 && flag_loadDataFilesWhenPossible && exist(sourceDataFilePath,'file')
    load(sourceDataFilePath,'OSM_LLSegments_matrix','OSM_LLSegments_cellArray','usableTableRows');
else

    % Call the function
    [OSM_LLSegments_matrix, OSM_LLSegments_cellArray] = fcn_OSM2SHP_extractLLFromGeospatialTable(OSM_geospatialTable, (-1));

    % Good segments should be kept in the table
    segmentsKept = OSM_LLSegments_matrix(:,3);
    segmentsKept = segmentsKept(~isnan(segmentsKept));
    segmentsKept = unique(segmentsKept);
    usableTableRows = false(height(OSM_geospatialTable),1);
    usableTableRows(segmentsKept) = true;

    % Save the results
    save(sourceDataFilePath,'OSM_LLSegments_matrix','OSM_LLSegments_cellArray','usableTableRows');


end



%%%%%
%  Plot results?
if 1==1
    figure(figNum);
    clf;

    % Create sublots?
    if 1==1
        % Set view
        % [41.2545 -78.0122], 'ZoomLevel', 6.875); % Entire state
        % [40.439535257611780 -78.426147949962584], 'ZoomLevel', 16.75); % Altoona interchange
        mapCenter = [40.4453 -78.4351]; zoomLevel = 14.625; % zoom out of interchange

        subplot(1,2,1);

        plotFormat.Color = [0 0.7 0];
        plotFormat.Marker = '.';
        plotFormat.MarkerSize = 20;
        plotFormat.LineStyle = '-';
        plotFormat.LineWidth = 3;
        plotFormat.DisplayName = 'OSM';

        fcn_plotRoad_plotLL(OSM_LLSegments_matrix,(plotFormat),(figNum));
        legend('Interpreter','none','Location','northeast');

        set(gca, 'MapCenter', mapCenter, 'ZoomLevel', zoomLevel);


        title('All segments')
        % temp = gca;
        % set(temp, 'MapCenter', [40.792665826872089 -77.863991325077109], 'ZoomLevel', 19);  % Intersection between South Atherton and W. College Ave


        subplot(1,2,2);

    end
    % Get the colorOrder
    ax = gca;
    colorOrder = ax.ColorOrder;
    Ncolors = size(colorOrder,1);

    segmentNumber = OSM_LLSegments_matrix(:,3);
    colorIndex = mod(segmentNumber-1,Ncolors)+1;
    LLIdata = [OSM_LLSegments_matrix(:,1:2) colorIndex];
    [h_plot, indiciesInEachPlot]  = fcn_plotRoad_plotLLI(LLIdata, (plotFormat),  (colorOrder), (figNum)); %#ok<ASGLU>

    set(gca, 'MapCenter', mapCenter, 'ZoomLevel', zoomLevel);

    title(sprintf('Each of %.0f segments as a different color',length(OSM_LLSegments_cellArray)));

    if flag_exportFigures
        figure(figNum); %#ok<UNRCH>
        figFileName = fullfile(pwd,'Images',cat(2,sourceDataFileName,'.png'));
        exportgraphics(h_fig,figFileName,'Resolution',300)
    end
end

%% Subsegmenting the network
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _                                         _   _
%  / ____|     | |                                       | | (_)
% | (___  _   _| |__  ___  ___  __ _ _ __ ___   ___ _ __ | |_ _ _ __   __ _
%  \___ \| | | | '_ \/ __|/ _ \/ _` | '_ ` _ \ / _ \ '_ \| __| | '_ \ / _` |
%  ____) | |_| | |_) \__ \  __/ (_| | | | | | |  __/ | | | |_| | | | | (_| |
% |_____/ \__,_|_.__/|___/\___|\__, |_| |_| |_|\___|_| |_|\__|_|_| |_|\__, |
% | | | |                       __/ |                                  __/ |
% | |_| |__   ___              |___/                                  |___/
% | __| '_ \ / _ \
% | |_| | | |  __/
%  \__|_| |_|\___|                   _
% | \ | |    | |                    | |
% |  \| | ___| |___      _____  _ __| | __
% | . ` |/ _ \ __\ \ /\ / / _ \| '__| |/ /
% | |\  |  __/ |_ \ V  V / (_) | |  |   <
% |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Subsegmenting%0Athe%0ANetwork&x=none&v=4&h=4&w=80&we=false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the PennDOT segments can have very large segment lengths, and this can
% introduce errors when snapping data into the network as the snap distance
% error can be as large as half a subsegment length. One subsegment is
% 5,000 meters long (about 3+ miles!), which means the friction data could
% have as much as 1.5 miles of error.


%% Subsegmenting PennDOT road segments
figNum = 20001;
titleString = sprintf('Subsegmenting OSM road segments');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Set up GPS object - this is used to convert LLA to ENU and vice versa
reference_latitude = 40.86368573; %#ok<NASGU>
reference_longitude = -77.83592832; %#ok<NASGU>
reference_altitude = 344.189;
% Initialize WGS84 ellipsoid model (units: meters) for LLA <-> ECEF conversions
wgs84 = wgs84Ellipsoid('meters');


% Load the LL data
PreviousDataFileName = 'OSM_LLcoordinates';
PreviouseDataFilePath = fullfile(pwd,'LargeData',cat(2,PreviousDataFileName,'.mat'));
if flag_loadDataFilesWhenPossible && exist(PreviouseDataFilePath,'file')
    load(PreviouseDataFilePath,'OSM_LLSegments_cellArray');
else
    error('Unable to load file: \n\t%s\nNeed to run prior section in this script!',PreviouseDataFilePath);
end

increment = 1; % Every 1 meter

sourceDataFileName = 'OSM_Subsegments';
sourceDataFilePath = fullfile(pwd,'LargeData',cat(2,sourceDataFileName,'.mat'));

if 1==1 && flag_loadDataFilesWhenPossible &&  exist(sourceDataFilePath,'file')
    load(sourceDataFilePath,'OSM_XYZsubSegments_cellArray','OSM_LLsubSegments_cellArray','OSM_XYZSegments_cellArray','OSM_LLSegments_cellArray') %#ok<NASGU>
else



    Nsegments = length(OSM_LLSegments_cellArray);

    % tempDataFileName = 'PennDOT_SegmentLengthAnalysis';
    % tempDataFilePath = fullfile(pwd,'Data',cat(2,tempDataFileName,'.mat'));
    % try
    %     % load(tempDataFilePath,'PennDOT_ENSegments_matrix');
    % 	load(tempDataFilePath,'PennDOT_segmentLengths','PennDOT_segmentENCoordinates','subsegmentLengths','PennDOT_ENSegments_matrix');
    % catch
    %     error('Unable to load file: \n\t%s\nNeed to run prior section in this script!',tempDataFilePath);
    % end
    % PennDOT_ENSegments_cellArrayIndices = fcn_DebugTools_breakArrayByNans(PennDOT_ENSegments_matrix,-1)';



    OSM_XYZSegments_cellArray    = OSM_LLSegments_cellArray;
    OSM_XYZsubSegments_cellArray = OSM_LLSegments_cellArray;
    OSM_LLsubSegments_cellArray = OSM_LLSegments_cellArray;

    NsegmentsWithRepeats = 0;
    for ith_segment = 1:Nsegments
        if mod(ith_segment,1000)==0
            fprintf(1,'Resampling segment %.0f of %.0f\n',ith_segment,Nsegments)
        end

        thisLLSegment = OSM_LLSegments_cellArray{ith_segment};
        thisLL = thisLLSegment(:,1:2);
        thisSegmentID = thisLLSegment(1,3);

        % Make sure all segment numbers are same
        assert(all(thisLLSegment(:,3)==thisSegmentID));


        %%%%%%%%%
        % Convert LLA to ECEF
        Npoints_1 = size(thisLL,1);

        % Estimate altitude
        altitudeColumn = ones(Npoints_1,1)*reference_altitude;

        % Obtain LLA data
        thisLLA = [thisLL, altitudeColumn];

        [X, Y, Z] = geodetic2ecef(wgs84, thisLLA(:,1), thisLLA(:,2), thisLLA(:,3));
        thisXYZ = [X, Y, Z];
        % For ECEF data, all XYZ need to be saved
        % Save result

        OSM_XYZSegments_cellArray{ith_segment} = [thisXYZ ones(Npoints_1,1)*thisSegmentID];


        % Calculate stations
        stations = fcn_Path_calcPathStation(thisXYZ,-1);

        % Determine new stations

        newStations = (stations(1):increment:stations(end))';
        if newStations(end)~=stations(end)
            newStations(end+1,1) = stations(end); %#ok<SAGROW> % Ensure the last station is included
        end
        Nstations = length(newStations);

        % Make sure there's no NaN values (the Path code below won't work)
        if any(isnan(thisXYZ(:,1)),'all')
            error('Nan value found in data - unable to continue.');
        end

        % Make sure there's no repeats
        if ~isequal(unique(thisXYZ,'rows','stable'),thisXYZ)
            NsegmentsWithRepeats = NsegmentsWithRepeats+1;
            thisXYZ = unique(thisXYZ,'rows','stable');
        end

        % Resample path at new stations
        thisSubSegmentXYZ = fcn_Path_newPathByStationResampling(thisXYZ,newStations,-1);

        % Fill in segment numbers
        thisXYZSubSegment = [thisSubSegmentXYZ, ones(Nstations,1)*thisSegmentID];

        % Fill array with results
        OSM_XYZsubSegments_cellArray{ith_segment} = thisXYZSubSegment;


        % Convert ECEF XYZ back to LLA



        % Convert ECEF XYZ to LLA
        thisX = thisSubSegmentXYZ(:,1);
        thisY = thisSubSegmentXYZ(:,2);
        thisZ = thisSubSegmentXYZ(:,3);
        [thisLat, thisLon, thisAlt] = ecef2geodetic(wgs84, thisX, thisY, thisZ);
        thisLLA = [thisLat, thisLon, thisAlt];
        % Extract LL coordinates from LLA
        thisLL = thisLLA(:,1:2);

        % Add segment number
        thisLLSubSegment = [thisLL, ones(Nstations,1)*thisSegmentID];

        % Fill array with results
        OSM_LLsubSegments_cellArray{ith_segment} = thisLLSubSegment;


    end

    fprintf(1,'There were %.0f segments found (out of %.0f) that had repeated points.\n',NsegmentsWithRepeats,Nsegments);

    % Save results
    save(sourceDataFilePath,'OSM_XYZsubSegments_cellArray','OSM_LLsubSegments_cellArray','OSM_XYZSegments_cellArray','OSM_LLSegments_cellArray');
end

%%%%%%
%% Plot the results

figNum = 20001;
titleString = sprintf('Subsegmenting OSM road segments');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;
mapCenter = [40.439535257611780 -78.426147949962584];
zoomLevel =  19;

subplot(1,2,1);
fcn_OSM2SHP_plotNetworkAtLocation(OSM_LLSegments_cellArray, mapCenter, zoomLevel, figNum);
title('Original OSM shape file (segments)')

subplot(1,2,2);
fcn_OSM2SHP_plotNetworkAtLocation(OSM_LLsubSegments_cellArray, mapCenter, zoomLevel, figNum);
title(sprintf('Resampled OSM shape file (subsegments) at %.2f meters',increment));



%% KD Tree formation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  _  _______    _______
% | |/ /  __ \  |__   __|
% | ' /| |  | |    | |_ __ ___  ___  ___
% |  < | |  | |    | | '__/ _ \/ _ \/ __|
% | . \| |__| |    | | | |  __/  __/\__ \
% |_|\_\_____/     |_|_|  \___|\___||___/
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=KD+Trees&x=none&v=4&h=4&w=80&we=false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figNum = 30001;
titleString = sprintf('Building KD Trees');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;


sourceDataFileName = 'OSM_KDTrees';
sourceDataFilePath = fullfile(pwd,'LargeData',cat(2,sourceDataFileName,'.mat'));

if 1==1 && flag_loadDataFilesWhenPossible &&  exist(sourceDataFilePath,'file')
    load(sourceDataFilePath,...
        'kdtreeModelLL','OSM_LLSegmentsKDIds', ...
        'kdtreeModelLLsub','OSM_LLsubSegments',...
        'kdtreeModelECEF', 'OSM_XYZSegmentsKDIds',...
        'kdtreeModelECEFsub','OSM_ENsubSegments'); %#ok<NASGU>
else

    %%%% Load the data
    warning('This process is VERY slow and make take 10+ minutes.')

    tempDataFileName = 'OSM_Subsegments';
    tempsourceDataFilePath = fullfile(pwd,'LargeData',cat(2,tempDataFileName,'.mat'));

    if 1==1 && flag_loadDataFilesWhenPossible &&  exist(tempsourceDataFilePath,'file')
        load(tempsourceDataFilePath,'OSM_XYZsubSegments_cellArray','OSM_LLsubSegments_cellArray','OSM_XYZSegments_cellArray','OSM_LLSegments_cellArray')
    else
        error('Unable to find load file:\n\t%s\n. Run main demo script to produce this.\n',tempsourceDataFilePath);
    end

    % Make sure sizes of LL data are consistent with EN data for both segments
    % and subsegments
    assert(isequal(size(OSM_XYZsubSegments_cellArray),size(OSM_LLsubSegments_cellArray)));
    assert(isequal(size(OSM_XYZSegments_cellArray),size(OSM_LLSegments_cellArray)));

    %%%% Create the matrix versions of all cell arrays
    OSM_LLSegments_matrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(OSM_LLSegments_cellArray,-1);
    OSM_LLsubSegments_matrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(OSM_LLsubSegments_cellArray,-1);
    OSM_XYZSegments_matrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(OSM_XYZSegments_cellArray,-1);
    OSM_XYZsubSegments_matrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(OSM_XYZsubSegments_cellArray,-1);


    % Remove NaN rows
    nanRows = isnan(OSM_LLSegments_matrix(:,1));
    OSM_LLSegments_matrix_noNaN = OSM_LLSegments_matrix(~nanRows,:);
    OSM_XYZSegments_matrix_noNaN = OSM_XYZSegments_matrix(~nanRows,:);

    % Make sure the matrices are still the same
    NumRows = size(OSM_XYZSegments_matrix_noNaN,1);
    assert(size(OSM_LLSegments_matrix_noNaN,1) == NumRows);

    % Build the reference matrices for the KD tree formation
    KDids = (1:NumRows)';
    OSM_LLSegmentsKDIds = [OSM_LLSegments_matrix_noNaN KDids];
    OSM_XYZSegmentsKDIds = [OSM_XYZSegments_matrix_noNaN KDids];

    % Again, remove Nan rows (should probably functionalize this - it's
    % repetitive)
    nanRows = isnan(OSM_LLsubSegments_matrix(:,1));
    OSM_LLsubSegments_matrix_noNaN = OSM_LLsubSegments_matrix(~nanRows,:);
    OSM_XYZsubSegments_matrix_noNaN = OSM_XYZsubSegments_matrix(~nanRows,:);

    % Make sure the matrices are still the same
    NumRows = size(OSM_XYZsubSegments_matrix_noNaN,1);
    assert(size(OSM_LLsubSegments_matrix_noNaN,1) == NumRows);

    % Build the reference matrices for the KD tree formation
    KDids = (1:NumRows)';
    OSM_LLsubSegmentsKDIds = [OSM_LLsubSegments_matrix_noNaN, KDids];
    OSM_XYZsubSegmentsKDIds = [OSM_XYZsubSegments_matrix_noNaN, KDids];


    % % Generate cell array versions of these also
    % % Too slow to generate these cells
    % OSM_LLSegmentsKDIds_cellArray = fcn_INTERNAL_buildCellArrayFromMatrix(OSM_LLSegmentsKDIds);
    % OSM_XYZSegmentsKDIds_cellArray = fcn_INTERNAL_buildCellArrayFromMatrix(OSM_XYZSegmentsKDIds);
    % OSM_LLsubSegmentsKDIds_cellArray = fcn_INTERNAL_buildCellArrayFromMatrix(OSM_LLsubSegmentsKDIds);
    % OSM_XYZsubSegmentsKDIds_cellArray = fcn_INTERNAL_buildCellArrayFromMatrix(OSM_XYZsubSegmentsKDIds);


    %%%% Build KD-trees of PennDOT data
    tic
    kdtreeModelLL = createns(OSM_LLSegmentsKDIds(:,1:2), 'NSMethod', 'kdtree');
    timeToCreateKDtree = toc;
    fprintf(1,'KD tree formation of LL segments data took %.3f seconds\n',timeToCreateKDtree);

    tic
    kdtreeModelLLsub = createns(OSM_LLsubSegmentsKDIds(:,1:2), 'NSMethod', 'kdtree');
    timeToCreateKDtree = toc;
    fprintf(1,'KD tree formation of LL subsegments data took %.3f seconds\n',timeToCreateKDtree);

    tic
    kdtreeModelECEF = createns(OSM_XYZSegmentsKDIds(:,1:3), 'NSMethod', 'kdtree');
    timeToCreateKDtree = toc;
    fprintf(1,'KD tree formation of EN segments data took %.3f seconds\n',timeToCreateKDtree);

    tic
    kdtreeModelECEFsub = createns(OSM_XYZsubSegmentsKDIds(:,1:3), 'NSMethod', 'kdtree');
    timeToCreateKDtree = toc;
    fprintf(1,'KD tree formation of EN subsegments data took %.3f seconds\n',timeToCreateKDtree);

    % % Save results
    % save(sourceDataFilePath,...
    %     'kdtreeModelLL','OSM_LLSegmentsKDIds','OSM_LLSegmentsKDIds_cellArray', ...
    %     'kdtreeModelLLsub','OSM_LLsubSegmentsKDIds', 'OSM_LLsubSegmentsKDIds_cellArray',...
    %     'kdtreeModelECEF', 'OSM_XYZSegmentsKDIds','OSM_XYZSegmentsKDIds_cellArray',...
    %     'kdtreeModelECEFsub','PennDOT_XYZsubSegmentsKDIds','OSM_XYZsubSegmentsKDIds_cellArray');
    save(sourceDataFilePath,...
        'kdtreeModelLL','OSM_LLSegmentsKDIds', ...
        'kdtreeModelLLsub','OSM_LLsubSegmentsKDIds',...
        'kdtreeModelECEF', 'OSM_XYZSegmentsKDIds',...
        'kdtreeModelECEFsub','OSM_XYZsubSegmentsKDIds');
end


%% Load all roads from PennDOT data (Query)


sourceDataFileName = 'PennDOT_geospatialTable';
sourceDataFilePath = fullfile(pwd,'Data',cat(2,sourceDataFileName,'.mat'));
if flag_loadDataFilesWhenPossible && exist(sourceDataFilePath,'file')
    load(sourceDataFilePath,'PennDOT_geospatialTable');
else
    % Load the data and create the data file
    fprintf(1,'\tLoading... (this will take about 20 seconds).\n');

    % Shape file string of PA highways
    shapeFileString = fullfile(pwd,'Data','PennDOT Road Shpfile','PennDOT Road Shapefile.shp');

    % Create a geospatial table
    PennDOT_geospatialTable = fcn_OSM2SHP_loadShapeFile(shapeFileString, (-1));

    % Save the results
    save(sourceDataFilePath,'PennDOT_geospatialTable');

end

sourceDataFileName = 'PennDOT_LLcoordinates';
sourceDataFilePath = fullfile(pwd,'LargeData',cat(2,sourceDataFileName,'.mat'));
if 1==1 && flag_loadDataFilesWhenPossible && exist(sourceDataFilePath,'file')
    load(sourceDataFilePath,'PennDOT_LLSegments_matrix','PennDOT_LLSegments_cellArray','usableTableRows');
else

    % Call the function
    [PennDOT_LLSegments_matrix, PennDOT_LLSegments_cellArray] = fcn_OSM2SHP_extractLLFromGeospatialTable(PennDOT_geospatialTable, (-1));

    % Good segments should be kept in the table
    segmentsKept = PennDOT_LLSegments_matrix(:,3);
    segmentsKept = segmentsKept(~isnan(segmentsKept));
    segmentsKept = unique(segmentsKept);
    usableTableRows = false(height(PennDOT_geospatialTable),1);
    usableTableRows(segmentsKept) = true;

    % Save the results
    save(sourceDataFilePath,'PennDOT_LLSegments_matrix','PennDOT_LLSegments_cellArray','usableTableRows');


end


%% Use ECEF KD-tree range search for PennDOT-OSM matching
% Note: The current global ECEF KD-tree search is very slow.
% In the current implementation, processing 1000 segments takes about 5 minutes,
% which is too expensive for large-scale matching. This suggests that the
% global point-level KD-tree is likely too large, and a more localized search
% strategy such as spatial tiling or local KD-trees should be considered.
% ~5 minutes to process 1000 PennDOT segments
r_meter = 8;
flag_do_plot = 0;
% N_total_segments = length(NIRA_LLSegments_cellArray);
N_total_segments = length(PennDOT_LLSegments_cellArray);
notMatched_mask = false(N_total_segments,1);
PennDOT_matchedOSM_ID = nan(N_total_segments, 1);

% Set up GPS object - this is used to convert LLA to ENU and vice versa
reference_latitude = 40.86368573; %#ok<NASGU>
reference_longitude = -77.83592832; %#ok<NASGU>
reference_altitude = 344.189;
% Initialize WGS84 ellipsoid model (units: meters) for LLA <-> ECEF conversions
wgs84 = wgs84Ellipsoid('meters');

tic
for ith_PennDOT_segment = 1:1000
    % queryPointsLL = NIRA_LLSegments_cellArray{ith_NIRA_segment};
    queryPointsLL = PennDOT_LLSegments_cellArray{ith_PennDOT_segment}(:,1:2);
    Npoints_1 = size(queryPointsLL,1);
    altitudeColumn = ones(Npoints_1,1)*reference_altitude;
    queryPointsLLA = [queryPointsLL, altitudeColumn];
    % Convert LLA to ECEF
    [X, Y, Z] = geodetic2ecef(wgs84, queryPointsLLA(:,1), queryPointsLLA(:,2), queryPointsLLA(:,3));
    queryPoints = [X, Y, Z];

    [idxCell, distCell] = rangesearch(kdtreeModelECEFsub, queryPoints, r_meter);
    %
    % % Collect all matched PennDOT row indices
    % idxCell_nonempty = idxCell(~cellfun(@isempty, idxCell));
    %
    % if isempty(idxCell_nonempty)
    %     notMatched_mask(ith_NIRA_segment) = true;
    %     continue;
    % end
    %
    % idxCell_nonempty = idxCell(~cellfun(@isempty, idxCell));
    % idxCell_nonempty = cellfun(@(x) x(:), idxCell_nonempty, 'UniformOutput', false);
    % all_row_idx = vertcat(idxCell_nonempty{:});
    %
    %
    % all_row_idx = sort(all_row_idx);
    % PennDOT_ids_inRange = PennDOT_LLsubSegmentsKDIds(all_row_idx,3);
    % PennDOT_ids_inRange_unique = unique(PennDOT_ids_inRange);
    % bestScore = -inf;
    % bestID = nan;
    % query_length = fcn_Path_calcPathStation(queryPoints,-1);
    % query_heading = fcn_INTERNAL_estHeadingFromTwoPoints(queryPointsLLA(1,1:2), queryPointsLLA(end,1:2));
    % N_candidates = length(PennDOT_ids_inRange_unique);
    % candidate_segmentes_cell = cell(N_candidates, 3);
    %
    % for ith_ID = 1:N_candidates
    %     thisID = PennDOT_ids_inRange_unique(ith_ID);
    %     % Matched rows of this candidate
    %     thisMatchedRows = all_row_idx(PennDOT_LLsubSegmentsKDIds(all_row_idx,3) == thisID);
    %     thisMatchedRows = unique(thisMatchedRows);
    %     if isempty(thisMatchedRows)
    %         continue
    %     end
    %     thisPointsLL = PennDOT_LLsubSegmentsKDIds(thisMatchedRows, 1:2);
    %     thisPointsXYZ = PennDOT_XYZsubSegmentsKDIds(thisMatchedRows, 1:3);
    %     segment_length = fcn_Path_calcPathStation(thisPointsXYZ, -1);
    %     if size(thisPointsXYZ,1) < 2
    %         continue;
    %     end
    %     % calculate match score
    %     score_match = max(segment_length) / max(query_length);
    %
    %     % calculate heading score
    %     segment_heading = fcn_INTERNAL_estHeadingFromTwoPoints(thisPointsLL(1,:), thisPointsLL(end,:));
    %
    %     dtheta = abs(query_heading - segment_heading);
    %     dtheta = mod(dtheta,360);
    %     dtheta = min(dtheta,360-dtheta);
    %     dtheta = min(dtheta,180-dtheta); % undirected
    %
    %     theta_max = 30; % deg
    %     score_heading = max(0, 1 - dtheta/theta_max);
    %
    %     % Calculate distance score
    %     min_dist_candidate = inf(size(queryPoints,1),1);
    %
    %     for i_point = 1:length(idxCell)
    %         ids_i = idxCell{i_point};
    %         if isempty(ids_i)
    %             continue;
    %         end
    %
    %         dists_i = distCell{i_point};
    %
    %
    %         mask_i = PennDOT_LLsubSegmentsKDIds(ids_i,3) == thisID;
    %
    %         if any(mask_i)
    %             min_dist_candidate(i_point) = min(dists_i(mask_i));
    %         end
    %     end
    %
    %     valid_mask = isfinite(min_dist_candidate);
    %
    %     if any(valid_mask)
    %         dist_med = median(min_dist_candidate(valid_mask));
    %     else
    %         dist_med = inf;
    %     end
    %
    %     dist_max = r_meter; % meters
    %     score_dist = max(0, 1 - dist_med/dist_max);
    %
    %     % -----------------------------
    %     % 4. Total score
    %     % -----------------------------
    %     thisScore = 0.5*score_match + 0.3*score_heading + 0.2*score_dist;
    %
    %     if thisScore > bestScore
    %         bestScore = thisScore;
    %         bestID = thisID;
    %
    %     end
    %     if flag_do_plot
    %         candidate_segmentes_cell{ith_ID, 1} = thisID;
    %         candidate_segmentes_cell{ith_ID, 2} = thisMatchedRows;
    %         candidate_segmentes_cell{ith_ID, 3} = thisScore;
    %         best_ith_ID = ith_ID;
    %     end
    %
    % end
    %
    % NIRA_matchedPennDOT_ID(ith_NIRA_segment) = bestID;
    %
    % if flag_do_plot
    %     figNum = 123;
    %     figure(figNum);
    %     clf
    %
    %     colors = rand(length(PennDOT_ids_inRange_unique), 3);
    %     legendEntries = cell(length(PennDOT_ids_inRange_unique)+1,1);
    %     for ith_ID = 1:length(PennDOT_ids_inRange_unique)
    %         thisID = candidate_segmentes_cell{ith_ID,1};
    %         thisMatchedRows = candidate_segmentes_cell{ith_ID,2};
    %         thisPoints = PennDOT_LLsubSegmentsKDIds(thisMatchedRows, 1:2);
    %         plotFormat.Marker = '.';
    %         plotFormat.Color = colors(ith_ID, :);
    %         plotFormat.MarkerSize = 50;
    %         plotFormat.LineStyle = '-';
    %         plotFormat.LineWidth = 15;
    %         fcn_plotRoad_plotLL(thisPoints, (plotFormat), (figNum));
    %         legendEntries{ith_ID} = sprintf('PennDOT ID: %d', thisID);
    %     end
    %     plotFormat.Color = [0 1 0];
    %     fcn_plotRoad_plotLL(queryPointsLLA(:,1:2), (plotFormat), (figNum));
    %     legendEntries{end} = 'NIRA Segment';
    %     legend(legendEntries, 'Location','best');
    %     title(sprintf('NIRA Segment %d Matching Candidates', ith_NIRA_segment));
    %
    %     figure(figNum + 1)
    %     clf
    %     plotFormat.Color = [1 0 0];
    %     thisID = candidate_segmentes_cell{best_ith_ID,1};
    %     assert(thisID == bestID);
    %     thisMatchedRows = candidate_segmentes_cell{best_ith_ID,2};
    %     thisPoints = PennDOT_LLsubSegmentsKDIds(thisMatchedRows, 1:2);
    %     fcn_plotRoad_plotLL(thisPoints(:,1:2), (plotFormat), (figNum + 1));
    %     plotFormat.Color = [0 1 0];
    %     fcn_plotRoad_plotLL(queryPointsLLA(:,1:2), (plotFormat), (figNum + 1));
    %     legend(legendEntries{best_ith_ID},legendEntries{end},'Location', 'best')
    %     title(sprintf('NIRA Segment %d Matching Result', ith_NIRA_segment));
    % end
end
timeToUseKDtree = toc;
fprintf(1,'Use KD tree with range search took %.3f seconds\n',timeToUseKDtree);

%% Grid KD Tree formation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____      _     _   _  _______    _______
%  / ____|    (_)   | | | |/ /  __ \  |__   __|
% | |  __ _ __ _  __| | | ' /| |  | |    | |_ __ ___  ___  ___
% | | |_ | '__| |/ _` | |  < | |  | |    | | '__/ _ \/ _ \/ __|
% | |__| | |  | | (_| | | . \| |__| |    | | | |  __/  __/\__ \
%  \_____|_|  |_|\__,_| |_|\_\_____/     |_|_|  \___|\___||___/
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: Instead of using one global ECEF KD-tree for all PennDOT points,
% this implementation first partitions PennDOT points into 10 km grids
% using ECEF X,Y coordinates. A local KD-tree is then built inside each
% non-empty grid.

titleString = sprintf('Building Grid KD Trees');
fprintf(1,'%s\n', titleString);

sourceDataFileName = 'OSM_KDTrees_10kmGrid';
sourceDataFilePath = fullfile(pwd,'LargeData',cat(2,sourceDataFileName,'.mat'));

if 1==1 && flag_loadDataFilesWhenPossible && exist(sourceDataFilePath,'file')
    load(sourceDataFilePath, ...
        'grid_size', ...
        'Xmin_grid','Ymin_grid', ...
        'gridKeys_unique', ...
        'gridXY_lookup', ...
        'gridKDTreesECEFsub', ...
        'OSM_LLSegmentsKDIds', ...
        'OSM_LLsubSegmentsKDIds', ...
        'OSM_XYZSegmentsKDIds', ...
        'OSM_XYZsubSegmentsKDIds', ...
        'gridPointIndices_cellArray', ...
        'gridSegmentIDs_cellArray'); %#ok<NASGU>

else

    %%%% Load the data
    warning('This process is VERY slow and may take 10+ minutes.')

    tempDataFileName = 'OSM_Subsegments';
    tempsourceDataFilePath = fullfile(pwd,'LargeData',cat(2,tempDataFileName,'.mat'));

    if 1==1 && flag_loadDataFilesWhenPossible && exist(tempsourceDataFilePath,'file')
        load(tempsourceDataFilePath, ...
            'OSM_XYZsubSegments_cellArray', ...
            'OSM_LLsubSegments_cellArray', ...
            'OSM_XYZSegments_cellArray', ...
            'OSM_LLSegments_cellArray')
    else
        error('Unable to find load file:\n\t%s\n. Run main demo script to produce this.\n',tempsourceDataFilePath);
    end

    % Make sure sizes of LL data are consistent with XYZ data for both segments
    % and subsegments
    assert(isequal(size(OSM_XYZsubSegments_cellArray),size(OSM_LLsubSegments_cellArray)));
    assert(isequal(size(OSM_XYZSegments_cellArray),size(OSM_LLSegments_cellArray)));

    %%%% Create the matrix versions of all cell arrays
    OSM_LLSegments_matrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(OSM_LLSegments_cellArray,-1);
    OSM_LLsubSegments_matrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(OSM_LLsubSegments_cellArray,-1);
    OSM_XYZSegments_matrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(OSM_XYZSegments_cellArray,-1);
    OSM_XYZsubSegments_matrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(OSM_XYZsubSegments_cellArray,-1);

    % Remove NaN rows
    nanRows = isnan(OSM_LLSegments_matrix(:,1));
    OSM_LLSegments_matrix_noNaN = OSM_LLSegments_matrix(~nanRows,:);
    OSM_XYZSegments_matrix_noNaN = OSM_XYZSegments_matrix(~nanRows,:);

    % Make sure the matrices are still the same
    NumRows = size(OSM_XYZSegments_matrix_noNaN,1);
    assert(size(OSM_LLSegments_matrix_noNaN,1) == NumRows);

    % Build the reference matrices for the KD tree formation
    KDids = (1:NumRows)';
    OSM_LLSegmentsKDIds = [OSM_LLSegments_matrix_noNaN KDids];
    OSM_XYZSegmentsKDIds = [OSM_XYZSegments_matrix_noNaN KDids];

    % Remove NaN rows from subsegment matrices
    nanRows = isnan(OSM_LLsubSegments_matrix(:,1));
    OSM_LLsubSegments_matrix_noNaN = OSM_LLsubSegments_matrix(~nanRows,:);
    OSM_XYZsubSegments_matrix_noNaN = OSM_XYZsubSegments_matrix(~nanRows,:);

    % Make sure the matrices are still the same
    NumRows = size(OSM_XYZsubSegments_matrix_noNaN,1);
    assert(size(OSM_LLsubSegments_matrix_noNaN,1) == NumRows);

    % Build the reference matrices for the KD tree formation
    KDids = (1:NumRows)';
    OSM_LLsubSegmentsKDIds = [OSM_LLsubSegments_matrix_noNaN, KDids];
    OSM_XYZsubSegmentsKDIds = [OSM_XYZsubSegments_matrix_noNaN, KDids];


    % Build grid indices using ECEF X,Y only
    grid_size = 10000; % meters

    X = OSM_XYZsubSegmentsKDIds(:,1);
    Y = OSM_XYZsubSegmentsKDIds(:,2);

    Xmin_grid = min(X);
    Ymin_grid = min(Y);

    grid_x = floor((X - Xmin_grid)./grid_size) + 1;
    grid_y = floor((Y - Ymin_grid)./grid_size) + 1;

    gridXY_all = [grid_x grid_y];

    % Find all unique non-empty grids
    [gridXY_lookup,~,gridID_perPoint] = unique(gridXY_all,'rows');
    Ngrids = size(gridXY_lookup,1);

    % Create a unique key per grid
    gridKeys_unique = gridXY_lookup(:,1)*1000000 + gridXY_lookup(:,2);

    % Preallocate storage
    gridKDTreesECEFsub = cell(Ngrids,1);
    gridPointIndices_cellArray = cell(Ngrids,1);
    gridSegmentIDs_cellArray = cell(Ngrids,1);

    fprintf(1,'Total number of non-empty 10 km grids: %.0f\n',Ngrids);

    % Build one KD-tree per non-empty grid

    tic
    for ith_grid = 1:Ngrids

        thisPointIndices = find(gridID_perPoint==ith_grid);
        gridPointIndices_cellArray{ith_grid} = thisPointIndices;

        thisXYZKDIds = OSM_XYZsubSegmentsKDIds(thisPointIndices,:);

        % Build local KD-tree using XYZ columns
        gridKDTreesECEFsub{ith_grid} = createns(thisXYZKDIds(:,1:3), 'NSMethod', 'kdtree');

        % Store associated KD ids
        gridSegmentIDs_cellArray{ith_grid} = thisXYZKDIds(:,4);

        if mod(ith_grid,100)==0 || ith_grid==Ngrids
            fprintf(1,'Built %.0f / %.0f grid KD trees\n',ith_grid,Ngrids);
        end
    end
    timeToCreateGridKDtrees = toc;
    fprintf(1,'Grid KD tree formation of ECEF subsegments data took %.3f seconds\n',timeToCreateGridKDtrees);

    % Save results'
    save(sourceDataFilePath, ...
        'grid_size', ...
        'Xmin_grid','Ymin_grid', ...
        'gridKeys_unique', ...
        'gridXY_lookup', ...
        'gridKDTreesECEFsub', ...
        'OSM_LLSegmentsKDIds', ...
        'OSM_LLsubSegmentsKDIds', ...
        'OSM_XYZSegmentsKDIds', ...
        'OSM_XYZsubSegmentsKDIds', ...
        'gridPointIndices_cellArray', ...
        'gridSegmentIDs_cellArray');
end



%% Use grid ECEF KD-tree range search for OSM–PennDOT matching
% Note: The current implementation uses local grid-based ECEF KD-trees
% instead of one global KD-tree. Each OSM segment first identifies which
% grids it falls into based on ECEF X,Y coordinates, and then performs
% range search only within the corresponding local KD-trees.

% It is taking too long run this! After a few hours MATLAB crashes. For
% Aneesh, it crashed after 2.5 hrs. 

r_meter = 8;
flag_do_plot = 1;
% N_total_segments = length(NIRA_LLSegments_cellArray);
N_total_segments = length(PennDOT_LLSegments_cellArray);
% N_total_segments = 2000;

% Set up GPS object - this is used to convert LLA to ENU and vice versa
reference_latitude = 40.86368573; %#ok<NASGU>
reference_longitude = -77.83592832; %#ok<NASGU>
reference_altitude = 344.189;
% Initialize WGS84 ellipsoid model (units: meters) for LLA <-> ECEF conversions
wgs84 = wgs84Ellipsoid('meters');

notMatched_mask = false(N_total_segments,1);
PennDOT_matchedOSM_ID = cell(N_total_segments, 1);
flag_do_resample = 1;
increment = 2;

tic
for ith_PennDOT_segment = 1:N_total_segments
    % queryPointsLL = NIRA_LLSegments_cellArray{ith_NIRA_segment};
    queryPointsLL = PennDOT_LLSegments_cellArray{ith_PennDOT_segment}(:,1:2);
    Npoints_1 = size(queryPointsLL,1);
    altitudeColumn = ones(Npoints_1,1)*reference_altitude;
    queryPointsLLA = [queryPointsLL, altitudeColumn];

    % Convert LLA to ECEF
    [X, Y, Z] = geodetic2ecef(wgs84, queryPointsLLA(:,1), queryPointsLLA(:,2), queryPointsLLA(:,3));
    thisXYZ = [X, Y, Z];
    % Calculate stations
    if flag_do_resample
        stations = fcn_Path_calcPathStation(thisXYZ,-1);

        % Determine new stations

        newStations = (stations(1):increment:stations(end))';
        if newStations(end)~=stations(end)
            newStations(end+1,1) = stations(end); %#ok<SAGROW> % Ensure the last station is included
        end
        % Make sure there's no NaN values (the Path code below won't work)
        if any(isnan(thisXYZ(:,1)),'all')
            error('Nan value found in data - unable to continue.');
        end

        % Make sure there's no repeats
        if ~isequal(unique(thisXYZ,'rows','stable'),thisXYZ)
            % NsegmentsWithRepeats = NsegmentsWithRepeats+1;
            thisXYZ = unique(thisXYZ,'rows','stable');
        end
        % Resample path at new stations
        queryPoints = fcn_Path_newPathByStationResampling(thisXYZ,newStations,-1);
    else
        queryPoints = thisXYZ;
    end




    % Find which grids the query points belong to
    grid_x_query = floor((queryPoints(:,1) - Xmin_grid)./grid_size) + 1;
    grid_y_query = floor((queryPoints(:,2) - Ymin_grid)./grid_size) + 1;
    queryGridXY = unique([grid_x_query grid_y_query],'rows');
    queryGridKeys = queryGridXY(:,1)*1000000 + queryGridXY(:,2);

    candidateGridIdx = find(ismember(gridKeys_unique, queryGridKeys));

    if isempty(candidateGridIdx)
        notMatched_mask(ith_PennDOT_segment) = true;
        continue;
    end

    all_row_idx = [];

    all_query_point_idx = [];

    % Range search within each corresponding local grid KD-tree
    for ith_grid = 1:length(candidateGridIdx)
        thisGridIdx = candidateGridIdx(ith_grid);

        thisKDTree = gridKDTreesECEFsub{thisGridIdx};
        thisPointIndices = gridPointIndices_cellArray{thisGridIdx};

        [idxCell_local, distCell_local] = rangesearch(thisKDTree, queryPoints, r_meter);

        valid_mask = ~cellfun(@isempty, idxCell_local);

        idxCell_valid = idxCell_local(valid_mask);
        distCell_valid = distCell_local(valid_mask);
        if isempty(idxCell_valid)
            continue;
        end

        idxs_local = cell2mat(cellfun(@(x) x(:), idxCell_valid, 'UniformOutput', false));
        idxs_global = thisPointIndices(idxs_local);
        all_row_idx = [all_row_idx; idxs_global(:)];

        query_idx_valid = find(valid_mask);
        counts_per_query = cellfun(@numel, idxCell_valid);
        query_idx_repeated = repelem(query_idx_valid, counts_per_query)';
        all_query_point_idx = [all_query_point_idx; query_idx_repeated(:)];
    end

    if isempty(all_row_idx)
        notMatched_mask(ith_PennDOT_segment) = true;
        continue;
    end
    pair_mat = [all_row_idx, all_query_point_idx];
    pair_mat = unique(pair_mat, 'rows');

    all_row_idx = pair_mat(:,1);
    all_query_point_idx = pair_mat(:,2);
    OSM_ids_inRange = OSM_LLsubSegmentsKDIds(all_row_idx,3);
    OSM_ids_inRange_unique = unique(OSM_ids_inRange);

    query_length = fcn_Path_calcPathStation(queryPoints,-1);
    query_heading = fcn_INTERNAL_estHeadingFromTwoPoints(queryPointsLLA(1,1:2), queryPointsLLA(end,1:2));
    N_candidates = length(OSM_ids_inRange_unique);
    candidate_segmentes_cell = cell(N_candidates, 3);

    keptIDs = [];
    keptScores = [];

    for ith_ID = 1:N_candidates
        % Grab the PennDOT ID for current segment
        thisID = OSM_ids_inRange_unique(ith_ID);

        % Matched rows of this candidate
        thisMask = OSM_LLsubSegmentsKDIds(all_row_idx,3) == thisID;
        thisMatchedRows = all_row_idx(thisMask);
        thisMatchedQueryIdx = all_query_point_idx(thisMask);
        if isempty(thisMatchedRows)
            continue
        end
        thisMatchedRows = sort(thisMatchedRows);
        thisMatchedQueryIdx = unique(sort(thisMatchedQueryIdx));
        if numel(thisMatchedQueryIdx) < 2
            continue
        end

        % Extract matched points from the road segment
        thisPointsLL = OSM_LLsubSegmentsKDIds(thisMatchedRows, 1:2);
        thisPointsXYZ = OSM_XYZsubSegmentsKDIds(thisMatchedRows, 1:3);

        % Extract matched query points from the NIRA segment
        queryPoints_thisID = queryPoints(thisMatchedQueryIdx, :);
        query_length_thisID = fcn_Path_calcPathStation(queryPoints_thisID, -1);
        % calculate match score
        segment_length = fcn_Path_calcPathStation(thisPointsXYZ, -1);
        score_match = min(max(segment_length) / max(query_length_thisID), 1);


        % calculate heading score
        segment_heading = fcn_INTERNAL_estHeadingFromTwoPoints(thisPointsLL(1,:), thisPointsLL(end,:));

        dtheta = abs(query_heading - segment_heading);
        dtheta = mod(dtheta,360);
        dtheta = min(dtheta,360-dtheta);
        dtheta = min(dtheta,180-dtheta); % undirected

        theta_max = 30; % deg
        score_heading = max(0, 1 - dtheta/theta_max);

        % Calculate distance score
        thisBlockDist = pdist2(queryPoints_thisID, thisPointsXYZ);
        minDist_per_query = min(thisBlockDist, [], 2);
        if ~isempty(minDist_per_query)
            dist_med = median(minDist_per_query);
        else
            dist_med = inf;
        end

        dist_max = r_meter; % meters
        score_dist = max(0, 1 - dist_med/dist_max);

        % -----------------------------
        % 4. Total score
        % -----------------------------
        thisScore = 0.3*score_match + 0.4*score_heading + 0.3*score_dist;

        % Keep all candidates above threshold, 0.9 comes from observations
        if thisScore > 0.9
            keptIDs = [keptIDs; thisID];
            keptScores = [keptScores; thisScore];
        end

        if flag_do_plot
            candidate_segmentes_cell{ith_ID, 1} = thisID;
            candidate_segmentes_cell{ith_ID, 2} = thisMatchedRows;
            candidate_segmentes_cell{ith_ID, 3} = thisScore;
        end
    end

    if ~isempty(keptIDs)
        [keptScores, sortIdx] = sort(keptScores,'descend');
        keptIDs = keptIDs(sortIdx);

        PennDOT_matchedOSM_ID{ith_PennDOT_segment} = keptIDs;
    else

        notMatched_mask(ith_PennDOT_segment) = true;
    end


    %
    if flag_do_plot
        figure(figNum);
        clf

        colors = rand(N_candidates, 3);
        legendEntries = cell(N_candidates+1,1);

        for ith_ID = 1:N_candidates
            thisID = candidate_segmentes_cell{ith_ID,1};
            thisMatchedRows = candidate_segmentes_cell{ith_ID,2};

            thisPoints = OSM_LLsubSegmentsKDIds(thisMatchedRows, 1:2);

            plotFormat.Marker = '.';
            plotFormat.MarkerSize = 50;
            plotFormat.LineStyle = '-';
            plotFormat.LineWidth = 4;
            plotFormat.Color = colors(ith_ID,:);

            fcn_plotRoad_plotLL(thisPoints, plotFormat, figNum);

            legendEntries{ith_ID} = sprintf('ID: %d (%.2f)', ...
                thisID, candidate_segmentes_cell{ith_ID,3});
        end

        plotFormat.Color = [0 1 0];
        fcn_plotRoad_plotLL(queryPointsLLA(:,1:2), plotFormat, figNum);

        legendEntries{end} = 'OSM Segment';
        legend(legendEntries, 'Location','best');

        title(sprintf('All Candidates - Segment %d', ith_PennDOT_segment));
        if isempty(keptIDs)
            continue
        end
        figure(figNum + 1)
        clf

        colors = rand(length(keptIDs), 3);
        legendEntries = cell(length(keptIDs)+1,1);

        for ith_ID = 1:length(keptIDs)
            thisID = keptIDs(ith_ID);

            idx_in_candidates = find(cell2mat(candidate_segmentes_cell(:,1)) == thisID,1);

            thisMatchedRows = candidate_segmentes_cell{idx_in_candidates,2};
            thisPoints = OSM_LLsubSegmentsKDIds(thisMatchedRows, 1:2);

            plotFormat.Marker = '.';
            plotFormat.MarkerSize = 50;
            plotFormat.LineStyle = '-';
            plotFormat.LineWidth = 6;
            plotFormat.Color = colors(ith_ID,:);

            fcn_plotRoad_plotLL(thisPoints, plotFormat, figNum + 1);

            legendEntries{ith_ID} = sprintf('ID: %d (%.2f)', ...
                thisID, candidate_segmentes_cell{idx_in_candidates,3});
        end

        plotFormat.Color = [0 1 0];
        fcn_plotRoad_plotLL(queryPointsLLA(:,1:2), plotFormat, figNum + 1);

        legendEntries{end} = 'OSM Segment';
        legend(legendEntries, 'Location','best');

        title(sprintf('Kept Candidates - Segment %d', ith_PennDOT_segment));
    end
end
timeToUseKDtree = toc;
fprintf(1,'Use grid KD tree with range search took %.3f seconds\n',timeToUseKDtree);
%% Save PennDOT data with OSM ID
csvTable.PennDOT_id = PennDOT_matchedOSM_ID;
sourceDataFileName = 'PennDOT_with_OSM_ID_small_sample';
sourceDataFilePath = fullfile(pwd,'Data',cat(2,sourceDataFileName,'.mat'));
save(sourceDataFilePath,'csvTable')
%% Test query accuracy
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _______        _      ____
%  |__   __|      | |    / __ \                            /\
%     | | ___  ___| |_  | |  | |_   _  ___ _ __ _   _     /  \   ___ ___ _   _ _ __ __ _  ___ _   _
%     | |/ _ \/ __| __| | |  | | | | |/ _ \ '__| | | |   / /\ \ / __/ __| | | | '__/ _` |/ __| | | |
%     | |  __/\__ \ |_  | |__| | |_| |  __/ |  | |_| |  / ____ \ (_| (__| |_| | | | (_| | (__| |_| |
%     |_|\___||___/\__|  \___\_\\__,_|\___|_|   \__, | /_/    \_\___\___|\__,_|_|  \__,_|\___|\__, |
%                                                __/ |                                         __/ |
%                                               |___/                                         |___/
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Test+Query+Accuracy&x=none&v=4&h=4&w=80&we=false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figNum = 60001;
titleString = sprintf('Testing Query Accuracy');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Load the LL data?
expectedVariables = {'kdtreeModelLL','OSM_LLSegmentsKDIds','OSM_LLSegmentsKDIds_cellArray', ...
    'kdtreeModelLLsub','OSM_LLsubSegmentsKDIds', 'OSM_LLsubSegmentsKDIds_cellArray',...
    'kdtreeModelEN', 'OSM_ENSegmentsKDIds','OSM_ENSegmentsKDIds_cellArray',...
    'kdtreeModelENsub','OSM_ENsubSegmentsKDIds','OSM_ENsubSegmentsKDIds_cellArray'};
flagMustLoad = false;
for ith_var = 1:length(expectedVariables)
    thisVariable = expectedVariables{ith_var};
    if ~exist(thisVariable,'var')
        flagMustLoad = true;
    end
end

if flagMustLoad
    PreviousDataFileName = 'OSM_KDTrees';
    PreviouseDataFilePath = fullfile(pwd,'LargeData',cat(2,PreviousDataFileName,'.mat'));
    if flag_loadDataFilesWhenPossible && exist(PreviouseDataFilePath,'file')
        load(PreviouseDataFilePath,expectedVariables{:});
    else
        error('Unable to load file: \n\t%s\nNeed to run prior section in this script!',PreviouseDataFilePath);
    end
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

%% fcn_INTERNAL_estHeadingFromTwoPoints
function heading_deg = fcn_INTERNAL_estHeadingFromTwoPoints(point1_LL, point2_LL)

lat1 = point1_LL(1);
lon1 = point1_LL(2);
lat2 = point2_LL(1);
lon2 = point2_LL(2);

dLat = lat2 - lat1;
dLon = lon2 - lon1;

heading_deg = atan2d(dLon*cosd(lat1), dLat);
heading_deg = mod(heading_deg, 360);

end

%% fcn_INTERNAL_buildCellArrayFromMatrix
function cellArrayOutput = fcn_INTERNAL_buildCellArrayFromMatrix(matrix)

matrixWithNans = insertNanRows(matrix);
cellArrayIndices = fcn_DebugTools_breakArrayByNans(matrixWithNans,-1);

% Fill up cell array
Ncells = length(cellArrayIndices);
cellArrayOutput = cell(Ncells,1);
for ith_array = 1:Ncells
    thisIndicies = cellArrayIndices{ith_array};
    cellArrayOutput{ith_array,1} = matrixWithNans(thisIndicies,:);
end
end % Ends fcn_INTERNAL_buildCellArrayFromMatrix

%% insertNanRows
function B = insertNanRows(A)
% INSERTNANROWS Insert a full NaN row whenever the first-column value changes.
%   B = INSERTNANROWS(A) returns A with a row of NaN inserted immediately
%   before every row where the value in column 1 differs from the previous row.
%
% If change coloumn is 1:
% A = [1 10; 1 11; 2 20; 2 21; 3 30];
% B = insertNanRows(A)
%
% Gives:
%
%   1    10
%   1    11
% NaN   NaN
%   2    20
%   2    21
% NaN   NaN
%   3    30


if isempty(A)
    B = A;
    return
end

nrowsSource = size(A,1);
ncolsSource = size(A,2);

changeColumn = A(:,3);
isNewGroup = [false; diff(changeColumn) ~= 0];

% Count the number of NaN rows
numNanRows = cumsum(isNewGroup,1);

% Initialize vectors
nrowsDestination = nrowsSource + numNanRows(end);

% Create destination indicies - these are the rows where the data from the
% source is being copied to
destinationIndices = (1:nrowsSource)';
destinationIndices = destinationIndices + numNanRows;

% Save results
out = nan(nrowsDestination,ncolsSource);
out(destinationIndices,:) = A;

B = out;
end % ENds insertNanRows

%% fcn_INTERNAL_createTestPoints

function [truePoints, unitVectorsAtTruePoints] = fcn_INTERNAL_createTestPoints(Npoints, PennDOT_ENSegmentsKDIds_cellArray)



%%%%%%%%%%%%%
% Pick random segments
Nsegments = length(PennDOT_ENSegmentsKDIds_cellArray);
if 1==1
    randomSegments = randi([1 Nsegments], Npoints, 1);
else
    % Generate random integers, no repeats, between 1 and the number of
    % segments
    nRows = size(pointMatrix,1);

    % Use randperm to generate random index list
    randomIdx = randperm(nRows, Npoints);

    % Pull a random number of true points out
    randomSegments = sort(randomIdx);
end

% In each segment, choose a random station
uniqueSegmentNumbers = unique(randomSegments);
NpointsSoFar = 0;
truePoints = nan(Npoints,2);
unitVectorsAtTruePoints = nan(Npoints,2);
NumNonUnique = 0;
for ith_segment = 2:length(uniqueSegmentNumbers)
    thisSegment = uniqueSegmentNumbers(ith_segment);
    numThisSegment = sum(randomSegments==thisSegment);
    thisSegmentPath = PennDOT_ENSegmentsKDIds_cellArray{thisSegment,1};

    thisSegmentPathUnique = unique(thisSegmentPath(:,1:2),'rows','stable');
    if ~isequal(thisSegmentPath(:,1:2),thisSegmentPathUnique(:,1:2))
        NumNonUnique = NumNonUnique + 1;
    end

    stationsThisPath = fcn_Path_calcPathStation(thisSegmentPath(:,1:2),-1);
    pathLength = stationsThisPath(end);

    % Generate random stations between 0 and path length
    randomStations = rand(numThisSegment,1)*pathLength;

    % Find ortho projection at station points
    [unit_normal_vector_start, unit_normal_vector_end] = ...
        fcn_Path_findOrthogonalPathVectorsAtStations(...
        randomStations,thisSegmentPath(:,1:2),...
        (1),(-1));

    thisUnitNormalVectors = unit_normal_vector_end - unit_normal_vector_start;
    try
        thisResampledPoints = fcn_Path_newPathByStationResampling(thisSegmentPathUnique(:,1:2),randomStations,-1);
    catch
        disp('stop here');
    end

    % For debugging
    if 1==0
        figure(383838);
        clf;
        hold on;
        plot(thisSegmentPath(:,1),thisSegmentPath(:,2),'k.-','LineWidth',3,'MarkerSize',20);
        axis equal;
        plot(thisResampledPoints(:,1),thisResampledPoints(:,2),'g.','MarkerSize',40);
        quiver(unit_normal_vector_start(:,1),unit_normal_vector_start(:,2),thisUnitNormalVectors(:,1), thisUnitNormalVectors(:,2),0,'r-','LineWidth',5);
    end
    truePoints((NpointsSoFar+1):(NpointsSoFar+numThisSegment),:) = thisResampledPoints;
    unitVectorsAtTruePoints((NpointsSoFar+1):(NpointsSoFar+numThisSegment),:) = thisUnitNormalVectors;

    NpointsSoFar = NpointsSoFar+numThisSegment;

end



end
