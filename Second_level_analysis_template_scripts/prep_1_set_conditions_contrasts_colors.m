%% Set up conditions 
% ------------------------------------------------------------------------

% conditions = {'C1' 'C2' 'C3' 'etc'};
% structural_wildcard = {'c1*nii' 'c2*nii' 'c3*nii' 'etc*nii'};
% functional_wildcard = {'fc1*nii' 'fc2*nii' 'fc3*nii' 'etc*nii'};
% colors = {'color1' 'color2' 'color3' etc}  One per condition

fprintf('Image data should be in /data folder\n');

DAT = struct();

% Names of subfolders in /data
DAT.subfolders = {'S*' 'S*' 'S*' 'S*'};

% Names of conditions
DAT.conditions = {'itch_img_control' 'itch_imagery' 'pain_img_control' 'pain_imagery'};

DAT.conditions = format_strings_for_legend(DAT.conditions);

DAT.structural_wildcard = {};
DAT.functional_wildcard = {'con_0001.img' 'con_0002.img' 'con_0003.img' 'con_0004.img'};

% Set Contrasts
% ------------------------------------------------------------------------

% Vectors across conditions
DAT.contrasts = [-1 1 0 0; 0 0 -1 1; 0 -1 0 1];
    
DAT.contrastnames = {'Itch_imagery_v_control' 'Pain_imagery_v_control' 'Pain_v_itch_imagery'};

DAT.contrastnames = format_strings_for_legend(DAT.contrastnames);


% Set Colors
% ------------------------------------------------------------------------

% Default colors: Use Matlab's default colormap
% Other options: custom_colors, seaborn_colors, bucknerlab_colors

DAT.colors = custom_colors([.8 .7 .2], [.5 .2 .8], length(DAT.conditions));

DAT.contrastcolors = custom_colors ([.2 .2 .8], [.2 .8 .2], length (DAT.contrasts));

% colors = colormap; % default list of n x 3 color vector
% colors = mat2cell(colors, ones(size(colors, 1), 1), 3)';
% DAT.colors = colors;
% clear colors
%close

disp('SET up conditions, colors, contrasts in DAT structure.');



