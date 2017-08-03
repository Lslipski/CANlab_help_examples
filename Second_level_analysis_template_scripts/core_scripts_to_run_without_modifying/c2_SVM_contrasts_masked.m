
%% Load stats
savefilenamedata = fullfile(resultsdir, 'svm_stats_results_contrasts_masked.mat');

if ~exist(savefilenamedata, 'file')
    disp('Run prep_3c_run_SVMs_on_contrasts_masked with dosavesvmstats = true option to get SVM results.'); 
    disp('No saved results file.  Skipping this analysis.')
    return
end

fprintf('\nLoading SVM results and maps from %s\n\n', savefilenamedata);
load(savefilenamedata, 'svm_stats_results');

%% Initialize fmridisplay slice display if needed, or clear existing display
% --------------------------------------------------------------------

% Specify which montage to add title to. This is fixed for a given slice display
whmontage = 5; 
plugin_check_or_create_slice_display; % script, checks for o2 and uses whmontage

% --------------------------------------------------------------------

printhdr('Cross-validated SVM to discriminate within-person contrasts');

%% Average images collected on the same person within each SVM class, for testing
% --------------------------------------------------------------------

[dist_from_hyperplane, Y, svm_dist_pos_neg, svm_dist_pos_neg_matrix, outcome_matrix] = plugin_svm_contrasts_get_results_per_subject(DAT, svm_stats_results, DATA_OBJ);

%% Check that we have paired images and skip if not. See below for details
% --------------------------------------------------------------------

kc = size(DAT.contrasts, 1);

ispaired = false(1, kc);

for i = 1:kc
    ispaired(i) = sum(Y{i} > 0) == sum(Y{i} < 0);
end

if ~all(ispaired)
    disp('This script should only be run on paired, within-person contrasts');
    disp('Check images and results. Skipping this analysis.');
    return
end


%% Define effect size functions and between/within ROC type
% --------------------------------------------------------------------
% Define paired and uppaired functions here for reference
% This script uses the paired option because it runs within-person
% contrasts

% ROC plot is different for paired samples and unpaired. Paired samples
% must be in specific order, 1:n for condition 1 and 1:n for condition 2.
% If samples are paired, this is set up by default in these scripts.
% But some contrasts entered by the user may be unbalanced, i.e., different
% numbers of images in each condition, unpaired. Other SVM scripts are set up
% to handle this condition explicitly and run the unpaired version.  

% Effect size, cross-validated, paired samples
dfun_paired = @(x, Y) mean(x(Y > 0) - x(Y < 0)) ./ std(x(Y > 0) - x(Y < 0));

% Effect size, cross-validated, unpaired sampled
dfun_unpaired = @(x, Y) (mean(x(Y > 0)) - mean(x(Y < 0))) ./ sqrt(var(x(Y > 0)) + var(x(Y < 0))); % check this.

rocpairstring = 'twochoice';  % 'twochoice' or 'unpaired'


%% Cross-validated accuracy and ROC plots for each contrast
% --------------------------------------------------------------------

for c = 1:kc
    
    printstr(DAT.contrastnames{c});
    printstr(dashes)
    
    % ROC plot
    % --------------------------------------------------------------------
    
    figtitle = sprintf('SVM ROC masked %s', DAT.contrastnames{c});
    create_figure(figtitle);
    
    ROC = roc_plot(dist_from_hyperplane{c}, logical(Y{c} > 0), 'color', DAT.contrastcolors{c}, rocpairstring);
    
    d_paired = dfun_paired(dist_from_hyperplane{c}, Y{c});
    fprintf('Effect size, cross-val: Forced choice: d = %3.2f\n\n', d_paired);
    
    plugin_save_figure
    

    % Plot the SVM map
    % --------------------------------------------------------------------
    % Get the stats results for this contrast, with weight map
    stats = svm_stats_results{c};
    
    o2 = removeblobs(o2);
    o2 = addblobs(o2, region(stats.weight_obj), 'trans');
        
    axes(o2.montage{whmontage}.axis_handles(5));
    title(DAT.contrastnames{c}, 'FontSize', 18)
    
    printstr(DAT.contrastnames{c}); printstr(dashes);
    
    figtitle = sprintf('SVM weight map nothresh masked %s', DAT.contrastnames{c});
    plugin_save_figure;
    
    % Remove title in case fig is re-printed in html
    axes(o2.montage{whmontage}.axis_handles(5));
    title(' ', 'FontSize', 18)
    
    o2 = removeblobs(o2);
    
    axes(o2.montage{whmontage}.axis_handles(5));
    title('Intentionally Blank', 'FontSize', 18); % For published reports
    
end  % within-person contrast

%% Cross-classification matrix
% uses svm_dist_pos_neg_matrix, outcome_matrix from plugin

diff_function = @(x) x(:, 1) - x(:, 2);         % should be positive for correct classification

iscorrect = @(x) sign(diff_function(x)) > 0;

acc_function = @(corr_idx) 100 * sum(corr_idx) ./ length(corr_idx);

svm_dist_per_subject_and_condition = cellfun(diff_function, svm_dist_pos_neg_matrix, 'UniformOutput', false);

accuracy_by_subject_and_condition = cellfun(iscorrect, svm_dist_pos_neg_matrix, 'UniformOutput', false);

accuracy = cellfun(acc_function, accuracy_by_subject_and_condition, 'UniformOutput', false);
accuracy = cell2mat(accuracy);

% Figure
% -------------------------------------------------------------------------
figtitle = sprintf('SVM Cross_classification masked');
create_figure(figtitle);

pos = get(gcf, 'Position');
pos(3) = pos(3) * 1.7;
set(gcf, 'Position', pos)

printhdr('Cross-validated distance from hyperplane. > 0 is correct classification');

ntransfer = size(svm_dist_per_subject_and_condition, 2);
text_xval = [];
han = {};

for c = 1:kc
   
    dat = svm_dist_per_subject_and_condition(c, :);
    
    xvals = 1 + ntransfer * (c-1) : c * ntransfer;
    
    xvals = xvals + c - 1; % skip a space

    text_xval(c) = mean(xvals);
    mycolors = DAT.contrastcolors;
    
    trainname = DAT.contrastnames{c};
    xtick_text{c} = sprintf('Train %s', trainname);

    mynames = DAT.contrastnames;  % for barplot_columns output
    
    printhdr(sprintf('Train on %s', trainname));
    
    han{c} = barplot_columns(dat, 'nofig', 'noviolin', 'colors', mycolors, 'x', xvals, 'names', mynames);
    set(gca, 'XLim', [.5 xvals(end) + .5]);
    
end

xlabel(' ');
ylabel('Distance from hyperplane');

barhandles = cat(2, han{1}.bar_han{:});
legend(barhandles, DAT.contrastnames)

set(gca, 'XTick', text_xval, 'XTickLabel', xtick_text, 'XTickLabelRotation', 0);

printhdr('Accuracy matrix - training (rows) by test contrasts (columns)');
print_matrix(accuracy, DAT.contrastnames, DAT.contrastnames);

plugin_save_figure;
