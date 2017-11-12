function [output_mask] = chamfer_template_matching(input_mask, templatess, threshold)
    
    norm_coef = [0.8, 0.8, 1.4, 1, 1, 1];
    CC = regionprops(logical(input_mask),'BoundingBox');
    template_size = size(templates{1});
    
    output_mask = zeros(size(input_mask));
    
    for i = 1:size(CC,1)
        v = zeros(size(templates)); 
        bbox = CC(i).BoundingBox;
        candidate = input_mask(ceil(bbox(2)):floor(bbox(2)+bbox(4)),ceil(bbox(1)):floor(bbox(1)+bbox(3)));
        candidate = edge(imresize(padarray(candidate,[1 1],0,'both'),template_size),'Sobel');
        candidate = bwdist(candidate);
        
        for k = 1:size(templates,2)
            template = edge(imresize(padarray(templates{k},[1 1],0,'both'),template_size),'Sobel');
            v(k) = norm_coef(k)*sum(sum(candidate.*template));
        end
        %disp(v)
        if min(v) < threshold
            
            %Update mask
            output_mask(ceil(bbox(2)):floor(bbox(2)+bbox(4)),ceil(bbox(1)):floor(bbox(1)+bbox(3)))...
                = input_mask(ceil(bbox(2)):floor(bbox(2)+bbox(4)),ceil(bbox(1)):floor(bbox(1)+bbox(3)));

        end
        
    end
    
end
