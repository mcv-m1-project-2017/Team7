function candidate_bboxes = corr_template_matching(im, mask, thresh, show, templates)
    if nargin < 5
        temp_A = imread('template_A.png'); temp_B = imread('template_B.png');
        temp_C = imread('template_C.png'); temp_D = imread('template_D.png');
        temp_E = imread('template_E.png'); temp_F = imread('template_F.png');
        templates = {temp_A, temp_B, temp_C, temp_D, temp_E, temp_F};
    end
    show_corr = 0;
    step = 8; % There is a range of 208, so step should be a multple of 208.
    w = txt2cell('train_dataset.txt', 'columns', 3);
    h = txt2cell('train_dataset.txt', 'columns', 4);
    w = cellfun(@str2num, w); w = [min(w), max(w)];
    h = cellfun(@str2num, h); h = [min(h), max(h)];
    im_gray = rgb2gray(im);
    if size(mask,1) ~= 1, im_gray = im_gray .* uint8(mask); end %avoid analyzing the whole image using color segmentation.
    whmin= min(w(1),h(1)); whmax = max(w(2),h(2));
    candidate_bboxes = [];
    for s=whmin:step:whmax
        for i=1:length(templates)      
            template = imresize(templates{i}, [s s]);
            c = normxcorr2(template, im_gray);
            if max(c(:)) > thresh
                if show_corr, figure; surf(c); shading flat; end
                [ypeak, xpeak] = find(c==max(c(:)));
                yoffSet = ypeak-size(template,1);
                if yoffSet < 0, yoffSet = 0; end
                xoffSet = xpeak-size(template,2);
                if xoffSet < 0, xoffSet = 0; end
                bbox = [xoffSet+1, yoffSet+1, size(template,2), size(template,1)];
                candidate_bboxes = [candidate_bboxes; bbox];
            end
        end
    end
    candidate_bboxes = merge_bboxes(Inf, Inf, candidate_bboxes, show, im);
    if show
        figure
        imshow(im_gray);
        hold on
        for k=1:size(candidate_bboxes,1)
            rectangle('Position', [candidate_bboxes(k,1), candidate_bboxes(k,2),...
                candidate_bboxes(k,3),candidate_bboxes(k,4)],'EdgeColor','g')
        end
    end
end