clc
clear all
%%
directory=['C:\Users\Jordi\Jordi\Uni\master CV\M1-Intro to Human Vision\project\training_data_set\train'];
%% 
files = ListFiles(directory); %This function reads de Id. of the images
%% Reading the Id. of the train dataset split.
datfile=['train_dataset.txt'];
fid=fopen(datfile,'rt');
train_dataset=textscan(fid,'%s');
fclose all;
%% Red, green and blue values of Red and Blue pixels from train signals
b_acumulator_r=zeros(0,0); %Red channel values of Blue pixels from train signals.
b_acumulator_g=zeros(0,0); %Green channel values of Blue pixels from train signals.
b_acumulator_b=zeros(0,0); %Blue channel values of Blue pixels from train signals.
r_acumulator_r=zeros(0,0); %Red channel values of Red pixels from train signals.
r_acumulator_g=zeros(0,0); %Green channel values of Red pixels from train signals.
r_acumulator_b=zeros(0,0); %Blue channel values of Red pixels from train signals.

%% Reading and saving the values of Red and Blue pixels that belongs training signals
for i=1:size(train_dataset{1},1)
file_id=train_dataset{1}(i);
datfile=strcat(directory,'\gt\gt.',file_id{1},'.txt');
fid=fopen(datfile,'rt');
gt=textscan(fid,'%f %f %f %f %c');
fclose all;

