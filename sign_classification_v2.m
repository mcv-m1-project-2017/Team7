clc
clear all
%%
directory=['C:\Users\Jordi\Jordi\Uni\master CV\M1-Intro to Human Vision\project\training_data_set\train'];
%% Reading the segmentation values
datfile=['segmentation_values.txt'];
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

%% Classification of validation images searching those pixels that are between mean(+/-)std.

datfile=['val_dataset.txt'];
fid=fopen(datfile,'rt');
val_dataset=textscan(fid,'%s');
fclose all;

for i=1:size(val_dataset{1},1)
file_id=val_dataset{1}(i);
im = imread(strcat(directory,'\',file_id{1},'.jpg'));

%technique 1: The threshold is done with the mean(+/-)std of colors rgb of blue and red
%pixels from the training dataset.
im_seg_1=((im(:,:,1)>(b_pixel_r_mean-b_pixel_r_std)) & (im(:,:,1)<(b_pixel_r_mean+b_pixel_r_std))...
    & (im(:,:,2)>(b_pixel_g_mean-b_pixel_g_std)) & (im(:,:,2)<(b_pixel_g_mean+b_pixel_g_std))...
    & (im(:,:,3)>(b_pixel_b_mean-b_pixel_b_std)) & (im(:,:,3)<(b_pixel_b_mean+b_pixel_b_std)))...
    | ((im(:,:,1)>(r_pixel_r_mean-r_pixel_r_std)) & (im(:,:,1)<(r_pixel_r_mean+r_pixel_r_std))...
    & (im(:,:,2)>(r_pixel_g_mean-r_pixel_g_std)) & (im(:,:,2)<(r_pixel_g_mean+r_pixel_g_std))...
    & (im(:,:,3)>(r_pixel_b_mean-r_pixel_b_std)) & (im(:,:,3)<(r_pixel_b_mean+r_pixel_b_std)));


%technique 2: The threshold is done with the mean(+/-)std of rgb ratios of blue and red
%pixels from the training dataset.
im_seg_2=((im(:,:,3)./im(:,:,1)>(b_pixel_br_ratio_mean-b_pixel_br_ratio_std))...
    & (im(:,:,3)./im(:,:,1)<(b_pixel_br_ratio_mean+b_pixel_br_ratio_std))...
    & (im(:,:,3)./im(:,:,2)>(b_pixel_bg_ratio_mean-b_pixel_bg_ratio_std))...
    & (im(:,:,3)./im(:,:,2)<(b_pixel_bg_ratio_mean+b_pixel_bg_ratio_std)))...
    | ((im(:,:,1)./im(:,:,2)>(r_pixel_rg_ratio_mean-r_pixel_rg_ratio_std))...
    & (im(:,:,1)./im(:,:,2)<(r_pixel_rg_ratio_mean+r_pixel_rg_ratio_std))...
    & (im(:,:,1)./im(:,:,3)>(r_pixel_rb_ratio_mean-r_pixel_rb_ratio_std))...
    & (im(:,:,1)./im(:,:,3)<(r_pixel_rb_ratio_mean+r_pixel_rb_ratio_std)));

%technique 3: Both techniques 1 and 2 are added
im_seg_3=((im(:,:,3)./im(:,:,1)>(b_pixel_br_ratio_mean-b_pixel_br_ratio_std))...
    & (im(:,:,3)./im(:,:,1)<(b_pixel_br_ratio_mean+b_pixel_br_ratio_std))...
    & (im(:,:,3)./im(:,:,2)>(b_pixel_bg_ratio_mean-b_pixel_bg_ratio_std))...
    & (im(:,:,3)./im(:,:,2)<(b_pixel_bg_ratio_mean+b_pixel_bg_ratio_std))...
    & (im(:,:,1)>(b_pixel_r_mean-b_pixel_r_std)) & (im(:,:,1)<(b_pixel_r_mean+b_pixel_r_std))...
    & (im(:,:,2)>(b_pixel_g_mean-b_pixel_g_std)) & (im(:,:,2)<(b_pixel_g_mean+b_pixel_g_std))...
    & (im(:,:,3)>(b_pixel_b_mean-b_pixel_b_std)) & (im(:,:,3)<(b_pixel_b_mean+b_pixel_b_std)))...
    | ((im(:,:,1)./im(:,:,2)>(r_pixel_rg_ratio_mean-r_pixel_rg_ratio_std))...
    & (im(:,:,1)./im(:,:,2)<(r_pixel_rg_ratio_mean+r_pixel_rg_ratio_std))...
    & (im(:,:,1)./im(:,:,3)>(r_pixel_rb_ratio_mean-r_pixel_rb_ratio_std))...
    & (im(:,:,1)./im(:,:,3)<(r_pixel_rb_ratio_mean+r_pixel_rb_ratio_std))...
    & (im(:,:,1)>(r_pixel_r_mean-r_pixel_r_std)) & (im(:,:,1)<(r_pixel_r_mean+r_pixel_r_std))...
    & (im(:,:,2)>(r_pixel_g_mean-r_pixel_g_std)) & (im(:,:,2)<(r_pixel_g_mean+r_pixel_g_std))...
    & (im(:,:,3)>(r_pixel_b_mean-r_pixel_b_std)) & (im(:,:,3)<(r_pixel_b_mean+r_pixel_b_std)));

% Saving the segmented mask using each technique.
imwrite(im_seg_1,strcat(directory,'\mask\mask.01.',file_id{1}(4:end),'.png'));
imwrite(im_seg_2,strcat(directory,'\mask\mask.02.',file_id{1}(4:end),'.png'));
imwrite(im_seg_3,strcat(directory,'\mask\mask.03.',file_id{1}(4:end),'.png'));

% figure;
% imshow(im)
% figure;
% imshow(mask*255)
% figure;
% imshow(im_seg_1*255)
% figure;
% imshow(im_seg_2*255)
% figure;
% imshow(im_seg_3*255)
end

