%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% TRAIN DATASET ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function extract_features(directory, plot_features)
%Function that reads training dataset and writes a file named "image_features.txt"
%by following the structure:
%    image_id signal_num w h bbox_area mask_area form_factor filling_ratio
%    and the signal coordinates pixelwise.
%Varargin "directory" refers to the path where your dataset is allocated.
%Optional varargin "plot_features" must be 1 if a visualization of the features
%per signal type is required. 
    
    if nargin < 2
       plot_features = 0; 
    end

    files = ListFiles(directory);
    features_file = fopen('image_features.txt', 'w');
    signal_counter = zeros(1,6);
    typeA = struct([]); typeB = struct([]); typeC = struct([]); 
    typeD = struct([]); typeE = struct([]); typeF = struct([]); 
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
            
            %Count how many signals are  in the dataset of each type and store  
            %features by signal type to later analyze them:      
            switch(type)
                case 'A'
                    signal_counter(1) = signal_counter(1) + 1;
                    typeA(signal_counter(1)).id = image_id;
                    typeA(signal_counter(1)).signal_size = mask_area;
                    typeA(signal_counter(1)).form_factor = form_factor;
                    typeA(signal_counter(1)).filling_ratio = filling_ratio;
                case 'B'
                    signal_counter(2) = signal_counter(2) + 1;
                    typeB(signal_counter(2)).id = image_id;
                    typeB(signal_counter(2)).signal_size = mask_area;
                    typeB(signal_counter(2)).form_factor = form_factor;
                    typeB(signal_counter(2)).filling_ratio = filling_ratio;
                case 'C'
                    signal_counter(3) = signal_counter(3) + 1;
                    typeC(signal_counter(3)).id = image_id;
                    typeC(signal_counter(3)).signal_size = mask_area;
                    typeC(signal_counter(3)).form_factor = form_factor;
                    typeC(signal_counter(3)).filling_ratio = filling_ratio;
                case 'D'
                    signal_counter(4) = signal_counter(4) + 1;
                    typeD(signal_counter(4)).id = image_id;
                    typeD(signal_counter(4)).signal_size = mask_area;
                    typeD(signal_counter(4)).form_factor = form_factor;
                    typeD(signal_counter(4)).filling_ratio = filling_ratio;
                case 'E'
                    signal_counter(5) = signal_counter(5) + 1;
                    typeE(signal_counter(5)).id = image_id;
                    typeE(signal_counter(5)).signal_size = mask_area;
                    typeE(signal_counter(5)).form_factor = form_factor;
                    typeE(signal_counter(5)).filling_ratio = filling_ratio;
                otherwise
                    signal_counter(6) = signal_counter(6) + 1;
                    typeF(signal_counter(6)).id = image_id;
                    typeF(signal_counter(6)).signal_size = mask_area;
                    typeF(signal_counter(6)).form_factor = form_factor;
                    typeF(signal_counter(6)).filling_ratio = filling_ratio;
            end
            
            %Write output files
            fprintf(features_file,'%s\t%d\t%d\t%d\t%d\t%d\t%f\t%f\t%d\t%d\t%d\t%d\t%c\n',...
                image_id, signal, w, h, bbox_area, mask_area, form_factor, filling_ratio, ...
                tly, tlx, bly, blx,type);
        end
    end
    fclose(features_file);
    
    %Compute and save statistics per signal type: max and min size, mean
    %form factor, mean filling ratio and frequency of appearance:
    total_signals = sum(signal_counter);
    statsA = [min([typeA.signal_size]), max([typeA.signal_size]), mean([typeA.form_factor]), ...
        mean([typeA.filling_ratio]), signal_counter(1)/total_signals];
    statsB = [min([typeB.signal_size]), max([typeB.signal_size]), mean([typeB.form_factor]), ...
        mean([typeB.filling_ratio]), signal_counter(2)/total_signals];
    statsC = [min([typeC.signal_size]), max([typeC.signal_size]), mean([typeC.form_factor]), ...
        mean([typeC.filling_ratio]), signal_counter(3)/total_signals];
    statsD = [min([typeD.signal_size]), max([typeD.signal_size]), mean([typeD.form_factor]), ...
        mean([typeD.filling_ratio]), signal_counter(4)/total_signals];
    statsE = [min([typeE.signal_size]), max([typeE.signal_size]), mean([typeE.form_factor]), ...
        mean([typeE.filling_ratio]), signal_counter(5)/total_signals];
    statsF = [min([typeF.signal_size]), max([typeF.signal_size]), mean([typeF.form_factor]), ...
        mean([typeF.filling_ratio]), signal_counter(6)/total_signals];
    stats = [statsA; statsB; statsC; statsD; statsE; statsF]; %store them in a matrix
    
    dlmwrite('dataset_analysis.txt', stats, 'delimiter', '\t') %Write data into a textfile
    
    %TODO: Plot features per signal type if required.

end
