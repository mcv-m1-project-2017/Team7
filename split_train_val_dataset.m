%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% TRAIN DATASET SPLITTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function split_train_val_dataset(features_file)
%Function that splits train dataset in train and validation subsets by saving
%images id in a text file. Approximately the train dataset is the 70% of
%the original dataset, while the validation is a 30%. Varargin "directory"
%refers to the path where your dataset is allocated.
    sign_types = ['A', 'B', 'C', 'D', 'E', 'F'];
    % Save in an array the total number of traffic signals that appear and 
    % associate them to an image:
    data = txt2cell(features_file, 'columns', [1 13])';
    images_id = data(1,:);    
    signals_found = data(2, :);
    clear data
    
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
        train_dataset = [train_dataset, images_id(train_indexs(i))];
        train_dataset = unique(train_dataset); %erase repeated elements
    end
    for i=1:length(val_indexs)
        if sum(strcmp(train_dataset,images_id(val_indexs(i)))) < 1 %check there are not repeated elements
            val_dataset = [val_dataset, images_id(val_indexs(i))];
        end
    end
    val_dataset = unique(val_dataset);
    
    %Check how many images with multiple signals are in train and val
    %datasets and balance them:
    two_signals_train = 0;
    three_signals_train = 0;
    two_signals_val = 0;
    three_signals_val = 0;
    [images_2signals, images_3signals] = obtain_images_multiple_signals('/home/mcv07/Team7/train_features.txt');
    train_2signals_idx = [];
    train_3signals_idx = [];
    val_2signals_idx = [];
    val_3signals_idx = [];
    for k=1:length(train_dataset)
        contains_two = sum(strcmp(train_dataset(k),images_2signals));
        contains_three = sum(strcmp(train_dataset(k),images_3signals));
        two_signals_train = two_signals_train + contains_two;  
        three_signals_train =  three_signals_train + contains_three;
        if contains_two
            train_2signals_idx = [train_2signals_idx, k];
        elseif contains_three
            train_3signals_idx = [train_3signals_idx, k];
        end
    end
    for k=1:length(val_dataset)
        contains_two = sum(strcmp(val_dataset(k),images_2signals));
        contains_three = sum(strcmp(val_dataset(k),images_3signals));
        two_signals_val = two_signals_val + contains_two;  
        three_signals_val =  three_signals_val + contains_three;
        if contains_two
            val_2signals_idx = [val_2signals_idx, k];
        elseif contains_three
            val_3signals_idx = [val_3signals_idx, k];
        end  
    end
    target_train = round((two_signals_train+two_signals_val)*0.7);
    if  target_train < two_signals_train
        new_val_img_idx = train_2signals_idx(1:two_signals_train - target_train);
        val_dataset = [val_dataset, train_dataset(new_val_img_idx)];
        train_dataset(new_val_img_idx) = [];
    elseif target_train > two_signals_train
        new_train_img_idx = val_2signals_idx(1:target_train - two_signals_train);
        train_dataset = [train_dataset, val_dataset(new_train_img_idx)];
        val_dataset(new_train_img_idx) = [];  
    end
    target_train = round((three_signals_train+three_signals_val)*0.7);
    if  target_train < three_signals_train
        new_val_img_idx = train_3signals_idx(1:three_signals_train - target_train);
        val_dataset = [val_dataset, train_dataset(new_val_img_idx)];
        train_dataset(new_val_img_idx) = [];
    elseif target_train > three_signals_train
        new_train_img_idx = val_3signals_idx(1:target_train - three_signals_train);
        train_dataset = [train_dataset, val_dataset(new_train_img_idx)];
        val_dataset(new_train_img_idx) = [];  
    end
    clear train_indexs val_indexs images_2signals images_3signals
    
    %Add features extracted in train and val dataset files
    features = txt2cell('./image_features.txt');
    t_txt=fopen('train_dataset.txt','w');
    v_txt=fopen('val_dataset.txt','w');
    t=1; v=1;
    for i=1:size(features,1)
        if sum(strcmp(train_dataset, features{i,1}))
            new_train_dataset(t,:) = features(i,:);
            t=t+1;
            fprintf(t_txt,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',features{i,:});
        elseif sum(strcmp(val_dataset,features{i,1}))
            new_val_dataset(v,:) = features(i,:);
            v=v+1;
            fprintf(v_txt,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',features{i,:});
        end
    end
    fclose(t_txt);
    fclose(v_txt);
end

function [images2, images_3] = obtain_images_multiple_signals(features)
    file = fopen(features);
    images = [];
    while(1)
        row = fgetl(file);
        if(row == -1)
            break
        else
            feats = strsplit(row);
            if str2num(cell2mat(feats(2))) >=2
                images = [images, feats(1)];
            end
        end
        
    end
    fclose(file);
    [images_3] = get_duplicates(images);
    unique_img = unique(images);
    images2 = [];
    for i=1:length(unique_img)
       if sum(strcmp(unique_img(i), images_3)) == 0
           images2 = [images2, unique_img(i)];
       end
    end
    
end

function [dup_names] = get_duplicates(cell_array) 
% Function that finds duplicate entries in the cell array of images id
    [unique_cell,~,unique_cell_ndx] = unique(cell_array);
    N = histc(unique_cell_ndx,1:numel(unique_cell));
    dup_names = unique_cell(N>1);
end
%TODO: Finish check by size!!!
function [new_train, new_val] = check_by_size(train_dataset, val_dataset, features)
    features_analysis = {[]};
    signal_types = ['A', 'B', 'C', 'D','E', 'F'];
    counter_big = zeros(1,6);
    counter_small = zeros(1,6);
    for i=1:6
        idx = find(strcmp(signal_types(i), features(:,13)));
        mean_area = mean(features(idx, 6));
        std_area = std(features(idx, 6));
        for k=1:length(idx);
            features_analysis.image_id = features(idx(k), 1);
            features_analysis.signal_type = signal_types(i);
            if features(idx(k), 6) < mean_area - std_area
               features_analysis.size = 'big';
               counter_big(i) = counter_big(i) + 1;
            elseif features(idx(k), 6) > mean_area + std_area
               features_analysis.size = 'small';
               counter_small(i) = counter_small(i) + 1;
            end
        end
        
    end
end
