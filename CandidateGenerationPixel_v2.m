
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandidateGeneration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%    

directory='/home/mcv00/DataSet/4c/train';
files = ListFiles(directory);

space='HCbCr';  %'seg_type' string that can be 'RGB' 'CbCr', 'H' or 'HCbCr', indicating 
%                   which color channels are used in the segmentation
 
%% Reading the segmentation values
datfile=['segmentation_values.txt'];
% segmentation_values=txt2cell('segmentation_values.txt');
fid=fopen(datfile,'rt');
segmentation_values=fscanf(fid,'%f');
fclose all;

%Means and Standards deviations of blue pixels from training signals.
b_pixel_r_mean=segmentation_values(1);
b_pixel_r_std=segmentation_values(2);
b_pixel_g_mean=segmentation_values(3);
b_pixel_g_std=segmentation_values(4);
b_pixel_b_mean=segmentation_values(5);
b_pixel_b_std=segmentation_values(6);

%Means and Standards deviations of red pixels from training signals.
r_pixel_r_mean=segmentation_values(7);
r_pixel_r_std=segmentation_values(8);
r_pixel_g_mean=segmentation_values(9);
r_pixel_g_std=segmentation_values(10);
r_pixel_b_mean=segmentation_values(11);
r_pixel_b_std=segmentation_values(12);

%Means and Standards deviations of the blue/red and blue/green ratios of blue pixels from training signals.
b_pixel_br_ratio_mean=segmentation_values(13);
b_pixel_br_ratio_std=segmentation_values(14);
b_pixel_bg_ratio_mean=segmentation_values(15);
b_pixel_bg_ratio_std=segmentation_values(16);

%Means and Standards deviations of the red/green and red/blue ratios of red pixels from training signals.
r_pixel_rg_ratio_mean=segmentation_values(17);
r_pixel_rg_ratio_std=segmentation_values(18);
r_pixel_rb_ratio_mean=segmentation_values(19);
r_pixel_rb_ratio_std=segmentation_values(20);

%Means and Standards deviations of red pixels from training signals in H
%space.
b_pixel_H_mean=segmentation_values(21);
b_pixel_H_std=segmentation_values(22);
r_pixel_H_mean=segmentation_values(27);
r_pixel_H_std=segmentation_values(28);

%Means and Standards deviations of red pixels from training signals in CbCr
%space.
b_pixel_Cb_mean=segmentation_values(23);
b_pixel_Cb_std=segmentation_values(24);
b_pixel_Cr_mean=segmentation_values(25);
b_pixel_Cr_std=segmentation_values(26);

r_pixel_Cb_mean=segmentation_values(29);
r_pixel_Cb_std=segmentation_values(30);
r_pixel_Cr_mean=segmentation_values(31);
r_pixel_Cr_std=segmentation_values(32);


