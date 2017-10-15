function [perceptual_info] = BackProjectionTrain(directory, bins)
    % BackProjectionTrain
    % Function to train a signal segmentation system based on histogram 
    % back-projection. The method generates 2D histograms from HSV channels
    % for each signal group, focused on blue and red areas.
    %
    %   function [G1,G2,G3] = BackProjectionTrain(directory, bins)
    %
    %    Parameter name      Value
    %    --------------      -----
    %    'directory'         Training samples directory
    %    'bins'              Histogram bins
    %
    % The function returns the perceptual information from each group.
    % perceptual_info = {G1, G2, G3} being 'Gx' a struct to index the 2D
    % perceptual histogram between Hue and Saturation components.
    
    train_dataset = textscan(fopen('train_dataset.txt','rt'),'%s');
    px_coordinates = textscan(fopen('px_coordinates.txt', 'rt'), ...
        '%s\t%d\t%d\t%d\t%d\t%c\n');

    g1 = 'ABC'; g2 = 'DF'; g3 = 'E';
    g1_signals = []; g2_signals = []; g3_signals = [];

    for i=1:size(train_dataset{1},1)

        file_id=train_dataset{1}(i);
        im = imread(strcat(directory,'/',file_id{1},'.jpg'));
        im_hsv = rgb2hsv(im);
        
        %filter red and blue pixels
        r_pixels=(im(:,:,2)*1.2<im(:,:,1) & im(:,:,3)*1.2<im(:,:,1));
        b_pixels=(im(:,:,1)*1.2<im(:,:,3) & im(:,:,2)*1.2<im(:,:,3));
        
        %Find ground truth information for file_id
        pos = find(strcmp(px_coordinates{1},file_id{1}));
        
        for j=1:length(pos)
            
            coordinates = {px_coordinates{2}(pos(j)), px_coordinates{3}(pos(j)), ...
            px_coordinates{4}(pos(j)), px_coordinates{5}(pos(j)), px_coordinates{6}(pos(j))};
        
            mask = r_pixels(coordinates{1}:coordinates{3},coordinates{2}:coordinates{4})...
                | b_pixels(coordinates{1}:coordinates{3},coordinates{2}:coordinates{4});
            mask = reshape(mask,[size(mask,1)*size(mask,2),1]);
            
            pixels_h = im_hsv(coordinates{1}:coordinates{3},coordinates{2}:coordinates{4},1);
            pixels_h = reshape(pixels_h,[size(pixels_h,1)*size(pixels_h,2),1]);
            pixels_h = pixels_h(mask==1);
            
            pixels_s = im_hsv(coordinates{1}:coordinates{3},coordinates{2}:coordinates{4},2);
            pixels_s = reshape(pixels_s,[size(pixels_s,1)*size(pixels_s,2),1]);
            pixels_s = pixels_s(mask==1);

            if ~isempty(strfind(g1, coordinates{5}))
                %group 1 signals: red
                g1_signals = [g1_signals;[pixels_h, pixels_s]];

            elseif ~isempty(strfind(g2, coordinates{5}))
                %group 2 signals: blue
                g2_signals = [g2_signals;[pixels_h, pixels_s]];
                
            elseif ~isempty(strfind(g3, coordinates{5}))
                %group 3 signals: red & blue
                g3_signals = [g3_signals;[pixels_h, pixels_s]];

            end
            
        end
        
    end
    clear im im_hsv pixels_r pixels_g pixels_b
    
    %Compute 2D histograms per signal group
    fig=figure; set(fig,'visible','off');
    
    H1=histogram2(g1_signals(:,1), g1_signals(:,2), bins);
    G1.Values = H1.Values; G1.XBinEdges = H1.XBinEdges; G1.YBinEdges = H1.YBinEdges;
    G1.N = size(g1_signals, 1);
    
    H2=histogram2(g2_signals(:,1), g2_signals(:,2), bins);
    G2.Values = H2.Values; G2.XBinEdges = H2.XBinEdges; G2.YBinEdges = H2.YBinEdges;
    G2.N = size(g2_signals, 1);
    
    H3=histogram2(g3_signals(:,1), g3_signals(:,2), bins);
    G3.Values = H3.Values; G3.XBinEdges = H3.XBinEdges; G3.YBinEdges = H3.YBinEdges;
    G3.N = size(g3_signals, 1);
    
    perceptual_info = {G1, G2, G3};
    close(fig);

end