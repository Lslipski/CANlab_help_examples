function z_batch_publish_analyses(varargin)
% Runs batch analyses and publishes HTML report with figures and stats to
% results/published_output in local study-specific analysis directory.
%
% Run this from the main base directory (basedir)
%
% Enter string for which analyses to run, in any order
%
% 'contrasts'     : Coverage and univariate condition and contrast maps
% 'signatures'    : Pre-defined brain 'signature' responses from CANlab
% 'svm'           : Cross-validated Support Vector Machine analyses for each contrast
% 'bucknerlab'    : Decomposition of each condition and contrast into loadings on resting-state network maps
% 'meta_analysis' : Tests of "pattern of interest" analyses and ROIs derived from CANlab meta-analyses
%
% Default if you run z_batch_publish_analyses with no arguments is to run
% all, in this order.
%
% Or run a custom set:
% - Including an argument with a cell array of strings for analyses you want to run:
% z_batch_publish_analyses({'svm' 'bucknerlab'})

% Define strings for analyses to run
% ------------------------------------------------------------------------

close all
% clear all

if nargin == 0
    analyses_to_run = {'contrasts' 'signatures' 'svm' 'bucknerlab' 'meta_analysis'};
else
    analyses_to_run = varargin{1};
end

% ------------------------------------------------------------------------
% Set paths based on local study-specific base analysis directory.
% Add the study-specific scripts to the top of the path.
% Load saved data.

scriptname = fullfile(pwd, 'scripts', 'a_set_up_paths_always_run_first.m');

if ~exist(scriptname, 'file')
    error('Run from base directory (basedir) of 2nd-level analysis folder.');
else
    run(scriptname)
end

printhdr('Running analyses:');
disp(analyses_to_run)


% Options for publish
% ------------------------------------------------------------------------

pubdir = fullfile(resultsdir, 'published_output');
if ~exist(pubdir, 'dir'), mkdir(pubdir), end

disp(' ');
disp('Saving published HTML reports here:');
disp(pubdir);
disp(' ');


% Reload all saved data
% ------------------------------------------------------------------------

b_reload_saved_matfiles           % done in indivdidual scripts to save output info in html, but re-run here so vars are available



% Loop through and run
% ------------------------------------------------------------------------
if ~iscell(analyses_to_run), analyses_to_run = {analyses_to_run}; end

for i = 1:length(analyses_to_run)
    
    analysis_str = analyses_to_run{i};
    
    % 'contrasts'     : Coverage and univariate condition and contrast maps
    % 'signatures'    : Pre-defined brain 'signature' responses from CANlab
    % 'svm'           : Cross-validated Support Vector Machine analyses for each contrast
    % 'bucknerlab'    : Decomposition of each condition and contrast into loadings on resting-state network maps
    % 'meta_analysis' : Tests of "pattern of interest" analyses and ROIs derived from CANlab meta-analyses
    
    switch analysis_str
        
        case 'contrasts'
            % ------------------------------------------------------------------------
            
            pubfilename = ['analysis_coverage_and_contrasts_' scn_get_datetime];
            
            p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 1600, ...
                'format', 'html', 'outputDir', fullfile(pubdir, pubfilename), 'showCode', false);
            
            publish('z_batch_coverage_and_contrasts.m', p)
            
            close all
            
        case 'svm'
            % ------------------------------------------------------------------------
            
            
            pubfilename = ['analysis_SVM_on_contrasts_' scn_get_datetime];
            
            p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 1600, ...
                'format', 'html', 'outputDir', fullfile(pubdir, pubfilename), 'showCode', false);
            
            publish('z_batch_svm_analysis.m', p)
            
            close all
            
            
        case 'signatures'
            % ------------------------------------------------------------------------
            
            
            pubfilename = ['analysis_signature_analyses_' scn_get_datetime];
            
            p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 1600, ...
                'format', 'html', 'outputDir', fullfile(pubdir, pubfilename), 'showCode', false);
            
            publish('z_batch_signature_analyses.m', p)
            
            close all
            
        case 'bucknerlab'
            % ------------------------------------------------------------------------
            
            pubfilename = ['analysis_bucknerlab_networks_' scn_get_datetime];
            
            p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 1600, ...
                'format', 'html', 'outputDir', fullfile(pubdir, pubfilename), 'showCode', false);
            
            publish('z_batch_bucknerlab_network_analyses.m', p)
            
            close all
            
        case 'meta_analysis'
            % ------------------------------------------------------------------------
            
            pubfilename = ['analysis_meta_analysis_masks_' scn_get_datetime];
            
            p = struct('useNewFigure', false, 'maxHeight', 800, 'maxWidth', 1600, ...
                'format', 'html', 'outputDir', fullfile(pubdir, pubfilename), 'showCode', false);
            
            publish('z_batch_meta_analysis_mask_analyses.m', p)
            
            close all
            
        otherwise
            
            printhdr(sprintf('UNRECOGNIZED COMMAND STRING: %s\nSkipping.\n', analysis_str));
            
    end % switch
    
end % loop

end % function

