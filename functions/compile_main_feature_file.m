function compile_main_feature_file(save_features_pathname, feature_file_key, save_filename, options)
% Function to to collate and compile our final feature matrix from all
% individual feature files exacted over all inertial sensor files available
%--------------------------------------------------------------------------
% Input:
%     save_features_pathname: a character array denoting the pathname where
%     the feature data is stored
% 
%     feature_file_key: a character array denoting the identifying filename
%     prefixs indictaing the files are relevant featreue files. See 'dir.m'
%     using a '*' wildcard input filename: a char array denoting the
%     filename where the data is stored
% 
%     save_filename: a char array indicating the final output filename of
%     the feature matrix
% _________________________________________________________________________
%    options: structure containing optional inputs to be used in each
%    feature extraction function. Currently there are no options associated
%    with this file. 
%--------------------------------------------------------------------------
% Reference:
% [1]  A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%      Characterisation of Ambulation in Multiple Sclerosis during the
%      Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%      Informatics, doi: 10.1109/JBHI.2020.2998187.
%
%% Andrew Creagh. Last modified on June 2020 

%% MAIN
    
    %Gather the feature filenames to be grouped into a feature matrix. 
    files=dir([save_features_pathname, filesep, '*', feature_file_key, '*']);
    full_filenames(:,1)=fullfile({files.folder}, filesep, {files.name});
    filename(:,1)={files.name};

    %create new savename (including the path) for the feature matrix
    full_save_filename=[save_features_pathname, filesep,save_filename, '.txt'];

    %loop through the number of feature files
    num_files=length(full_filenames);  
    for fileno=1:num_files

        %I find readtable quite good. 
        %*Note: readtale will truncate precision of some long floats, be
        %aware of this functionality and if it affects your own
        %applications switch to another method to load the feature data in.
        %Suggestion - 'dlmread.m'
        FEATURE_DATA=readtable(fullfile(save_features_pathname, filesep, filename{fileno}));

        if fileno==1 %write the initial file with headers
              
        variables=FEATURE_DATA.Properties.VariableNames;
        FEATURE_DATA=table2array(FEATURE_DATA);
        fileID = fopen(full_save_filename,'w');
        formatSpec=['%s,',repmat('%s,', 1, length(variables)-1), '%s\n'];

        headers= [{'filename'}, variables];
        %write feature file with headers
        fprintf(fileID,formatSpec,headers{:});
        %write feature values
        formatSpec=['%s,', repmat('%12.8f,', 1, length(variables)-1), '%12.8f\n'];
        fprintf(fileID,formatSpec,filename{fileno}, FEATURE_DATA(:));
        fclose(fileID);

        else %append the file
        
        FEATURE_DATA=table2array(FEATURE_DATA);
        fileID = fopen(full_save_filename,'a');
        %write feature values
        formatSpec=['%s,', repmat('%12.8f,', 1, length(variables)-1), '%12.8f\n'];
        fprintf(fileID,formatSpec,filename{fileno}, FEATURE_DATA(:));
        fclose(fileID);

        end
        
        %re-initailise FEATURE_DATA, clear the values but keep the variable
        %in memory
        FEATURE_DATA=[];
        
    end
    fprintf('Final feature matrix compiled: %s.txt\n',  save_filename)
end 

%EOF