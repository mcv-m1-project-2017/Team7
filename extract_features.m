%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% TRAIN DATASET ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function extract_features(directory)
%Function that reads training dataset and writes a file named "features.txt"
%by following the structure:
%    image_id signal_num w h bbox_area mask_area form_factor filling_ratio
%Output file "px_coordinates.txt" with the signal coordinates in pixelwise.
%Varargin "directory" refers to the path where your dataset is allocated.

    files = ListFiles(directory);
    features_file = fopen('train_features.txt', 'w');
    px_coordinates = fopen('px_coordinates.txt', 'w');

    for i=1:size(files,1)
        image_id = files(i).name(1:size(files(i).name,2)-4);
        mask = imread(strcat(directory, '/mask/mask.', image_id, '.png'));
        gt=textscan(fopen(strcat(directory, '/gt/gt.', image_id, ...
            '.txt'), 'rt'),'%f %f %f %f %c');

        for signal=1:size(gt{1},1)
            %Read mask coordinates from gt and check if they are valid
            tly = floor(gt{1}(signal)); if tly==0, tly = 1; end
            tlx = floor(gt{2}(signal)); if tlx==0, tlx = 1; end
            bly = floor(gt{3}(signal)); if bly==0, bly = 1; end
            blx = floor(gt{4}(signal)); if blx==0, blx = 1; end
            type = gt{5}(signal);

            %Compute signal features
            w = blx-tlx+1; h = bly-tly+1;
            bbox_area = w*h;
            mask_area = sum(sum(mask(tly:bly,tlx:blx)));
            form_factor = w/h;
            filling_ratio = mask_area/bbox_area;

            %Write output files
            fprintf(px_coordinates,'%s\t%d\t%d\t%d\t%d\t%c\n',image_id, tly, tlx, bly, blx,type);
            fprintf(features_file,'%s\t%d\t%d\t%d\t%d\t%d\t%f\t%f\n', ...
                image_id, signal, w, h, bbox_area, mask_area, ...
                form_factor, filling_ratio);
        end
    end
    fclose(features_file);
    fclose(px_coordinates);
end

