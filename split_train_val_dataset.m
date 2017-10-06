%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% TRAIN DATASET SPLITTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function split_train_val_dataset(directory)
%Function that splits train dataset in train and validation subsets by saving
%images id in a text file. Approximately the train dataset is the 70% of
%the original dataset, while the validation is a 30%. Varargin "directory"
%refers to the path where your dataset is allocated.
    files = ListFiles(directory);
    signals_found = [];
    images_id = [];
    % Save in an array the total number of traffic signals that appear and 
    % associate them to an image:
    for i=1:size(files,1)
        [signs, img_id] = extract_signal_type(directory, files, i);
        signals_found = [signals_found, signs];
        for j=1:length(signs)
            images_id = [images_id, img_id];
        end
    end
    images_id = mat2cell(images_id, 1, 9*ones(1,numel(signals_found)));
    sign_types = ['A', 'B', 'C', 'D', 'E', 'F'];
    signs_appearance = zeros(6,1);
    distributions_per_split = zeros(6,2);
    %Compute how many signals should be in each split
    for i=1:6
        signs_appearance(i) = sum(strcmp(signals_found, sign_types(i)));
        distributions_per_split(i,1) = round(signs_appearance(i) * 0.7);
        distributions_per_split(i,2) = round(signs_appearance(i) * 0.3);
    end
    %Check if round operator suits for our problem
    if sum(distributions_per_split(:)) ~= sum(signs_appearance)
        display('Error')
        return
    end
    train_indexs = [];
    val_indexs = [];
    % Assign a 70% of each type of signal to the train dataset and a 30% to
    % the validation dataset.
    for i=1:6
        index = find(strcmp(signals_found, sign_types(i)));
        index = index(randperm(length(index)));
        train_indexs = [train_indexs, index(1:distributions_per_split(i,1))];
        val_indexs = [val_indexs, index(distributions_per_split(i,1)+1:end)];
    end
    train_dataset=[];
    val_dataset = [];
    for i=1:length(train_indexs)
        train_dataset = [train_dataset, images_id(train_indexs(i))]
        train_dataset = unique(train_dataset) %erase repeated elements
    end
    for i=1:length(val_indexs)
        if sum(strcmp(train_dataset,images_id(val_indexs(i)))) < 1 %check there are not repeated elements
            val_dataset = [val_dataset, images_id(val_indexs(i))]
        end
    end
    %Save image_ids associated to train and val datasets in different text
    %files:
    train_file = fopen('train_dataset.txt', 'w');
    fprintf(train_file, '%s\n', train_dataset{:});
    fclose(train_file);
    val_file = fopen('val_dataset.txt', 'w');
    fprintf(val_file, '%s\n', val_dataset{:});
    fclose(val_file)
end

function [signal_types, image_id] = extract_signal_type(directory, files, i)
% Function that extracts the type of the signal (A, B, C, D, E or F) and
% the id associated to the image.
    image_id = files(i).name(1:size(files(i).name,2)-4);
    name = strcat(directory, '/gt/gt.', image_id, '.txt');
    file = fopen(name);
    signal_types = [];
    while(1)
        row = fgetl(file);
        if(row == -1)
            break
        else
            gt = strsplit(row);
            signal_types = [signal_types, gt(5)];
        end
        
    end

end
