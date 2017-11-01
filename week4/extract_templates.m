function templates = extract_templates(template_type, debug, show)
% Function that extracts a template for each signal type by computing the
% mean of each type over the train dataset. It returns a binary template
% and a color based template depending on argin "template type":
% 'bwtemplate' for black&white, and 'color' for the color based.

    dataset_path = '/home/mcv00/DataSet/train/';
    annotation_path = strcat(dataset_path, 'gt/gt.');
    mask_path = strcat(dataset_path, 'mask/mask.');
    train_dataset = unique(txt2cell('train_dataset.txt', 'columns', 1));
    signal_count = [0 0 0 0 0 0]; %[typeA, typeB, ..., typeF]
    a = zeros(224, 224, 3); b = zeros(224, 224, 3);
    c = zeros(224, 224, 3); d = zeros(224, 224, 3);
    e = zeros(224, 224, 3); f = zeros(224, 224, 3);
    
    %Iterate over the train dataset
    for i=1:length(train_dataset)
        img_an = strcat(annotation_path, train_dataset(i), '.txt');
        bboxes = txt2cell(img_an{1}, 'columns', 1:4);
        bboxes = cellfun(@(x) floor(str2num(x)), bboxes);
        types = txt2cell(img_an{1}, 'columns', 5);
        num_signals = size(bboxes,1);
        img = imread(strcat(dataset_path, train_dataset{i}, '.jpg'));
        mask = imread(strcat(mask_path, train_dataset{i}, '.png'));
        for k=1:num_signals
            clear signal
            
            img_subset = img(bboxes(k,1):bboxes(k,3), bboxes(k,2)+1:bboxes(k,4),:);
            mask_subset = mask(bboxes(k,1):bboxes(k,3), bboxes(k,2)+1:bboxes(k,4));
            signal(:,:,1) = img_subset(:,:,1) .* mask_subset;
            signal(:,:,2) = img_subset(:,:,2) .* mask_subset;
            signal(:,:,3) = img_subset(:,:,3) .* mask_subset;
            if debug, figure; imshow(signal); figure; imshow(img_subset); end
            signal = double(signal);
            if strcmp(types(k), 'A')
                signal = imresize(signal, [224 224]);
                if debug, figure; imshow(signal); end
                a = a + signal;
                signal_count(1) = signal_count(1) + 1;
            elseif strcmp(types(k), 'B')
                signal = imresize(signal, [224 224]);
                if debug, figure; imshow(signal); end
                b = b + signal;
                signal_count(2) = signal_count(2) + 1;
            elseif strcmp(types(k), 'C')
                signal = imresize(signal, [224 224]);
                if debug, figure; imshow(signal); end
                c = c + signal;
                signal_count(3) = signal_count(3) + 1;
            elseif strcmp(types(k), 'D')
                signal = imresize(signal, [224 224]);
                if debug, figure; imshow(signal); end
                d = d + signal;
                signal_count(4) = signal_count(4) + 1;
            elseif strcmp(types(k), 'E')
                signal = imresize(signal, [224 224]);
                if debug, figure; imshow(signal); end
                e = e + signal;
                signal_count(5) = signal_count(5) + 1;
            elseif strcmp(types(k), 'F')
                signal = imresize(signal, [224 224]);
                if debug, figure; imshow(signal); end
                f = f + signal;
                signal_count(6) = signal_count(6) + 1;
            end
            
        end
    end
    
    mean_a = a / signal_count(1);  mean_b = b / signal_count(2);
    mean_c = c / signal_count(3);  mean_d = d / signal_count(4);
    mean_e = e / signal_count(5);  mean_f = f / signal_count(6);
    
    if strcmp(template_type, 'bw')
        if show
            figure; imshow(mean_a); figure; imshow(mean_b);
            figure; imshow(mean_c); figure; imshow(mean_d);
            figure; imshow(mean_e); figure; imshow(mean_f);
        end
        templates = {mean_a, mean_b, mean_c, mean_d, mean_e, mean_f};
    else
        a = uint8(mean_a); b = uint8(mean_b);
        c = uint8(mean_c); d = uint8(mean_d);
        e = uint8(mean_e); f = uint8(mean_f);
        
        
        if strcmp(template_type, 'grayscale') 
            a = rgb2gray(a); b = rgb2gray(b);
            c = rgb2gray(c); d = rgb2gray(d);
            e = rgb2gray(e); f = rgb2gray(f);           
        end
        if show
            figure; imshow(a); figure; imshow(b);
            figure; imshow(c); figure; imshow(d);
            figure; imshow(e); figure; imshow(f);
        end
        templates = {a, b, c, d, e, f};
    end 
end