im = imread(strcat(directory,'\',file_id{1},'.jpg')); %Image from the training dataset
mask=imread(strcat(directory,'\mask\mask.',file_id{1},'.png')); %Mask of the image im
%The image im_mask will be the image im, but with 0 value for the pixels
%that are not a signal.
im_mask(:,:,1)=im(:,:,1).*mask; %Red channel of the signals of the image im (Multiplication of the image with the mask
im_mask(:,:,2)=im(:,:,2).*mask; %Green channel of the signals of the image im (Multiplication of the image with the mask
im_mask(:,:,3)=im(:,:,3).*mask; %Blue channel of the signals of the image im (Multiplication of the image with the mask

    for j=1:size(gt{1},1) %This loop is done as many times as signals are in the image.
                                   
         im_mask_sign=im_mask(gt{1}(j):gt{3}(j),gt{2}(j):gt{4}(j),:); %im_mask_sign is an image of one signal from the image im
         im_mask_sign_r=im_mask_sign(:,:,1);
         im_mask_sign_g=im_mask_sign(:,:,2);
         im_mask_sign_b=im_mask_sign(:,:,3);
         %The blue pixels will be those that the channel blue is a 20% higher than chanels green and red.
         %The red pixels will be those that the channel red is a 20% higher than chanels green and blue.
         b_pixels=(im_mask_sign(:,:,1)*1.2<im_mask_sign(:,:,3) & im_mask_sign(:,:,2)*1.2<im_mask_sign(:,:,3)); %Mask of the blue pixels from the signal.
         r_pixels=(im_mask_sign(:,:,2)*1.2<im_mask_sign(:,:,1) & im_mask_sign(:,:,3)*1.2<im_mask_sign(:,:,1)); %Mask of the red pixels from the signal.
         b_acumulator_r=cat(1,b_acumulator_r,im_mask_sign_r(b_pixels)); %Saving the red value of blue pixels from signals.
         b_acumulator_g=cat(1,b_acumulator_g,im_mask_sign_g(b_pixels)); %Saving the green value of blue pixels from signals.
         b_acumulator_b=cat(1,b_acumulator_b,im_mask_sign_b(b_pixels)); %Saving the blue value of blue pixels from signals.
         r_acumulator_r=cat(1,r_acumulator_r,im_mask_sign_r(r_pixels)); %Saving the red value of red pixels from signals.
         r_acumulator_g=cat(1,r_acumulator_g,im_mask_sign_g(r_pixels)); %Saving the green value of green pixels from signals.
         r_acumulator_b=cat(1,r_acumulator_b,im_mask_sign_b(r_pixels)); %Saving the blue value of red pixels from signals.
         
         clear im_mask_sign im_mask_sign_r im_mask_sign_g im_mask_sign_b b_pixels r_pixels
    end
    
clear file_id datfile fid gt im mask im_mask  
end

%% Calculation of the relation between channels of blue and red pixels
b_pixel_br_ratio=double(b_acumulator_b)./double(b_acumulator_r); %For each blue pixel saved, how many times is the blue channel higher than the red channel?
b_pixel_bg_ratio=double(b_acumulator_b)./double(b_acumulator_g); %For each blue pixel saved, how many times is the blue channel higher than the green channel?

r_pixel_rg_ratio=double(r_acumulator_r)./double(r_acumulator_g); %For each red pixel saved, how many times is the red channel higher than the green channel?
r_pixel_rb_ratio=double(r_acumulator_r)./double(r_acumulator_b); %For each red pixel saved, how many times is the red channel higher than the green channel?

%Since the ratios calculated can be pixels divided by 0 (infinite), all
%values of ratio upper than 10 (going to infinite) are substituted by 10.
for k1=1:size(b_acumulator_b,1)
    if b_pixel_br_ratio(k1)>10
         b_pixel_br_ratio(k1)=10;
    end
    if b_pixel_bg_ratio(k1)>10
         b_pixel_bg_ratio(k1)=10;
    end
end
    
for k2=1:size(r_acumulator_r,1)
    if r_pixel_rg_ratio(k2)>10
         r_pixel_rg_ratio(k2)=10;
    end
    if r_pixel_rb_ratio(k2)>10
         r_pixel_rb_ratio(k2)=10;
    end
end
    
%% Calculation of the means and standards deviations of the blue and red pixels.
b_pixel_r_mean=mean(b_acumulator_r); %Mean of the red channel values of Blue pixels.
b_pixel_r_std=std(double(b_acumulator_r)); %Standard deviation of the red channel values of Blue pixels.
b_pixel_g_mean=mean(b_acumulator_g); %Mean of the green channel values of Blue pixels.
b_pixel_g_std=std(double(b_acumulator_g)); %Standard deviation of the green channel values of Blue pixels.
b_pixel_b_mean=mean(b_acumulator_b); %Mean of the blue channel values of Blue pixels.
b_pixel_b_std=std(double(b_acumulator_b)); %Standard deviation of the blue channel values of Blue pixels.

r_pixel_r_mean=mean(r_acumulator_r); %Mean of the red channel values of Red pixels.
r_pixel_r_std=std(double(r_acumulator_r)); %Standard deviation of the red channel values of Red pixels.
r_pixel_g_mean=mean(r_acumulator_g); %Mean of the green channel values of Red pixels.
r_pixel_g_std=std(double(r_acumulator_g)); %Standard deviation of the green channel values of Red pixels.
r_pixel_b_mean=mean(r_acumulator_b); %Mean of the blue channel values of Red pixels.
r_pixel_b_std=std(double(r_acumulator_b)); %Standard deviation of the blue channel values of Red pixels.

b_pixel_br_ratio_mean=mean(b_pixel_br_ratio); %Mean of the blue/red ratios of Blue pixels.
b_pixel_br_ratio_std=std(b_pixel_br_ratio); %Standard deviation of the blue/red ratios of Blue pixels.
b_pixel_bg_ratio_mean=mean(b_pixel_bg_ratio); %Mean of the blue/green ratios of Blue pixels.
b_pixel_bg_ratio_std=std(b_pixel_bg_ratio); %Standard of the blue/green ratios of Blue pixels.

r_pixel_rg_ratio_mean=mean(r_pixel_rg_ratio); %Mean of the red/green ratios of Red pixels.
r_pixel_rg_ratio_std=std(r_pixel_rg_ratio); %Standard deviation of the red/green ratios of Red pixels.
r_pixel_rb_ratio_mean=mean(r_pixel_rb_ratio); %Mean of the red/blue ratios of Red pixels.
r_pixel_rb_ratio_std=std(r_pixel_rb_ratio); %Standard deviation of the red/blue ratios of Red pixels.

%% Writing the segmentation values in a text file.
fileID=fopen(['segmentation_values.txt'],'w');
fprintf(fileID,'%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\r\n', b_pixel_r_mean,b_pixel_r_std,b_pixel_g_mean,b_pixel_g_std,b_pixel_b_mean,b_pixel_b_std);
fprintf(fileID,'%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\r\n', r_pixel_r_mean,r_pixel_r_std,r_pixel_g_mean,r_pixel_g_std,r_pixel_b_mean,r_pixel_b_std);
fprintf(fileID,'%.1f\t%.1f\t%.1f\t%.1f\r\n', b_pixel_br_ratio_mean,b_pixel_br_ratio_std,b_pixel_bg_ratio_mean,b_pixel_bg_ratio_std);
fprintf(fileID,'%.1f\t%.1f\t%.1f\t%.1f\r\n', r_pixel_rg_ratio_mean,r_pixel_rg_ratio_std,r_pixel_rb_ratio_mean,r_pixel_rb_ratio_std);
fclose all ;
      