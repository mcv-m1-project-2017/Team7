function [im_seg] = apply_morph_operator_v2(im_seg, method)
switch(method)
     case 1 %Method used for week 3
            %Obtain min and max signal sizes:
            sizes = txt2cell('dataset_analysis.txt', 'columns', [1 2 3]);
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
    
    case 2 %Improvement for week 4
            SE=strel('disk',6);
            im_seg= imdilate(im_seg, SE);
            im_seg = imfill(im_seg, 'holes');
            im_seg=imerode(im_seg,SE);
            im_seg=imopen(im_seg,SE);
    
    case 3 %Improvement for week 4
            
            im_seg = imfill(im_seg,'holes');     
            SE_S = ones(9,9);
            SE_C = strel('diamond',9);
            SE_T1 = [ 0   0   0   0   0   1   0   0   0   0   0
                      0   0   0   0   0   1   0   0   0   0   0
                      0   0   0   0   1   1   1   0   0   0   0
                      0   0   0   0   1   1   1   0   0   0   0
                      0   0   0   1   1   1   1   1   0   0   0
                      0   0   0   1   1   1   1   1   0   0   0
                      0   0   1   1   1   1   1   1   1   0   0
                      0   0   1   1   1   1   1   1   1   0   0
                      0   1   1   1   1   1   1   1   1   1   0
                      0   1   1   1   1   1   1   1   1   1   0
                      1   1   1   1   1   1   1   1   1   1   1 ];
            SE_T2 = flipud(SE_T1);
            final_mask_T1 = imopen(im_seg, SE_T1);
            final_mask_T2 = imopen(im_seg, SE_T2);
            final_mask_C = imopen(im_seg, SE_C);
            final_mask_S = imopen(im_seg, SE_S);
            im_seg = or(or(or(final_mask_T1, final_mask_T2), final_mask_C), final_mask_S);
    case 4 %Improvement for week 4
            SE=strel('diamond',4);
            im_seg= imdilate(im_seg, SE);
            im_seg = imfill(im_seg, 'holes');
            im_seg=imerode(im_seg,SE);
            SE_1 = [0   0   1   1   1   1   1   1   1   0   0
                    0   1   1   1   1   1   1   1   1   1   0
                    1   1   1   1   1   1   1   1   1   1   1
                    1   1   1   1   1   1   1   1   1   1   1
                    1   1   1   1   1   1   1   1   1   1   1
                    1   1   1   1   1   1   1   1   1   1   1
                    1   1   1   1   1   1   1   1   1   1   1
                    1   1   1   1   1   1   1   1   1   1   1
                    1   1   1   1   1   1   1   1   1   1   1
                    0   1   1   1   1   1   1   1   1   1   0
                    0   0   1   1   1   1   1   1   1   0   0];
                 
            im_seg=imopen(im_seg,SE_1);
            
    otherwise
        disp('Error, not a valid method')
end
end
