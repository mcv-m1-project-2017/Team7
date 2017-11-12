function [final_mask, WindowCandidates] = CCL_filtering(final_mask, features)

labels = bwlabel(final_mask);
CC = regionprops(labels,'Area','BoundingBox','FilledArea','Perimeter','ConvexArea','Perimeter'); 

t = 1.5;

mean_size_t = mean(features.size.mean(1:2));
mean_size_c = mean(features.size.mean(3:5));
mean_size_s = features.size.mean(6);

mean_form_t = mean(features.form_factor.mean(1:2));
mean_form_c = mean(features.form_factor.mean(3:5));
mean_form_s = features.form_factor.mean(6);

mean_fill_t = mean(features.filling_ratio.mean(1:2));
mean_fill_c = mean(features.filling_ratio.mean(3:5));
mean_fill_s = features.filling_ratio.mean(6);

mean_conv_t = mean(features.convex_ratio.mean(1:2));
mean_conv_c = mean(features.convex_ratio.mean(3:5));
mean_conv_s = features.convex_ratio.mean(6);

std_size_t = mean(features.size.std(1:2));
std_size_c = mean(features.size.std(3:5));
std_size_s = features.size.std(6);

std_form_t = mean(features.form_factor.std(1:2));
std_form_c = mean(features.form_factor.std(3:5));
std_form_s = features.form_factor.std(6);

std_fill_t = mean(features.filling_ratio.std(3:5));
std_fill_c = mean(features.filling_ratio.std(3:5));
std_fill_s = features.filling_ratio.std(6);

std_conv_t = mean(features.convex_ratio.std(3:5));
std_conv_c = mean(features.convex_ratio.std(3:5));
std_conv_s = features.convex_ratio.std(6);

% extract properties of each connected component
WindowCandidates = [];
for j = 1:length(CC)   

    bbox = CC(j).BoundingBox;    %expressed [x , y , width , height]
    bbox_area = bbox(3)*bbox(4);
    form_factor = bbox(3)/bbox(4);
    signal_size = CC(j).Area;
    fill_ratio = signal_size/bbox_area;
    convex_ratio = CC(j).ConvexArea/bbox_area;

    
    % Filter
    if ( form_factor>= 0.5 && form_factor<= 1.2 )  ...
         && ( signal_size >= min(features.size.min) && signal_size <= max(features.size.max)) ...
         && ( bbox_area >= 900 && bbox_area <= 56000)
                % then it is a signal candidate
                bbox_signal = struct('x',bbox(1),'y',bbox(2),'w',bbox(3),'h',bbox(4));
                WindowCandidates = [WindowCandidates, bbox_signal];
    else
        labels(labels==j) = 0;   
    end

end
final_mask = labels>0;

end
