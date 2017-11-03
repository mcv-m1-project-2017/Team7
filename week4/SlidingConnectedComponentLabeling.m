function [bboxes] = SlidingConnectedComponentLabeling(im_seg, show)

    %Compute ratios
    train_dataset = txt2cell('train_dataset.txt', 'columns', [3, 4, 7, 8]);
    w = cell2vec(train_dataset(:,1)); w = [min(w), max(w)];
    h = cell2vec(train_dataset(:,2)); h = [min(h), max(h)];
    
    fr = cell2vec(train_dataset(:,4)); 
    mean_fr = mean(fr); var_fr = std(fr);
    fr = [mean_fr-var_fr, mean_fr+var_fr];
    
    %window sizes
    N_windows = 2; % >1
    size_i = zeros(N_windows,1); size_j = size_i;
    pi = ceil((h(2)-h(1)-5)/(N_windows-1));
    pj = ceil((w(2)-w(1)-5)/(N_windows-1));
    for i = 1:N_windows
        size_i(i) = h(1)+((i-1)*pi);
        size_j(i) = w(1)+((i-1)*pj);  
    end
    
    %slide each window
    candidate_X = []; candidate_Y = [];
    for w = 1:N_windows
        [X, Y] = find_candidates(im_seg, size_i(w), size_j(w), fr, 0);
        candidate_X = [candidate_X; X];
        candidate_Y = [candidate_Y; Y];
    end
    
    %if show, show_candidates(im_seg, candidate_X, candidate_Y); end
    bboxes = merge_bboxes(candidate_X, candidate_Y, Inf, show, im_seg);
end

function [X, Y] = find_candidates(img, size_i, size_j, fr, th)

    [h, w] = size(img);
    X = []; Y= [];
    step = 10;
    
    %sliding process
    for i = 1:step:h-size_i
        for j = 1:10:w-size_j
            window = img(i:i+size_i, j:j+size_j);
            filling_ratio = sum(sum(window))/(size_i*size_j);
            if(filling_ratio >= fr(1)-th && filling_ratio <= fr(2)+th)
                X = [X;[i, i, i+size_i, i+size_i]];
                Y = [Y;[j, j+size_j, j, j+size_j]];  
            end
        end 
    end
end
