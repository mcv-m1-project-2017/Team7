function candidate_bboxes = chanfer_template_matching(im, mask, thresh, show, templates, method)

    show_corr = 0;
    step = 8; % There is a range of 208, so step should be a multple of 208.
    w = txt2cell('train_dataset.txt', 'columns', 3);
    h = txt2cell('train_dataset.txt', 'columns', 4);
    w = cellfun(@str2num, w); w = [min(w), max(w)];
    h = cellfun(@str2num, h); h = [min(h), max(h)];
    
    if strcmp(method, 'hsv')
        im_proc = rgb2hsv(im); im_proc = im_proc(:,:,2);
    elseif strcmp(method, 'grayscale')
        im_proc = rgb2gray(im);
    end
    
    im_proc = bwdist(edge(uint8(im_proc)*255,'canny'));
    
    if size(mask,1) ~= 1, im_proc = im_proc .* uint8(mask); end %avoid analyzing the whole image using color segmentation.
    whmin= min(w(1),h(1)); whmax = max(w(2),h(2));
    candidate_bboxes = [];
    %imshow(im_proc)

    for s=whmin:step:whmax
        for i=1:length(templates)     
            template = resize_template(templates{i}, s, s);
            c = normxcorr2(template, im_proc);
            if min(c(:)) < thresh
                if show_corr, figure; surf(c); shading flat; end
                [ypeak, xpeak] = find(c==min(c(:)));
                yoffSet = ypeak-size(template,1);
                if yoffSet < 0 
                    break 
                end
                xoffSet = xpeak-size(template,2);
                if xoffSet < 0
                    break
                end
                if xoffSet +1 + size(template,1)>size(im_proc,1)
                    h = size(im_proc,1)-xoffSet-2;
                    break
                else
                    h = size(template,1);
                end
                if yoffSet+1+size(template,2) > size(im_proc,2)
                    w = size(im_proc,2)-yoffSet-2;
                    break
                else
                    w = size(template,2);
                end
                bbox = [xoffSet+1, yoffSet+1, w, h];
                candidate_bboxes = [candidate_bboxes; bbox];
            end
        end
    end
    candidate_bboxes = merge_bboxes(Inf, Inf, candidate_bboxes, show, im);
    if show
        figure
        imshow(im_proc);
        hold on
        for k=1:size(candidate_bboxes,1)
            rectangle('Position', [candidate_bboxes(k,1), candidate_bboxes(k,2),...
                candidate_bboxes(k,3),candidate_bboxes(k,4)],'EdgeColor','g')
        end
    end
end
function score = slightly_score(input_img, template)
    %score = zeros([size(img,1)-size(template,1),size(img,2)-size(template,2)]);
    img = max(max(input_img))*ones(size(input_img,1)+size(template,1), ...
        size(input_img,2)+size(template,2));
    img(1:size(img,1)-size(template,1), 1:size(img,2)-size(template,2)) = input_img;
    score =  zeros(size(img));
    imshow(img)
    for i=1:size(img,1)-size(template,1)
        for j=1:size(img,2)-size(template,2)
            img_aux = img(i:i+size(template,1)-1, j:j+size(template,2)-1);
            score(i,j) = sum(sum(img_aux .* template));
        end
    end
    score = score(1:size(img,1)-size(template,1),1:size(img,2)-size(template,2)); 
end

function template = resize_template(template, x, y)
    SE=strel('square', 5 );
    template = imfill(template, 'holes');
    template = imresize(template, [x y]);
    z = zeros([x y]);
    z(2:size(template,1)-1,2:size(template,2)-1)=template(2:size(template,1)-1,2:size(template,2)-1);
    template=imclose(edge(z,'canny',0.8),SE); 
end
