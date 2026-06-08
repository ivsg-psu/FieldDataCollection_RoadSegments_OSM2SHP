function stackedMatrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(cellArrayToStack, varargin)
%% fcn_OSM2SHP_stackCellArrayIntoMatrix
% 
% Takes a cell array of matrices and "stacks" them into one matrix, with
% each cell array separated by NaN values. Eliminates situations where
% there may be repeated NaN rows. The last row will be NaN for entire row
% to allow resulting matrix to "stack" onto other matrices as well.
% 
% FORMAT:
%
%       stackedMatrix = fcn_OSM2SHP_stackCellArrayIntoMatrix(cellArrayToStack, (figNum))
%
% INPUTS:
%
%      cellArrayToStack: Cell array of matrices. All matrices need to be
%      same size.
%
%      (OPTIONAL INPUTS)
%
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      stackedMatrix: [N x M] matrix of all cell arrays stacked together,
%      separated by NaN values between the matrices.  
%
% DEPENDENCIES:
%
%      
%
% EXAMPLES:
%
%       See the script:
%
%       script_test_fcn_OSM2SHP_stackCellArrayIntoMatrix.m 
%
%       for a full test suite.
%
% This function was written on 2026_03_14 by Sean Brennan, sbrennan@psu.edu
% Questions or comments? sbrennan@psu.edu


% REVISION HISTORY:
%
% 2026_03_14 by Sean Brennan, sbrennan@psu.edu
% - In fcn_OSM2SHP_stackCellArrayIntoMatrix
%   % * Wrote the code originally
%
% 2026_03_18 by Sean Brennan, sbrennan@psu.edu
% - In fcn_OSM2SHP_stackCellArrayIntoMatrix
%   % * Added test to make sure matrices had same number of columns
%   % * Added test to make sure matrices had nonzero numbers of rows
%   % * Return empty matrix if cell array itself is empty
% 
% 2026_06_06 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_OSM2SHP_stackCellArrayIntoMatrix
%   % * Copied this function to OSM2SHP from PennDOTSHP

% TO-DO:
%
% 2026_03_14 bySean Brennan, sbrennan@psu.edu
% - Add DebugTools options to check the inputs


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
    MATLABFLAG_PENNDOTSHP_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_PENNDOTSHP_FLAG_CHECK_INPUTS");
    MATLABFLAG_PENNDOTSHP_FLAG_DO_DEBUG = getenv("MATLABFLAG_PENNDOTSHP_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_PENNDOTSHP_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_PENNDOTSHP_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_PENNDOTSHP_FLAG_DO_DEBUG); 
        flag_check_inputs  = str2double(MATLABFLAG_PENNDOTSHP_FLAG_CHECK_INPUTS);
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
        figNum = temp; %#ok<NASGU>
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

if isempty(cellArrayToStack)
	stackedMatrix = [];
	return;
end

try
	nCols = size(cellArrayToStack{1},2);
catch
	error('Unable to assess number of columns to use?');
end

% Separate each road segment with NaN matrix 
nan_matrix = nan(1,nCols);

% Make sure all columns counts of all matrices have same number
ncols = cellfun(@(x) size(x,2), cellArrayToStack);
allSame = all(ncols == ncols(1));

if ~allSame
	badIndices = find(ncols~=ncols(1));
	fprintf(1,'The following indices were found with dissimilar columns: %.0f\n',badIndices);
	error('Unable to stack arrays with dissimilar number of columns');
end

% Make sure that cell array has no matrices with zero rows
nrows = cellfun(@(x) size(x,1), cellArrayToStack);
allNonzeroRows = all(nrows > 0);
if ~allNonzeroRows
	badIndices = find(nrows==0);
	fprintf(1,'The following indices were found with zero rows: %.0f\n',badIndices);
	error('Unable to stack arrays where there are zero rows');
end

% Convert road segment cell array into matrix and append NaN matrix at the
% end of each road segment. 
stackedMatrixWithRepeatNaNs = cell2mat( ...
    cellfun(@(ith_segment) [ith_segment; nan_matrix], cellArrayToStack, 'UniformOutput', false));

% Remove any rows that are all NaN and follow a row of NaNs. Basically,
% this removes repeated rows of NaNs
stackedMatrix = fcn_INTERNAL_removeConsecutiveNanRows(stackedMatrixWithRepeatNaNs);


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
    % figure(figNum);

   
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

function B = fcn_INTERNAL_removeConsecutiveNanRows(A)
% removeConsecutiveNanRows  Reduce consecutive rows that contain NaNs to one row
% B = removeConsecutiveNanRows(A)
% Any block of consecutive rows for which any element is NaN will be
% collapsed so only the first row of that block remains.

if isempty(A)
    B = A;
    return
end

rowHasNaN = any(isnan(A(:,1:2)), 2);           % logical per row
% keep a row if it's not NaN-containing, or if it is NaN-containing but
% the previous row was not NaN-containing (start of a block)
keep = ~rowHasNaN | (rowHasNaN & ~[false; rowHasNaN(1:end-1)]);
B = A(keep, :);
end