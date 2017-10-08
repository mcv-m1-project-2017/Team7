
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandidateGeneration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CandidateGenerationPixel_Color(files,directory,space)

%%    




 
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

%% Classification of images searching those pixels that are between mean(+\-)std.
 
switch space
  case 'normrgb'
        
    for i=1:size(files,1)

         im = imread(strcat(directory,'\',files(i).name));
         %      [signal_size, form_factor, filling_ratio, type] = extract_features(directory, files, i)

        %technique 1: The threshold is done with the mean(+\-)std of colors rgb of blue and red
        %pixels from the training dataset.
        im_seg_1=((im(:,:,1)>(b_pixel_r_mean-b_pixel_r_std)) & (im(:,:,1)<(b_pixel_r_mean+b_pixel_r_std))...
            & (im(:,:,2)>(b_pixel_g_mean-b_pixel_g_std)) & (im(:,:,2)<(b_pixel_g_mean+b_pixel_g_std))...
            & (im(:,:,3)>(b_pixel_b_mean-b_pixel_b_std)) & (im(:,:,3)<(b_pixel_b_mean+b_pixel_b_std)))...
            | ((im(:,:,1)>(r_pixel_r_mean-r_pixel_r_std)) & (im(:,:,1)<(r_pixel_r_mean+r_pixel_r_std))...
            & (im(:,:,2)>(r_pixel_g_mean-r_pixel_g_std)) & (im(:,:,2)<(r_pixel_g_mean+r_pixel_g_std))...
            & (im(:,:,3)>(r_pixel_b_mean-r_pixel_b_std)) & (im(:,:,3)<(r_pixel_b_mean+r_pixel_b_std)));


        %technique 2: The threshold is done with the mean(+\-)std of rgb ratios of blue and red
        %pixels from the training dataset.
        im_seg_2=((double(im(:,:,3))./double(im(:,:,1))>(b_pixel_br_ratio_mean-b_pixel_br_ratio_std))...
            & (double(im(:,:,3))./double(im(:,:,1))<(b_pixel_br_ratio_mean+b_pixel_br_ratio_std))...
            & (double(im(:,:,3))./double(im(:,:,2))>(b_pixel_bg_ratio_mean-b_pixel_bg_ratio_std))...
            & (double(im(:,:,3))./double(im(:,:,2))<(b_pixel_bg_ratio_mean+b_pixel_bg_ratio_std)))...
            | ((double(im(:,:,1))./double(im(:,:,2))>(r_pixel_rg_ratio_mean-r_pixel_rg_ratio_std))...
            & (double(im(:,:,1))./double(im(:,:,2))<(r_pixel_rg_ratio_mean+r_pixel_rg_ratio_std))...
            & (double(im(:,:,1))./double(im(:,:,3))>(r_pixel_rb_ratio_mean-r_pixel_rb_ratio_std))...
            & (double(im(:,:,3))./double(im(:,:,1))<(r_pixel_rb_ratio_mean+r_pixel_rb_ratio_std)));

        %technique 3: Both techniques 1 and 2 are added
        im_seg_3=((double(im(:,:,3))./double(im(:,:,1))>(b_pixel_br_ratio_mean-b_pixel_br_ratio_std))...
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

        % Saving the segmented mask using each technique.
        imwrite(im_seg_1,strcat('candidate_mask\mask.01.',files(i).name(1:9),'.png'));
        imwrite(im_seg_2,strcat('candidate_mask\mask.02.',files(i).name(1:9),'.png'));
        imwrite(im_seg_3,strcat('candidate_mask\mask.03.',files(i).name(1:9),'.png'));

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

        % Candidate Generation (window)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % windowCandidates = CandidateGenerationWindow_Example(im, pixelCandidates, window_method); %%'SegmentationCCL' or 'SlidingWindow'  (Needed after Week 3)

                % Accumulate pixel performance of the current image %%%%%%%%%%%%%%%%%
        %         pixelAnnotation = imread(strcat(directory, '/mask/mask.', files(i).name(1:size(files(i).name,2)-3), 'png'))>0;
        %         [localPixelTP, localPixelFP, localPixelFN, localPixelTN] = PerformanceAccumulationPixel(pixelCandidates, pixelAnnotation);
        %         pixelTP = pixelTP + localPixelTP;
        %         pixelFP = pixelFP + localPixelFP;
        %         pixelFN = pixelFN + localPixelFN;
        %         pixelTN = pixelTN + localPixelTN;

                % Accumulate object performance of the current image %%%%%%%%%%%%%%%%  (Needed after Week 3)
                % windowAnnotations = LoadAnnotations(strcat(directory, '/gt/gt.', files(i).name(1:size(files(i).name,2)-3), 'txt'));
                % [localWindowTP, localWindowFN, localWindowFP] = PerformanceAccumulationWindow(windowCandidates, windowAnnotations);
                % windowTP = windowTP + localWindowTP;
                % windowFN = windowFN + localWindowFN;
                % windowFP = windowFP + localWindowFP;

                clear im im_seg_1 im_seg_2 im_seg_3
    end
    
 otherwise
      error('Incorrect color space defined');
      return
 end

end
