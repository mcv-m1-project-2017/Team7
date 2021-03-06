
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CandidateGeneration - Week4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%    
clear
clc 
addpath('evaluation');
directory='C:\Users\Fran\Documents\MATLAB\train'; %directori of the images that we whant to mask
directory_train='C:\Users\Fran\Documents\MATLAB\train'; %directori of the mask's (for the evaluation
directory_results='C:\Users\Fran\Documents\MATLAB\Team7-master\results'; %directori where the results are saved

method=2; %Int value: 1 if want to aply method 1
show=0; % Int value: 1 if want to show the results, 0 otherwise
write_results = 1; % Int value: 1 if want to save generated masks, 0 otherwise
eval_results=1; % Int value: 1 if want evaluate the results, 0 if not


files = ListFiles(directory);
evaluation = zeros(size(files,1),4);
evaluation2=zeros(20,5);
wTP=zeros(size(files,1));
wFN=zeros(size(files,1));
wFP=zeros(size(files,1));
if method==1
    space='HS2';  %'seg_type' string that can be 'RGB' 'CbCr', 'H', 'HorCbCr' or 'HandCbCr', indicating which color channels are used in the segmentation
    morph_operator='Yes'; %'morph_operator' string that can be 'Yes','No', indicating if morphological operators are used
    CCL=1; % Int value: 1 if want to apply the ConnectedComponentLabeling method, 0 otherwise
    CCL_team3=0;
    TM = 0; % Int value: 1 if you want to apply the corr_template_matching method, 0 otherwise
    CW = 0; % Int value: 1 if you want to apply the compare_window method, 0 otherwise
    CTM = 1; % Int value: 1 if you want to apply the chanfer_template_matching, 0 otherwise
    method_morph=4; 
    windMethod=2;
    segmentation = 'color'; % 'color' or 'mean-shift'
    
    stdr=1.3; %standard deviation increase
    cw_thresh = 0.25; % Double value: Threshold to apply to the correlation template matching in order to compare candidate windows. Between 0 and 1.
    crosscorr_thresh = 0.7; % Double value: Threshold to apply to the cross-correlation template matching method
    chanfer_th = 14200; % Int value: Threshold to apply to the chanfer_template_matching method
end

if method==2
    space='HS2';  %'seg_type' string that can be 'RGB' 'CbCr', 'H', 'HorCbCr' or 'HandCbCr', indicating which color channels are used in the segmentation
    morph_operator='Yes'; %'morph_operator' string that can be 'Yes','No', indicating if morphological operators are used
    CCL=1; % Int value: 1 if want to apply the ConnectedComponentLabeling method, 0 otherwise
    TM = 0; % Int value: 1 if you want to apply the corr_template_matching method, 0 otherwise
    CW = 0; % Int value: 1 if you want to apply the compare_window method, 0 otherwise
    CTM = 1; % Int value: 1 if you want to apply the chanfer_template_matching, 0 otherwise
    method_morph=4; 
    windMethod=2;
    segmentation = 'mean-shift'; % 'color' or 'mean-shift'
    
    stdr=1.8; %standard deviation increase
    cw_thresh = 0.25; % Double value: Threshold to apply to the correlation template matching in order to compare candidate windows. Between 0 and 1.
    crosscorr_thresh = 0.7; % Double value: Threshold to apply to the cross-correlation template matching method
    chanfer_th = 13750; % Int value: Threshold to apply to the chanfer_template_matching method
end

%% Reading the segmentation values
datfile=['segmentation_values.txt'];
fid=fopen(datfile,'rt');
segmentation_values=fscanf(fid,'%f');
fclose all;

%% Extract chanfer template matching templates
if CTM
    chanfer_templates = chanfer_extract_templates(show);
end

%Compute ratios for window candidates
train_dataset = txt2cell('train_dataset.txt', 'columns', [3, 4, 7, 8]);
w_train = cell2vec(train_dataset(:,1)); w = [min(w_train), max(w_train), mean(w_train), std(w_train)]; 
h_train = cell2vec(train_dataset(:,2)); h = [min(h_train), max(h_train), mean(h_train), std(h_train)];
ff = cell2vec(train_dataset(:,3)); ff=[min(ff), max(ff), mean(ff), std(ff)]; %Form factor   
fr = cell2vec(train_dataset(:,4)); fr=[min(fr), max(fr), mean(fr), std(fr)]; %Filling ratio


%% Classification of images searching those pixels that are between mean(+\-)stdr.
elapsed_time = [];

