function im_seg = mean_shift_segmentation(image, factor, colorspace, segmentation_values, stdr, show)
%tic

image = rgb2hsv(im2double(image));
if strcmp(colorspace,'HandCbCr')
     im_YCbCr=rgb2ycbcr(hsv2rgb(image));
     image(:,:,2) = im_YCbCr(:,:,2);
     image(:,:,3) = im_YCbCr(:,:,3);
     clear im_YCbCr
end
image = imresize(image, factor); %Subsample image to accelerate computation.
im_gray = rgb2gray(image);
data_pts = reshape(image,size(image,1)*size(image,2), size(image,3));
im_seg = reshape(im_gray,size(im_gray,1)*size(im_gray,2), size(im_gray,3));

% Mean-shift clustering:
[~,~,cluster2dataCell] = MeanShiftCluster(data_pts',0.1);
for i = 1:length(cluster2dataCell)
    if segment(data_pts(cluster2dataCell{i}, :), colorspace, segmentation_values, stdr)
        im_seg(cluster2dataCell{i}) = 255; % Signal detected
    else
        im_seg(cluster2dataCell{i}) = 0; % Not a signal
    end
end

%Return to original shape:
im_seg = reshape(im_seg(:), size(image,1), size(image,2));
im_seg = imresize(im_seg, 1/factor);

%Erase bigger and smaller areas than max and min signal size:
sizes = txt2cell('dataset_analysis.txt', 'columns', [1 2]);
max_size = max(cell2mat(cellfun(@str2num,sizes(:, 2),'un',0)));
min_size = min(cell2mat(cellfun(@str2num,sizes(:,1),'un',0)));

im_seg = xor(bwareaopen(im_seg,min_size), bwareaopen(im_seg,max_size));

if show, figure; imshow(im_seg); end
%toc
end

function [out] = segment(data_pts, colorspace, segmentation_values, stdr)
    switch colorspace
        case 'HSV'
            out = check_hsv_cluster(data_pts, 0.85, 2);   
        case 'HS'
            out = check_hs_cluster(data_pts, 0.85);
        case 'HS2'
            out = check_hs2_cluster(data_pts, 0.85, segmentation_values, stdr);
        case 'HandCbCr'
            out = check_HandCbCr_cluster(data_pts, 0.85, segmentation_values, stdr);
    end
end

function [out] = check_hsv_cluster(hsv, threshold, method)
    if method == 1
        color_filter = ( ( (hsv(:, 1) >= 0.925) | (hsv(:, 1) <= 0.1) ...
                        | ( (hsv(:, 1) >= 0.5) & (hsv(:, 1) <= 0.78) ) ) ...
                        & (hsv(:, 2)) & (hsv(:, 3)>= 0.15) );
        sample = nnz((color_filter)) / numel(color_filter);
        out = sample >= threshold;
    elseif method == 2
             hred = [350 20];
             hblueA = [180 250];
             hblueB = [210 300];
             sred = 0.45;
             sblueA = 0.4;
             sblueB = [0.15 0.4];
             vred = 0;%0.25;
             vblueB = 0.3;

              red = ((((hsv(:, 1)<hred(2))&(hsv(:, 1)>=0))|((hsv(:, 1)<=360)...
                  &(hsv(:, 1)>hred(1))))&(hsv(:, 2)>sred)&(hsv(:, 3)>vred));
              blueA = ((hsv(:, 1)<hblueA(2)) & (hsv(:, 1)>hblueA(1)) & (hsv(:, 2)>sblueA));
              blueB = ((hsv(:, 1)<hblueB(2)) & (hsv(:, 1)>hblueB(1)) & (hsv(:, 2)>sblueB(1))...
                  & (hsv(:, 2)<sblueB(2))) &(hsv(:, 3)<vblueB);
              color_filter = red | blueA | blueB;
              sample = nnz(color_filter) /numel(color_filter);
              out = sample >= threshold;
    else
        error('Incorrect Method');
    end
end

function out = check_hs_cluster(hs, threshold)
    mask_RED = (hs(:,1) > 0.9 | hs(:,1) < 0.07) & hs(:,2)>0.4 & hs(:,3)>0;
    mask_BLUE1 = hs(:,1) > 0.5 & hs(:,1) < 0.7 & hs(:,2)>0.4 & hs(:,3)>0;
    mask_BLUE2 = hs(:,1) > 0.58 & hs(:,1) < 0.83 & hs(:,2) > 0.15 & hs(:,2) < 0.4 & hs(:,3) < 0.3; 
    color_filter = mask_BLUE1 | mask_RED | mask_BLUE2;
    sample = nnz(color_filter) /numel(color_filter);
    out = sample >= threshold;
end

function out = check_hs2_cluster(hs2, threshold, segmentation_values, stdr)

    b_pixel_H_mean=segmentation_values(21);
    b_pixel_H_std=segmentation_values(22)*stdr;
    r_pixel_H_mean=segmentation_values(27);
    r_pixel_H_std=segmentation_values(28)*stdr;            
    b_pixel_S_mean=segmentation_values(33);
    b_pixel_S_std=segmentation_values(34)*stdr;
    r_pixel_S_mean=segmentation_values(35);
    r_pixel_S_std=segmentation_values(36)*stdr;
    color_filter = ((hs2(:,1)>(b_pixel_H_mean-b_pixel_H_std)) & (hs2(:,1)<(b_pixel_H_mean+b_pixel_H_std))...
            & (hs2(:,2)>(b_pixel_S_mean-b_pixel_S_std)) & (hs2(:,2)<(b_pixel_S_mean+b_pixel_S_std)))...
            | ((((hs2(:,1)>(r_pixel_H_mean-r_pixel_H_std)) & (hs2(:,1)<1)) | (hs2(:,1)<(r_pixel_H_mean+r_pixel_H_std-1)))...
            &(hs2(:,2)>(r_pixel_S_mean-r_pixel_S_std)) & (hs2(:,2)<(r_pixel_S_mean+r_pixel_S_std)));    
    sample = nnz(color_filter) /numel(color_filter);
    out = sample >= threshold;

end

function out = check_HandCbCr_cluster(HandCbCr, threshold, segmentation_values, stdr)

    b_pixel_Cb_mean=segmentation_values(23);
    b_pixel_Cb_std=segmentation_values(24)*stdr;
    b_pixel_Cr_mean=segmentation_values(25);
    b_pixel_Cr_std=segmentation_values(26)*stdr;

    r_pixel_Cb_mean=segmentation_values(29);
    r_pixel_Cb_std=segmentation_values(30)*stdr;
    r_pixel_Cr_mean=segmentation_values(31);
    r_pixel_Cr_std=segmentation_values(32)*stdr;
            
    b_pixel_H_mean=segmentation_values(21);
    b_pixel_H_std=segmentation_values(22)*stdr;
    r_pixel_H_mean=segmentation_values(27);
    r_pixel_H_std=segmentation_values(28)*stdr;
            
    color_filter = (((HandCbCr(:,1)>(b_pixel_H_mean-b_pixel_H_std)) & (HandCbCr(:,1)<(b_pixel_H_mean+b_pixel_H_std)))...
                | ((HandCbCr(:,1)>(r_pixel_H_mean-r_pixel_H_std)) & (HandCbCr(:,1)<1))...
                | (HandCbCr(:,1)<(r_pixel_H_mean+r_pixel_H_std-1)))...
                & (((HandCbCr(:,2)>(b_pixel_Cb_mean-b_pixel_Cb_std)) & (HandCbCr(:,2)<(b_pixel_Cb_mean+b_pixel_Cb_std))...
                & (HandCbCr(:,3)>(b_pixel_Cr_mean-b_pixel_Cr_std)) & (HandCbCr(:,3)<(b_pixel_Cr_mean+b_pixel_Cr_std)))...
                | ((HandCbCr(:,2)>(r_pixel_Cb_mean-r_pixel_Cb_std)) & (HandCbCr(:,2)<(r_pixel_Cb_mean+r_pixel_Cb_std))...
                & (HandCbCr(:,3)>(r_pixel_Cr_mean-r_pixel_Cr_std)) & (HandCbCr(:,3)<(r_pixel_Cr_mean+r_pixel_Cr_std))));
    sample = nnz(color_filter) /numel(color_filter);
    out = sample >= threshold;
end