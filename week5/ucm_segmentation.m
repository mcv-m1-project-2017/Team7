function im_seg = ucm_segmentation(image, threshold_ucm, segmentation_values, stdr)
    addpath('segment-ucm');
    segments = segment_ucm(image, threshold_ucm);
    labels = unique(segments);
    im_HSV = rgb2hsv(image);
    h = im_HSV(:,:,1); s = im_HSV(:,:,2);
    clear im_HSV
    im_seg = zeros(size(image,1), size(image,2));
    clear image
    for i=1:length(labels)
       cand_seg = labels(i) == segments;
       b_pixel_H_mean=segmentation_values(21);
       b_pixel_H_std=segmentation_values(22)*stdr;
       r_pixel_H_mean=segmentation_values(27);
       r_pixel_H_std=segmentation_values(28)*stdr;            
       b_pixel_S_mean=segmentation_values(33);
       b_pixel_S_std=segmentation_values(34)*stdr;
       r_pixel_S_mean=segmentation_values(35);
       r_pixel_S_std=segmentation_values(36)*stdr;
            
       candidate = ((h(cand_seg)>(b_pixel_H_mean-b_pixel_H_std)) & (h(cand_seg)<(b_pixel_H_mean+b_pixel_H_std))...
           & (s(cand_seg)>(b_pixel_S_mean-b_pixel_S_std)) & (s(cand_seg)<(b_pixel_S_mean+b_pixel_S_std)))...
           | ((((h(cand_seg)>(r_pixel_H_mean-r_pixel_H_std)) & (h(cand_seg)<1)) | (h(cand_seg)<(r_pixel_H_mean+r_pixel_H_std-1)))...
           &(s(cand_seg)>(r_pixel_S_mean-r_pixel_S_std)) & (s(cand_seg)<(r_pixel_S_mean+r_pixel_S_std)));
       
        if nnz(candidate) / numel(candidate) > 0.8
            im_seg(cand_seg) = 255;
        end
       
    end
    %Erase bigger and smaller areas than max and min signal size:
    sizes = txt2cell('dataset_analysis.txt', 'columns', [1 2]);
    max_size = max(cell2mat(cellfun(@str2num,sizes(:, 2),'un',0)));
    min_size = min(cell2mat(cellfun(@str2num,sizes(:,1),'un',0)));
    im_seg = xor(bwareaopen(im_seg,min_size), bwareaopen(im_seg,max_size));
    
end
