
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandidateGeneration - Week3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%    
clear
clc 
mkdir('results');
directory='D:\Documentos\MCV\M1. Introduction to human and computer vision\Project\train';
files = ListFiles(directory);
Method=3; %Int value: 1 if want to aply the task 1 method
space='HCbCr';  %'seg_type' string that can be 'RGB' 'CbCr', 'H' or 'HCbCr', indicating which color channels are used in the segmentation
morph_operator='Yes'; %'morph_operator' string that can be 'Yes','No', indicating if morphological operators are used
std=1.3; %standard deviation increase
write_results = 0; % Int value: 1 if want to save generated masks, 0 otherwise
show=0; % Int value: 1 if want to show the results, 0 otherwise

if Method==1
    CCL=1; % Int value: 1 if want to aply the ConnectedComponentLabeling method, 0 otherwise
    SCCL=0; % Int value: 1 if want to aply the SlidingConnectedComponentLabeling method, 0 otherwise
    SCCL_int=0;  % Int value: 1 if want to aply the SlidingConnectedComponentLabeling with integral Images method, 0 otherwise
elseif Method==2;
    CCL=0; % Int value: 1 if want to aply the ConnectedComponentLabeling method, 0 otherwise
    SCCL=1; % Int value: 1 if want to aply the SlidingConnectedComponentLabeling method, 0 otherwise
    SCCL_int=0;  % Int value: 1 if want to aply the SlidingConnectedComponentLabeling with integral Images method, 0 otherwise
elseif Method==3;
    CCL=0; % Int value: 1 if want to aply the ConnectedComponentLabeling method, 0 otherwise
    SCCL=0; % Int value: 1 if want to aply the SlidingConnectedComponentLabeling method, 0 otherwise
    SCCL_int=1;  % Int value: 1 if want to aply the SlidingConnectedComponentLabeling with integral Images method, 0 otherwise 
end
 
%% Reading the segmentation values
datfile=['segmentation_values.txt'];
fid=fopen(datfile,'rt');
segmentation_values=fscanf(fid,'%f');
fclose all;

%Means and Standards deviations of blue pixels from training signals.
b_pixel_r_mean=segmentation_values(1);
b_pixel_r_std=segmentation_values(2)*std;
b_pixel_g_mean=segmentation_values(3);
b_pixel_g_std=segmentation_values(4)*std;
b_pixel_b_mean=segmentation_values(5);
b_pixel_b_std=segmentation_values(6)*std;

%Means and Standards deviations of red pixels from training signals.
r_pixel_r_mean=segmentation_values(7);
r_pixel_r_std=segmentation_values(8)*std;
r_pixel_g_mean=segmentation_values(9);
r_pixel_g_std=segmentation_values(10)*std;
r_pixel_b_mean=segmentation_values(11);
r_pixel_b_std=segmentation_values(12)*std;

%Means and Standards deviations of the blue/red and blue/green ratios of blue pixels from training signals.
b_pixel_br_ratio_mean=segmentation_values(13);
b_pixel_br_ratio_std=segmentation_values(14)*std;
b_pixel_bg_ratio_mean=segmentation_values(15)*std;
b_pixel_bg_ratio_std=segmentation_values(16)*std;

%Means and Standards deviations of the red/green and red/blue ratios of red pixels from training signals.
r_pixel_rg_ratio_mean=segmentation_values(17);
r_pixel_rg_ratio_std=segmentation_values(18)*std;
r_pixel_rb_ratio_mean=segmentation_values(19);
r_pixel_rb_ratio_std=segmentation_values(20)*std;

%Means and Standards deviations of red pixels from training signals in H
%space.
b_pixel_H_mean=segmentation_values(21);
b_pixel_H_std=segmentation_values(22)*std;
r_pixel_H_mean=segmentation_values(27);
r_pixel_H_std=segmentation_values(28)*std;

%Means and Standards deviations of red pixels from training signals in CbCr
%space.
b_pixel_Cb_mean=segmentation_values(23);
b_pixel_Cb_std=segmentation_values(24)*std;
b_pixel_Cr_mean=segmentation_values(25);
b_pixel_Cr_std=segmentation_values(26)*std;

