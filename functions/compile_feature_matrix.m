function compile_feature_matrix(save_features_pathname, feature_file_key, save_filename, options)

    files=dir([save_features_pathname, filesep, '*', feature_file_key, '*']);
    full_filenames(:,1)=fullfile({files.folder}, filesep, {files.name});
    save_filename=[save_features_pathname, filesep,save_filename, '.txt'];

    num_files=length(full_filenames);

    for fileno=1:num_files

        FEATURE_DATA=readtable(full_filenames{fileno});
        FEATURE_DATA=table2array(FEATURE_DATA);

        if fileno==1 %write the initial file
              
              % save feature labels
              % say use DLM write for ease but in R2020a can use writetable which gives nice compatability
 
              dlmwrite(save_filename,FEATURE_DATA)
%             writetable(FEATURE_DATA, save_filename, 'WriteRowNames',false)


        else %append the file
                dlmwrite(save_filename,FEATURE_DATA,'-append')
%             writetable(FEATURE_DATA, save_filename,'WriteMode','append',...
%                 'WriteVariableNames',false, 'WriteRowNames',false)
        end
        FEATURE_DATA=[];
        
    end

end 