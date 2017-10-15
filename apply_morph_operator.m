function [im_seg] = apply_morph_operator(im_seg, method)
switch(method)
    case 1
%Obtain min and max signal sizes:
    sizes = txt2cell('/home/mcv07/Team7/dataset_analysis.txt', 'columns', [1 2 3]);
    max_size = max(cell2mat(cellfun(@str2num,sizes(:, 2),'un',0)));
    min_size = min(cell2mat(cellfun(@str2num,sizes(:,1),'un',0)));
    max_form_factor = max(cell2mat(cellfun(@str2num,sizes(:, 3),'un',0)));
    % Morphological operators to remove noise
    SE_close=strel('rectangle',[7,3]);
    SE2=strel('square', 5 );        
    im_seg= imclose(im_seg, SE_close);
%     figure;
%     imshow(im_seg*255)
    im_seg = imfill(im_seg, 'holes');
%     figure;
%     imshow(im_seg*255)
    im_seg=imopen(im_seg,SE2);
%     figure;
%     imshow(im_seg*255)
    im_seg = xor(bwareaopen(im_seg,min_size),  bwareaopen(im_seg,max_size)); %Remove connected areas above and behind max and min sizes
%     figure;
%     imshow(im_seg*255)
%     ul_corner = regionprops(im_seg, 'BoundingBox');
    otherwise
        disp('Error, not a valid method')
end
end
