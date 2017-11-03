function [bboxes] = merge_bboxes(candidate_X, candidate_Y, yxwh, show, im_seg)
% Function that merges overlapped clusters into one only cluster
    if size(candidate_X) == [0 0] |  size(yxwh) == [0 0]
        bboxes = [];
        return
    end
    if candidate_X ~= Inf & candidate_Y ~= Inf & yxwh == Inf
        yxwh = zeros(length(candidate_X(:,1)), 4);
        yxwh(:,1) = candidate_Y(:,1); yxwh(:,2) = candidate_X(:,1);
        yxwh(:,3) = candidate_Y(:,4)-candidate_Y(:,1);
        yxwh(:,4) = candidate_X(:,4)-candidate_X(:,1);
    end
    % Compute the overlap ratio
    overlapRatio = bboxOverlapRatio(yxwh, yxwh);

    % Set the overlap ratio between a bounding box and itself to zero to
    % simplify the graph representation.
    n = size(overlapRatio,1);
    overlapRatio(1:n+1:n^2) = 0;

    % Create the graph
    g = graph(overlapRatio);

    % Find the connected regions within the graph
    componentIndices = conncomp(g);
    % Merge the boxes based on the minimum and maximum dimensions.
    xmin = yxwh(:,2); ymin = yxwh(:,1);
    xmax = xmin + yxwh(:,4) -1;
    ymax = ymin + yxwh(:,3) -1;
    xmin = accumarray(componentIndices', xmin, [], @min);
    ymin = accumarray(componentIndices', ymin, [], @min);
    xmax = accumarray(componentIndices', xmax, [], @max);
    ymax = accumarray(componentIndices', ymax, [], @max);

    % Compose the merged bounding boxes using the [y x width height] format.
    bboxes = [ymin xmin ymax-ymin+1 xmax-xmin+1];
    numRegionsInGroup = histcounts(componentIndices);
    bboxes(numRegionsInGroup == 1, :) = [];
    if show
    % Show the final detection result.
    imshow(im_seg*255)
    hold on
        for k = 1 : length(xmax)
          rectangle('Position', [bboxes(k,1), bboxes(k,2),bboxes(k,3),bboxes(k,4)],...
          'EdgeColor','g','LineWidth',2 )
        end
    end
end