for i=1:size(files,1)

    im = imread(strcat(directory,'\',files(i).name)); 
    tic

%Color Segmentation:
    if strcmp(segmentation, 'color')
        im_seg=color_segmentation_v2(im,space,segmentation_values,stdr);
    elseif strcmp(segmentation, 'mean-shift')
        im_seg = mean_shift_segmentation(im, 1/4, space, segmentation_values, stdr, show);
    else
        error('Not a valid segmentation method');
        break
    end
    
    if show
       figure;
       imshow(im)
       figure;
       imshow(im_seg*255)
    end

%Morphological operators:
    if strcmp(morph_operator,'Yes')
        im_seg = apply_morph_operator_v2(im_seg, method_morph);
        if show 
            figure;
            imshow(im_seg*255)
        end
    end

%Connected Component Labeling:    
    if CCL
        CC=bwconncomp(im_seg);
        stats=regionprops(CC,'BoundingBox');
        BoundingBoxes=zeros(size(stats,1),4);
            for j=1:size(stats,1)
                BoundingBoxes(j,:)=round(stats(j).BoundingBox);
            end
        [im_seg,windowCandidates] = windowCand_v2(im_seg, w, h, ff, fr, BoundingBoxes,windMethod);
    end

%Template Matching:     
    if TM
          BoundingBoxes = corr_template_matching(im, im_seg, crosscorr_thresh, show);  %BoundingBoxes = [tly, tlx, w, h)
          [im_seg,windowCandidates] = windowCand_v2(im_seg, w, h, ff, fr, BoundingBoxes,windMethod);
          windowCandidates = compare_windows(im, im_seg, windowCandidates, cw_thresh); %Verify candidates using correlation template matching
    end

    
    %Hough transform
    if HG
            [windowCandidates] = Hough_Segment(im,im_seg);
    end
 
     if CW
          [im_seg,windowCandidates] = compare_windows(im, im_seg, windowCandidates, cw_thresh); %Verify candidates using correlation template matching
     end
    
  if show
   figure;
   imshow(im_seg)
  end
  
% Saving the segmented mask.
   if write_results
    imwrite(im_seg,strcat(directory_results, '\method', num2str(method),'\',files(i).name(1:9),'.png'));
        if CCL | HG
            direc_save=strcat(directory_results, '\method', num2str(method),'\',files(i).name(1:9),'.mat');
            save(direc_save,'windowCandidates');
        end
   end
   elapsed_time= toc;
   
   %% Evaluation
    if eval_results
        %Pixel evaluation
       gt = imread(strcat(directory_train, '\mask\mask.', files(i).name(1:9), '.png'));
       [pixelTP, pixelFP, pixelFN, pixelTN] = PerformanceAccumulationPixel(im_seg, gt);
       [pixelPrecision, pixelRecall, pixelF1] = PerformanceEvaluationPixel_v2(pixelTP, pixelFP, pixelFN, pixelTN);
       evaluation(i,:) =[pixelPrecision, pixelRecall, pixelF1, elapsed_time];

       %Window evaluation
       if CCL||TM || HG
            bbox_gt = txt2cell(strcat(directory_train, '\gt\gt.', files(i).name(1:9),'.txt'), 'columns', 1:4);
            annotations = [];            
            for k=1:size(bbox_gt,1)
               annotation.y = floor(str2num(cell2mat(bbox_gt(k,1))));
               annotation.x = floor(str2num(cell2mat(bbox_gt(k,2))));
               annotation.w = floor(str2num(cell2mat(bbox_gt(k,4)))) - floor(str2num(cell2mat(bbox_gt(k,2))))+1;
               annotation.h = floor(str2num(cell2mat(bbox_gt(k,3)))) - floor(str2num(cell2mat(bbox_gt(k,1))))+1; 
               annotations = [annotations; annotation];
            end
            [wTP(i),wFN(i),wFP(i)] = PerformanceAccumulationWindow(windowCandidates, annotations);
       
        end
              
    end
   
   clear im im_seg
end


%% Evaluation
    
    %Evaluation results file
    if eval_results    
        eval_file = fopen('eval_results.txt', 'a+');
        tech_eval = mean(evaluation);
        if CCL||TM
                [precision, recall, F1] = PerformanceEvaluationWindow_v2(sum(sum(wTP)), sum(sum(wFN)), sum(sum(wFP)));
                tech_eval=cat(2,tech_eval,[precision, recall, F1]);
                fprintf(eval_file, '%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', method, tech_eval(1),tech_eval(2),tech_eval(3), tech_eval(5),tech_eval(6),tech_eval(7),tech_eval(4));
                fclose(eval_file);
                disp('Evaluation (method,pixelPrecision, pixelRecall, pixelF1,windPrecision, windRecall, windF1,Time/frame)')
                disp([method,tech_eval(1:3),tech_eval(5:7),tech_eval(4)]) 
        else
        fprintf(eval_file, '%d\t%f\t%f\t%f\t%f\n', method, tech_eval(1),tech_eval(2),tech_eval(3),tech_eval(4));
        fclose(eval_file);    
        disp('Evaluation (method,pixelPrecision, pixelRecall, pixelF1,Time/frame)')
        disp([method,tech_eval(1:3),tech_eval(4)])       
        end
        
   
    end


 %   evaluation2(uint8(stdr*10-10+1),:) =[stdr,tech_eval];