r_pixel_Cb_mean=segmentation_values(29);
r_pixel_Cb_std=segmentation_values(30)*std;
r_pixel_Cr_mean=segmentation_values(31);
r_pixel_Cr_std=segmentation_values(32)*std;

%Compute ratios
train_dataset = txt2cell('train_dataset.txt', 'columns', [3, 4, 7, 8]);
w = cell2vec(train_dataset(:,1)); w = [min(w), max(w)];
h = cell2vec(train_dataset(:,2)); h = [min(h), max(h)];    
ff = cell2vec(train_dataset(:,3)); ff=[min(ff), max(ff)]; %Form factor   
fr = cell2vec(train_dataset(:,4)); fr=[min(fr), max(fr)]; %Filling ratio


%% Classification of images searching those pixels that are between mean(+\-)std.
elapsed_time = [];
for i=1:size(files,1)

    im = imread(strcat(directory,'\',files(i).name)); 
    tic

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

%             technique=1;


        case 'CbCr'
           im_YCbCr=rgb2ycbcr(im);
           im_seg= ((im_YCbCr(:,:,2)>(b_pixel_Cb_mean-b_pixel_Cb_std)) & (im_YCbCr(:,:,2)<(b_pixel_Cb_mean+b_pixel_Cb_std))...
                & (im_YCbCr(:,:,3)>(b_pixel_Cr_mean-b_pixel_Cr_std)) & (im_YCbCr(:,:,3)<(b_pixel_Cr_mean+b_pixel_Cr_std)))...
                | ((im_YCbCr(:,:,2)>(r_pixel_Cb_mean-r_pixel_Cb_std)) & (im_YCbCr(:,:,2)<(r_pixel_Cb_mean+r_pixel_Cb_std))...
                & (im_YCbCr(:,:,3)>(r_pixel_Cr_mean-r_pixel_Cr_std)) & (im_YCbCr(:,:,3)<(r_pixel_Cr_mean+r_pixel_Cr_std)));

%             technique=2;


        case 'H'
           im_HSV=rgb2hsv(im);
           im_seg= ((im_HSV(:,:,1)>(b_pixel_H_mean-b_pixel_H_std)) & (im_HSV(:,:,1)<(b_pixel_H_mean+b_pixel_H_std)))...
                | ((im_HSV(:,:,1)>(r_pixel_H_mean-r_pixel_H_std)) & (im_HSV(:,:,1)<1))...
                | (im_HSV(:,:,1)<(r_pixel_H_mean+r_pixel_H_std-1));

%             technique=3;

            
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

%             technique=4;
          
        otherwise
            error('Incorrect color space defined');

    end
    
%   figure;
%   imshow(im)
if show
   figure;
   imshow(im_seg*255)
end
  if strcmp(morph_operator,'Yes')
    im_seg = apply_morph_operator(im_seg, 1);
    if show 
        figure;
        imshow(im_seg*255)
    end
  end
  
  if CCL
    CC=bwconncomp(im_seg);
    stats=regionprops(CC,'BoundingBox');
    BoundingBoxes=zeros(size(stats,1),4);
        for j=1:size(stats,1)
            BoundingBoxes(j,:)=round(stats(j).BoundingBox);
        end   
  elseif SCCL
      %im_seg = SlidingConnectedComponentLabeling(im_seg, 1);
      BoundingBoxes=SlidingConnectedComponentLabeling(im_seg,show);    %Proposo fer-ho així, on BoundingBoxes es una matriu on les columnes son [tly, tlx, w, h)
  elseif SCCL_int
      BoundingBoxes=SlidingConnectedComponentLabeling_int(im_seg,show);    %Proposo fer-ho així, on BoundingBoxes es una matriu on les columnes son [tly, tlx, w, h)
  end
  
  [im_seg,windowCandidates] = windowCand(im_seg, w, h, ff, fr, BoundingBoxes);
  if show
   figure;
   imshow(im_seg)
  end
      
   % Saving the segmented mask.
   if write_results

    imwrite(im_seg,strcat('results','\',files(i).name(1:9),'.png'));
    direc_save=strcat('results','\',files(i).name(1:9),'.mat');
    save(direc_save,'windowCandidates');
    clear im im_seg
   end
   elapsed_time(i) = toc;
end

disp('Average time per frame: ')
disp(mean(elapsed_time))

