clc
clear all
%%
directory=['/home/mcv00/DataSet/4c/train'];
%% 
files = ListFiles(directory); %This function reads de Id. of the images
%% Reading the Id. of the train dataset split.
train_features=txt2cell('train_dataset.txt');

%% Reading and saving the values of Red and Blue pixels that belongs training signals
for i=1:size(train_features,1)
file_id=train_features{i,1};
im = imread(strcat(directory,'/',file_id,'.jpg')); %Image from the training dataset
mask=imread(strcat(directory,'/mask/mask.',file_id,'.png')); %Mask of the image im
mask(mask~=0)=1; % some masks are not binary !!! 

tly=str2num(train_features{i,9});
tlx=str2num(train_features{i,10});
bry=str2num(train_features{i,11});
brx=str2num(train_features{i,12});

im_mask_sign(:,:,1)=im(tly:bry,tlx:brx,1).*mask(tly:bry,tlx:brx,:); %Red channel of the signal pixels (Multiplication of the image with the mask
im_mask_sign(:,:,2)=im(tly:bry,tlx:brx,2).*mask(tly:bry,tlx:brx,:); %Green channel of the signal pixels (Multiplication of the image with the mask
im_mask_sign(:,:,3)=im(tly:bry,tlx:brx,3).*mask(tly:bry,tlx:brx,:); %Blue channel of the signal pixels (Multiplication of the image with the mask

%The blue pixels will be those that the channel blue is a 15% higher than chanels green and red.
%The red pixels will be those that the channel red is a 15% higher than chanels green and blue.
 b_pixels=(im_mask_sign(:,:,1)*1.2<im_mask_sign(:,:,3) & im_mask_sign(:,:,2)*1.2<im_mask_sign(:,:,3)); %Mask of the blue pixels from the signal.
 r_pixels=(im_mask_sign(:,:,2)*1.2<im_mask_sign(:,:,1) & im_mask_sign(:,:,3)*1.2<im_mask_sign(:,:,1)); %Mask of the red pixels from the signal.
 if i==1
 b_acumulator=reshape(im_mask_sign((repmat(b_pixels,[1 1 3]))),[],1,3);
 r_acumulator=reshape(im_mask_sign((repmat(r_pixels,[1 1 3]))),[],1,3);
 else
 b_acumulator=cat(1,b_acumulator,reshape(im_mask_sign((repmat(b_pixels,[1 1 3]))),[],1,3)); %Saving the value of blue pixels from signals.   
 r_acumulator=cat(1,r_acumulator,reshape(im_mask_sign((repmat(r_pixels,[1 1 3]))),[],1,3)); %Saving value of red pixels from signals.
 end
 
 %  figure;
%  imshow(im_mask_sign);
%  figure;
%  imshow(b_pixels+r_pixels);
 
clear file_id datfile fid gt im mask im_mask_sign im_mask_sign_r im_mask_sign_g im_mask_sign_b b_pixels r_pixels
end

b_acumulator_YCbCr= rgb2ycbcr(b_acumulator);%Value of blue pixels from signals in YCbCr
b_acumulator_HSV = rgb2hsv(b_acumulator);%Value of blue pixels from signals in HSV
r_acumulator_YCbCr= rgb2ycbcr(r_acumulator);%Value of red pixels from signals in YCbCr
r_acumulator_HSV = rgb2hsv(r_acumulator);%Value of red pixels from signals in HSV

%% Calculation of the relation between channels of blue and red pixels
b_pixel_br_ratio=double(b_acumulator(:,:,3))./double(b_acumulator(:,:,1)); %For each blue pixel saved, how many times is the blue channel higher than the red channel?
b_pixel_br_ratio(b_pixel_br_ratio>10)=10;%values of ratio upper than 10 (going to infinite) are substituted by 10.
b_pixel_bg_ratio=double(b_acumulator(:,:,3))./double(b_acumulator(:,:,2)); %For each blue pixel saved, how many times is the blue channel higher than the green channel?
b_pixel_bg_ratio(b_pixel_bg_ratio>10)=10;%values of ratio upper than 10 (going to infinite) are substituted by 10.

r_pixel_rg_ratio=double(r_acumulator(:,:,1))./double(r_acumulator(:,:,2)); %For each red pixel saved, how many times is the red channel higher than the green channel?
r_pixel_rg_ratio(r_pixel_rg_ratio>10)=10;%values of ratio upper than 10 (going to infinite) are substituted by 10.
r_pixel_rb_ratio=double(r_acumulator(:,:,1))./double(r_acumulator(:,:,3)); %For each red pixel saved, how many times is the red channel higher than the green channel?
r_pixel_rb_ratio(r_pixel_rb_ratio>10)=10;%values of ratio upper than 10 (going to infinite) are substituted by 10.

    
%% Calculation of the means and standards deviations of the blue and red pixels.
b_pixel_r_mean=mean(b_acumulator(:,:,1)); %Mean of the red channel values of Blue pixels.
b_pixel_r_std=std(double(b_acumulator(:,:,1))); %Standard deviation of the red channel values of Blue pixels.
b_pixel_g_mean=mean(b_acumulator(:,:,2)); %Mean of the green channel values of Blue pixels.
b_pixel_g_std=std(double(b_acumulator(:,:,2))); %Standard deviation of the green channel values of Blue pixels.
b_pixel_b_mean=mean(b_acumulator(:,:,3)); %Mean of the blue channel values of Blue pixels.
b_pixel_b_std=std(double(b_acumulator(:,:,3))); %Standard deviation of the blue channel values of Blue pixels.

r_pixel_r_mean=mean(r_acumulator(:,:,1)); %Mean of the red channel values of Red pixels.
r_pixel_r_std=std(double(r_acumulator(:,:,1))); %Standard deviation of the red channel values of Red pixels.
r_pixel_g_mean=mean(r_acumulator(:,:,2)); %Mean of the green channel values of Red pixels.
r_pixel_g_std=std(double(r_acumulator(:,:,2))); %Standard deviation of the green channel values of Red pixels.
r_pixel_b_mean=mean(r_acumulator(:,:,3)); %Mean of the blue channel values of Red pixels.
r_pixel_b_std=std(double(r_acumulator(:,:,3))); %Standard deviation of the blue channel values of Red pixels.

b_pixel_br_ratio_mean=mean(b_pixel_br_ratio); %Mean of the blue/red ratios of Blue pixels.
b_pixel_br_ratio_std=std(b_pixel_br_ratio); %Standard deviation of the blue/red ratios of Blue pixels.
b_pixel_bg_ratio_mean=mean(b_pixel_bg_ratio); %Mean of the blue/green ratios of Blue pixels.
b_pixel_bg_ratio_std=std(b_pixel_bg_ratio); %Standard of the blue/green ratios of Blue pixels.

r_pixel_rg_ratio_mean=mean(r_pixel_rg_ratio); %Mean of the red/green ratios of Red pixels.
r_pixel_rg_ratio_std=std(r_pixel_rg_ratio); %Standard deviation of the red/green ratios of Red pixels.
r_pixel_rb_ratio_mean=mean(r_pixel_rb_ratio); %Mean of the red/blue ratios of Red pixels.
r_pixel_rb_ratio_std=std(r_pixel_rb_ratio); %Standard deviation of the red/blue ratios of Red pixels.

b_pixel_H_mean=mean(b_acumulator_HSV(:,:,1));%Mean of the H channel values of Blue pixels.
b_pixel_H_std=std(b_acumulator_HSV(:,:,1));%Standard deviation of H channel values of Blue pixels.

r_acumulator_H=r_acumulator_HSV(:,:,1);
r_acumulator_H(r_acumulator_H<0.5)=r_acumulator_H(r_acumulator_H<0.5)+1;%Since r_acumulator_H has values from 0.86 to 0.13, the values lower than 0.5 are incressed by 1 in order to have continuity
r_pixel_H_mean=mean(r_acumulator_H);%Mean of the H channel values of Red pixels.
r_pixel_H_std=std(double(r_acumulator_H));%Standard deviation of H channel values of Red pixels.

b_pixel_Cb_mean=mean(b_acumulator_YCbCr(:,:,2));%Mean of the Cb channel values of Blue pixels.
b_pixel_Cb_std=std(double(b_acumulator_YCbCr(:,:,2)));%Standard deviation of Cb channel values of Blue pixels.
b_pixel_Cr_mean=mean(b_acumulator_YCbCr(:,:,3));%Mean of the Cr channel values of Blue pixels.
b_pixel_Cr_std=std(double(b_acumulator_YCbCr(:,:,3)));%Standard deviation of Cr channel values of Blue pixels.

r_pixel_Cb_mean=mean(r_acumulator_YCbCr(:,:,2));%Mean of the Cb channel values of Red pixels.
r_pixel_Cb_std=std(double(r_acumulator_YCbCr(:,:,2)));%Standard deviation of Cb channel values of Red pixels.
r_pixel_Cr_mean=mean(r_acumulator_YCbCr(:,:,3));%Mean of the Cr channel values of Red pixels.
r_pixel_Cr_std=std(double(r_acumulator_YCbCr(:,:,3)));%Standard deviation of Cr channel values of Red pixels.


%% Writing the segmentation values in a text file.
fileID=fopen(['segmentation_values.txt'],'w');
fprintf(fileID,'%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\r\n', b_pixel_r_mean,b_pixel_r_std,b_pixel_g_mean,b_pixel_g_std,b_pixel_b_mean,b_pixel_b_std);
fprintf(fileID,'%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\r\n', r_pixel_r_mean,r_pixel_r_std,r_pixel_g_mean,r_pixel_g_std,r_pixel_b_mean,r_pixel_b_std);
fprintf(fileID,'%.3f\t%.3f\t%.3f\t%.3f\r\n', b_pixel_br_ratio_mean,b_pixel_br_ratio_std,b_pixel_bg_ratio_mean,b_pixel_bg_ratio_std);
fprintf(fileID,'%.3f\t%.3f\t%.3f\t%.3f\r\n', r_pixel_rg_ratio_mean,r_pixel_rg_ratio_std,r_pixel_rb_ratio_mean,r_pixel_rb_ratio_std);
fprintf(fileID,'%.3f\t%.3f\t%.1f\t%.1f\t%.1f\t%.1f\r\n', b_pixel_H_mean,b_pixel_H_std,b_pixel_Cb_mean,b_pixel_Cb_std,b_pixel_Cr_mean,b_pixel_Cr_std);
fprintf(fileID,'%.3f\t%.3f\t%.1f\t%.1f\t%.1f\t%.1f\r\n', r_pixel_H_mean,r_pixel_H_std,r_pixel_Cb_mean,r_pixel_Cb_std,r_pixel_Cr_mean,r_pixel_Cr_std);
fclose all ;
      