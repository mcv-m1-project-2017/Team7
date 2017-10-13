function BackProjectionSegmentation(input, output, perceptual_info, alfa)
    % BackProjectionSegmentation
    % Function to segment the input signals using percetual information.
    % All the masks are saved at output path.
    %
    %   BackProjectionSegmentation(input, output, perceptual_info)
    %
    %    Parameter name      Value
    %    --------------      -----
    %    'input'             Input path
    %    'output'            Output path
    %    'perceptual_info'   Cell containing the perceptual information
    %    'alfa'              Probability threshold for mask generation
    
    if 7~=exist(output,'dir'), mkdir(output); end
    val_dataset = textscan(fopen('val_dataset.txt','rt'),'%s');
    
    for i=1:size(val_dataset{1},1)
        
        file_id=val_dataset{1}(i);
        img = rgb2hsv(imread(strcat(input,'/',file_id{1},'.jpg')));
        
        mask = GenerateMask(img(:,:,1), img(:,:,2), perceptual_info{1}, alfa)| ...
               GenerateMask(img(:,:,1), img(:,:,2), perceptual_info{2}, alfa)| ...
               GenerateMask(img(:,:,1), img(:,:,2), perceptual_info{3}, alfa);
        
        imwrite(mask, strcat(output, '/', file_id{1},'.jpg'));
        
        
    end
end


function binary_mask = GenerateMask(X, Y, H, alfa)
    % GenerateMask
    % Function to generate the segmentation mask of X and Y perceptual
    % information, based on 2D structured histogram.
    %
    %   mask = GenerateMask(X, Y, H, alfa)
    %
    %    Parameter name      Value
    %    --------------      -----
    %    'X'                 Hue target channel
    %    'Y'                 Saturation target channel
    %    'H'                 Struct of 2D histogram information
    %    'alfa'              Probability threshold
    %
    % The function returns a binary mask for the 'H' signal group info.
    
    rootX = H.XBinEdges(2)-H.XBinEdges(1);
    rootY = H.YBinEdges(2)-H.YBinEdges(1);
    bins = length(H.XBinEdges)-1;
    X = floor((X-H.XBinEdges(1))/rootX)+1; Y = floor((Y-H.YBinEdges(1))/rootY)+1;

    thresh = (max(max(H.Values/H.N))-mean(mean((H.Values/H.N))))*alfa;
    
    map = zeros(bins,bins);
    map((H.Values/H.N)>thresh) = 1;

    binary_mask = zeros(size(X));
    for x=1:bins
        for y=1:bins
            if(map(x,y)~=0)
                binary_mask(X==x & Y==y) = 1;
            end
        end
    end   
end 