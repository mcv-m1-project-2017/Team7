function [cands, scores_list] = chanfer_compare_windows(im, windowCandidates, thresh, templates)
    %Function that compared window candidates with different templates and
    %returns the correlation between them.

    num_win = length(windowCandidates);
    scores_list = zeros(num_win, 6);
    cands = [];
   for i=1:num_win
       xmax = windowCandidates(i).x + windowCandidates(i).w - 1;
       ymax = windowCandidates(i).y + windowCandidates(i).h - 1;
       im_bounded = im(windowCandidates(i).y:ymax, windowCandidates(i).x:xmax);
       im_proc = bwdist(edge(im_bounded,'canny'));
       for k=1:length(templates)
          if ~isempty(im_bounded)
            template = resize_template(templates{k}, size(im_bounded,1), size(im_bounded,2));
            figure; imshow(template);
            scores = slightly_score(im_proc, template);
            scores_list(i,k) = min(scores(:));
          end
       end
       if min(scores_list(i,:)) < thresh
           cands = [cands; windowCandidates(i)];
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
    SE=strel('square', 6 );
    template = imfill(imclose(template,SE),'holes');
    template = imresize(template, [x y]);
    z = zeros([x y]);
    z(2:size(template,1)-1,2:size(template,2)-1)=template(2:size(template,1)-1,2:size(template,2)-1);
    template=imclose(edge(z,'canny',0.8),SE); 
end
