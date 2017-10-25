function [bboxes] = merge_bboxes(candidate_X, candidate_Y, show, im_seg)
% Function that merges overlapped clusters into one only cluster

    % Compute the overlap ratio
    overlapRatio = bboxOverlapRatio([candidate_Y(:,1) candidate_X(:,1) candidate_Y(:,4)-candidate_Y(:,1), candidate_X(:,4)-candidate_X(:,1)],...
        [candidate_Y(:,1) candidate_X(:,1) candidate_Y(:,4)-candidate_Y(:,1), candidate_X(:,4)-candidate_X(:,1)]);

    % Set the overlap ratio between a bounding box and itself to zero to
    % simplify the graph representation.
    n = size(overlapRatio,1);
    overlapRatio(1:n+1:n^2) = 0;

    % Create the graph
    g = graph(overlapRatio);

    % Find the connected regions within the graph
    componentIndices = conncomp(g);
    % Merge the boxes based on the minimum and maximum dimensions.
    xmin = accumarray(componentIndices', candidate_X(:,1), [], @min);
    ymin = accumarray(componentIndices', candidate_Y(:,1), [], @min);
    xmax = accumarray(componentIndices', candidate_X(:,4), [], @max);
    ymax = accumarray(componentIndices', candidate_Y(:,4), [], @max);

    % Compose the merged bounding boxes using the [x y width height] format.
    bboxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
    numRegionsInGroup = histcounts(componentIndices);
    bboxes(numRegionsInGroup == 1, :) = [];

    % Show the final text detection result.
    imshow(im_seg*255)
    hold on
    if show
        for k = 1 : length(xmax)
          rectangle('Position', [bboxes(k,2), bboxes(k,1),bboxes(k,4),bboxes(k,3)],...
          'EdgeColor','g','LineWidth',2 )
        end
    end
end