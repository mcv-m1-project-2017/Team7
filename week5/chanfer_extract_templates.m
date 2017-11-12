function templates = chanfer_extract_templates(show)
    
    %dataset_path = '/home/mcv00/DataSet/train/';
    dataset_path = 'train/';
    annotation_path = strcat(dataset_path, 'gt/gt.');
    mask_path = strcat(dataset_path, 'mask/mask.');
    train_dataset = unique(txt2cell('train_dataset.txt', 'columns', 1));
    signal_count = [0 0 0 0 0 0]; %[typeA, typeB, ..., typeF]
    a = zeros(224, 224); b = zeros(224, 224);
    c = zeros(224, 224); d = zeros(224, 224);
    e = zeros(224, 224); f = zeros(224, 224);
    
    %Iterate over the train dataset
    for i=1:length(train_dataset)
    %for i =1:1
        img_an = strcat(annotation_path, train_dataset(i), '.txt');
        bboxes = txt2cell(img_an{1}, 'columns', 1:4);
        bboxes = cellfun(@(x) floor(str2num(x)), bboxes);
        types = txt2cell(img_an{1}, 'columns', 5);
        num_signals = size(bboxes,1);
        img = imread(strcat(dataset_path, train_dataset{i}, '.jpg'));
        mask = imread(strcat(mask_path, train_dataset{i}, '.png'));
        
        for k=1:num_signals
            clear signal
            
            img_subset = img(bboxes(k,1):bboxes(k,3), bboxes(k,2)+1:bboxes(k,4));
            mask_subset = mask(bboxes(k,1):bboxes(k,3), bboxes(k,2)+1:bboxes(k,4));
            signal = img_subset .* mask_subset;
            %signal = rgb2gray(signal);           
            signal=edge(signal,'canny');
            
            if strcmp(types(k), 'A')
                signal = imresize(signal, [224 224]);
                a = a + signal;
                signal_count(1) = signal_count(1) + 1;
            elseif strcmp(types(k), 'B')
                signal = imresize(signal, [224 224]);
                b = b + signal;
                signal_count(2) = signal_count(2) + 1;
            elseif strcmp(types(k), 'C')
                signal = imresize(signal, [224 224]);
                c = c + signal;
                signal_count(3) = signal_count(3) + 1;
            elseif strcmp(types(k), 'D')
                signal = imresize(signal, [224 224]);
                d = d + signal;
                signal_count(4) = signal_count(4) + 1;
            elseif strcmp(types(k), 'E')
                signal = imresize(signal, [224 224]);
                e = e + signal;
                signal_count(5) = signal_count(5) + 1;
            elseif strcmp(types(k), 'F')
                signal = imresize(signal, [224 224]);
                f = f + signal;
                signal_count(6) = signal_count(6) + 1;
            end
            
        end
    end
    mean_a = detect_edges(a / signal_count(1));  
    mean_b = detect_edges(b / signal_count(2));
    mean_c = detect_edges(c / signal_count(3));
    mean_d = detect_edges(d / signal_count(4));
    mean_e = detect_edges(e / signal_count(5));
    mean_f = detect_edges(f / signal_count(6));
    
    if show
        figure; imshow(mean_a); figure; imshow(mean_b);
        figure; imshow(mean_c); figure; imshow(mean_d);
        figure; imshow(mean_e); figure; imshow(mean_f);
    end
    templates = {mean_a, mean_b, mean_c, mean_d, mean_e, mean_f};
end

function img = detect_edges(img)
    SE=strel('square', 6 );
    img(img~=0)=1;
    img = imfill(img, 'holes');
    img = imclose(edge(img,'canny',0.8),SE);
end