%% Classification of images searching those pixels that are between mean(+\-)std.
for i=1:size(files,1),

    im = imread(strcat(directory,'/',files(i).name)); 


    switch space
        case 'RGB'
             im_seg=((double(im(:,:,3))./double(im(:,:,1))>(b_pixel_br_ratio_mean-b_pixel_br_ratio_std))...
                & (double(im(:,:,3))./double(im(:,:,1))<(b_pixel_br_ratio_mean+b_pixel_br_ratio_std))...
                & (double(im(:,:,3))./double(im(:,:,2))>(b_pixel_bg_ratio_mean-b_pixel_bg_ratio_std))...
                & (double(im(:,:,3))./double(im(:,:,2))<(b_pixel_bg_ratio_mean+b_pixel_bg_ratio_std))...
                & (im(:,:,1)>(b_pixel_r_mean-b_pixel_r_std)) & (im(:,:,1)<(b_pixel_r_mean+b_pixel_r_std))...
                & (im(:,:,2)>(b_pixel_g_mean-b_pixel_g_std)) & (im(:,:,2)<(b_pixel_g_mean+b_pixel_g_std))...
                & (im(:,:,3)>(b_pixel_b_mean-b_pixel_b_std)) & (im(:,:,3)<(b_pixel_b_mean+b_pixel_b_std)))...
                | ((double(im(:,:,1))./double(im(:,:,2))>(r_pixel_rg_ratio_mean-r_pixel_rg_ratio_std))...
                & (double(im(:,:,1))./double(im(:,:,2))<(r_pixel_rg_ratio_mean+r_pixel_rg_ratio_std))...
                & (double(im(:,:,1))./double(im(:,:,3))>(r_pixel_rb_ratio_mean-r_pixel_rb_ratio_std))...
                & (double(im(:,:,3))./double(im(:,:,1))<(r_pixel_rb_ratio_mean+r_pixel_rb_ratio_std))...
                & (im(:,:,1)>(r_pixel_r_mean-r_pixel_r_std)) & (im(:,:,1)<(r_pixel_r_mean+r_pixel_r_std))...
                & (im(:,:,2)>(r_pixel_g_mean-r_pixel_g_std)) & (im(:,:,2)<(r_pixel_g_mean+r_pixel_g_std))...
                & (im(:,:,3)>(r_pixel_b_mean-r_pixel_b_std)) & (im(:,:,3)<(r_pixel_b_mean+r_pixel_b_std)));


        case 'CbCr'
           im_YCbCr=rgb2ycbcr(im);
           im_seg= ((im_YCbCr(:,:,2)>(b_pixel_Cb_mean-b_pixel_Cb_std)) & (im_YCbCr(:,:,2)<(b_pixel_Cb_mean+b_pixel_Cb_std))...
                & (im_YCbCr(:,:,3)>(b_pixel_Cr_mean-b_pixel_Cr_std)) & (im_YCbCr(:,:,3)<(b_pixel_Cr_mean+b_pixel_Cr_std)))...
                | ((im_YCbCr(:,:,2)>(r_pixel_Cb_mean-r_pixel_Cb_std)) & (im_YCbCr(:,:,2)<(r_pixel_Cb_mean+r_pixel_Cb_std))...
                & (im_YCbCr(:,:,3)>(r_pixel_Cr_mean-r_pixel_Cr_std)) & (im_YCbCr(:,:,3)<(r_pixel_Cr_mean+r_pixel_Cr_std)));
            
        case 'H'
           im_HSV=rgb2hsv(im);
           im_seg= ((im_HSV(:,:,1)>(b_pixel_H_mean-b_pixel_H_std)) & (im_HSV(:,:,1)<(b_pixel_H_mean+b_pixel_H_std)))...
                | ((im_HSV(:,:,1)>(r_pixel_H_mean-r_pixel_H_std)) & (im_HSV(:,:,1)<1))...
                | (im_HSV(:,:,1)<(r_pixel_H_mean+r_pixel_H_std-1));
                case 'CbCr'

            
        case 'HCbCr'
           im_HSV=rgb2hsv(im);
           im_YCbCr=rgb2ycbcr(im);
           im_seg= (((im_HSV(:,:,1)>(b_pixel_H_mean-b_pixel_H_std)) & (im_HSV(:,:,1)<(b_pixel_H_mean+b_pixel_H_std)))...
                | ((im_HSV(:,:,1)>(r_pixel_H_mean-r_pixel_H_std)) & (im_HSV(:,:,1)<1))...
                | (im_HSV(:,:,1)<(r_pixel_H_mean+r_pixel_H_std-1)))...
                & (((im_YCbCr(:,:,2)>(b_pixel_Cb_mean-b_pixel_Cb_std)) & (im_YCbCr(:,:,2)<(b_pixel_Cb_mean+b_pixel_Cb_std))...
                & (im_YCbCr(:,:,3)>(b_pixel_Cr_mean-b_pixel_Cr_std)) & (im_YCbCr(:,:,3)<(b_pixel_Cr_mean+b_pixel_Cr_std)))...
                | ((im_YCbCr(:,:,2)>(r_pixel_Cb_mean-r_pixel_Cb_std)) & (im_YCbCr(:,:,2)<(r_pixel_Cb_mean+r_pixel_Cb_std))...
                & (im_YCbCr(:,:,3)>(r_pixel_Cr_mean-r_pixel_Cr_std)) & (im_YCbCr(:,:,3)<(r_pixel_Cr_mean+r_pixel_Cr_std))));

        otherwise
            error('Incorrect color space defined');

    end
    
%   figure;
%   imshow(im)
%   figure;
%   imshow(im_seg*255)
  
    %Hole filling:
    im_seg = imfill(im_seg, 'holes');
%   figure;
%   imshow(im_seg*255)
    
    %Obtain min and max signal sizes:
    sizes = txt2cell('/home/mcv07/Team7/dataset_analysis.txt', 'columns', [1 2]);
    max_size = max(cell2mat(cellfun(@str2num,sizes(:, 2),'un',0)));
    min_size = min(cell2mat(cellfun(@str2num,sizes(:,1),'un',0)));
    
  
   % Saving the segmented mask.
    imwrite(im_seg,strcat('candidate_mask/mask.01.',files(i).name(1:9),'.png'));
    clear im im_seg

end

