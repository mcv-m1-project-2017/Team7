function [windowCandidates] = Hough_Segment(im_seg,pixelCandidates)

plotting=false;

if plotting
end

% Extract contours
pc_edges = bwperim(pixelCandidates, 8);

% Dilate contour
se = [0 0 0 1 0 0 0; 0 1 1 1 1 1 0; 0 1 1 1 1 1 0; 1 1 1 1 1 1 1; 0 1 1 1 1 1 0; 0 1 1 1 1 1 0; 0 0 0 1 0 0 0];

%se=strel('disk',3);
pc_edges=imdilate(pc_edges,se);

if plotting
    subplot(2,3,1)
    imshow(pixelCandidates)
    title('Input mask')
end
pc_edges=bwmorph(pc_edges,'thin','Inf');

%% Standard Hough Transform
%hough transform
[H, theta,rho]=hough(pc_edges);

%calculate peaks in HT
P  = houghpeaks(H,25,'threshold',ceil(0.5*max(H(:))));

%exract lines from HT and its peaks
lines = houghlines(pc_edges, theta, rho, P, 'FillGap', 60, 'MinLength', 10);
thetas=[];
rhos=[];

if plotting
    
    subplot(2,3,2)
    imshow(pc_edges)
    title('Contour image')
    subplot(2,3,3), imshow(pc_edges), hold on
    for k = 1:length(lines)
        thetas=[thetas lines(k).theta];
        rhos=[rhos lines(k).rho];
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        
    end
    
    hold off
    title('Detected hough segments')
    
end

%% Circular Hough Transform
% Split in two Hough transforms not to cover a too broad radii range in a
% single call.
%[accum, circen_1, cirrad_1] = CircularHough_Grd(pixelCandidates, [20 70], 10, 60);
%[accum, circen_2, cirrad_2] = CircularHough_Grd(pixelCandidates, [71 120], 10, 60);
%circen_2=[];
%cirrad_2=[];

[circen_1, cirrad_1] = imfindcircles(pixelCandidates, [15, 40], 'Sensitivity', 0.85, 'EdgeThreshold', 0.5);
[circen_2, cirrad_2] = imfindcircles(pixelCandidates, [41, 100], 'Sensitivity', 0.85, 'EdgeThreshold', 0.5);

%% Hough triangle and rectangle heuristics
if(~isempty(lines))
    %cell with different detected shapes. Every shape is a vector with vector
    %'lines' positions
    shapes={};
    j=1;
    %vector with 'lines' indexes where a single shape is formed
    shape=[];
    %pool vector is the lines vector positions where a shape has not been
    %assigned yet. Initialized with all the positions.
    pool=1:length(lines);
    
    %segment index to analyse. Initialized with the first index in 'pool'.
    if ~isempty(pool)
        ind=pool(1);
    end
    %initialized 'end_seg' as point2
    end_seg=2;
    while (~isempty(pool)) %while pool still has candidates without assignment to a shape
        %theta angle as reference to compare further segments.
        ref_theta=lines(ind).theta;
        %always store current index in a shape. If further segments are in no
        %relation, it will be a shape with just one segment and,
        %therefore,discarded.
        shape=[shape ind];
        
        %find closest segment ('lines' index) to target segment 'ind'
        [closest_ind,end_seg_]=findClosestPoint(lines,pool,ind,end_seg); %-1 if no close segments
        %theta diference between current index candidate and closest index
        if(end_seg_~=0)
            end_seg=end_seg_;
        else
            end_seg=2;
        end
        
        %if a close segment fits triangle heuristics, erase previous segment 'ind'
        %from pool.
        pool(find(pool==ind))=[];
        
        if closest_ind~=-1
            theta_diff=abs(ref_theta-lines(closest_ind).theta);
            
            if(theta_diff<10  || (theta_diff<95 && theta_diff>20))
                %take next ind as closest_ind
                ind=closest_ind;
            else
                %finish the current shape and store it in 'shapes' cell.
                shapes{j}=shape;
                j=j+1;
                %restart 'shape'
                shape=[];
                %if the closest segment doesn't fit in the triangle heuristics, take
                %next segment to consider as the first one in the pool
                if (~isempty(pool))
                    ind=pool(1);
                end
            end
        else %if there is no close segment or the closest segment does not belong to the shape's heuristics
            %finish the current shape and store it in 'shapes' cell.
            shapes{j}=shape;
            j=j+1;
            %restart 'shape'
            shape=[];
            %if the closest segment doesn't fit in the triangle heuristics, take
            %next segment to consider as the first one in the pool
            if (~isempty(pool))
                ind=pool(1);
            end
        end
        
        %eliminate shapes without at least 3 segments
        def_shapes={};
        i=1;
        for s=1:length(shapes)
            shape_=shapes{s};
            if(length(shape_)>2)
                def_shapes{i}=shapes{s};
                i=i+1;
            end
        end
    end
    if plotting
        disp(['Num shapes before filter shape ' int2str(length(def_shapes))]);
    end
    def_shapes_={};
    k=1;
    
    for i=1:length(def_shapes)
        shape=def_shapes{i};
        if plotting
            disp(['shape num' int2str(i)]);
        end
        min_angle=1800;
        max_angle=-1800;
        for j=1:length(shape)
            if lines(shape(j)).theta<min_angle
                min_angle=lines(shape(j)).theta;
            end
            if lines(shape(j)).theta> max_angle
                max_angle=lines(shape(j)).theta;
            end
        end
        max_diff=abs(max_angle-min_angle);
        if max_diff>25 %then the shape is not a straight line, keep shape
            def_shapes_{k}=shape;
            k=k+1;
        end
    end
    
    
    %% HOUGH rectangle and triangle bounding boxes
    
    % Get BB from shape (triangle and square heuristics)
    windowCandidates=[];
    for i=1:length(def_shapes_)
        bb=getBoundingBox(lines,def_shapes_{i});
        fr= nnz(pixelCandidates(bb(2):bb(2)+bb(4),bb(1):bb(1)+bb(3)))/(bb(3)*bb(4));
        if (bb(3)/bb(4)<2.3 && bb(3)/bb(4)>0.5 && fr>0.3)
            windowCandidates=[windowCandidates; bb];
        end
    end
    
else
    windowCandidates=[];
end

% Get BB from circle centers and radius
if numel(circen_1) > 0
    for k=1:size(circen_1, 1)
        bb = [circen_1(k, 1) - cirrad_1(k), circen_1(k, 2) - cirrad_1(k), ...
            2 * cirrad_1(k), 2 * cirrad_1(k)];
        windowCandidates=[windowCandidates; bb];
    end
end
if numel(circen_2) > 0
    for k=1:size(circen_2, 1)
        bb = [circen_2(k, 1) - cirrad_2(k), circen_2(k, 2) - cirrad_2(k), ...
            2 * cirrad_2(k), 2 * cirrad_2(k)];
        windowCandidates=[windowCandidates; bb];
    end
end

%windowCandidates = candidatesArbitration(windowCandidates, 'hough', pixelCandidates);;
%% Plotting
if plotting
    subplot(2,3,4)
    imshow(pc_edges), hold on
    if exist('def_shapes_', 'var')
        disp(['Num shapes after filter shape ' int2str(length(def_shapes_))]);
        % Show lines in contour image
        for i=1:length(def_shapes_)
            vec= def_shapes_{i};
            if i==1
                color='green';
            elseif i==2
                color='red';
            elseif i==3
                color='blue';
            elseif i==4
                color='magenta';
            else
                color='yellow';
            end
            for k = 1:length(vec)
                xy = [lines(vec(k)).point1; lines(vec(k)).point2];
                plot(xy(:,1),xy(:,2),'LineWidth',2,'Color',color);
            end
        end
        
    end
    if ~isempty(circen_1)
        circ1 = viscircles(circen_1, cirrad_1, 'Color', 'b', 'LineWidth', 1, 'LineStyle', '--');
    end
    if ~isempty(circen_2)
        circ2 = viscircles(circen_2, cirrad_2, 'Color', 'r', 'LineWidth', 1, 'LineStyle', '--');
    end
    hold off
    title('Shapes in different colors')
    subplot(2,3,5);
    scatter(thetas,rhos)
    title('Theta and rho scatter')
    h=subplot(2,3,6); imshow(pixelCandidates,'Parent',h),hold on
    for zz = 1:size(windowCandidates,1)
        w=windowCandidates;
        r=rectangle(h,'Position', [w(zz,1), w(zz,2), w(zz,3), w(zz,4)], 'LineWidth',1,'EdgeColor','b');
        
    end
    title('Final bounding boxes without merge')
    drawnow
    waitforbuttonpress
    
end
    cands = [];
    for i=1:size(windowCandidates,1)
        cand.y = windowCandidates(i,1);
        cand.x = windowCandidates(i,2);
        cand.w = windowCandidates(i,3);
        cand.h = windowCandidates(i,4);
        cands = [cands; cand];
    end
    windowCandidates = cands;
    
end
function [closest_ind,end_seg_]=findClosestPoint(lines,pool,ind,end_seg)
%find closest point to lines(ind) in lines
%window size;
w=15;
%evaluate window around point1 or point2, depending on the point previously
%matched as candidate in last iteration.
end_seg_=0;
if end_seg==2
    ref=lines(ind).point2;
elseif end_seg==1
    ref=lines(ind).point1;
end
theta_ref=lines(ind).theta;
%closest candidates with point1
closest_candidates_p1=[];
%closest candidates with point2
closest_candidates_p2=[];
%now, lines are only the ones in the pool
%lines=lines(pool);
for i=-w:1:w
    for j=-w:1:w
        ref_point=[ref(1)+i,ref(2)+j];%construct 'ref_point' as the exact point to look for inside the window.
        for l=1:length(pool)
            %if a point1 or point2 in lines match the 'ref_point', a
            %closest_candidate has been found.
            if isequal(lines(pool(l)).point1,ref_point)  && ind~=l
                closest_candidates_p1=[closest_candidates_p1; pool(l)];
            elseif  isequal(lines(pool(l)).point2,ref_point) && ind~=l
                closest_candidates_p2=[closest_candidates_p2; pool(l)];
            end
        end
    end
end

%algorithm to discard closest_candidates
min_mse=1000;
min_ind=-1;
%theta_diff=
for i=1:length(closest_candidates_p1)
    cc=lines(closest_candidates_p1(i)).point1;
    mse=(abs(ref(1)-cc(1))^2+abs(ref(2)-cc(2))^2)/2;
    if mse<min_mse
        min_mse=mse;
        min_ind=closest_candidates_p1(i);
        end_seg_=1;
    end
end
for i=1:length(closest_candidates_p2)
    cc=lines(closest_candidates_p2(i)).point2;
    mse=(abs(ref(1)-cc(1))^2+abs(ref(2)-cc(2))^2)/2;
    if mse<min_mse
        min_mse=mse;
        min_ind=closest_candidates_p2(i);
        end_seg_=2;
    end
end
closest_ind=min_ind;

end

function [bb]=getBoundingBox(lines, shape)
%get bounding box just considering 'lines' with the indexes in 'shape' vector
max_y=0;
min_y=1000000000;
max_x=0;
min_x=1000000000;
for i=1:length(shape)
    point= lines(shape(i)).point1;
    if (point(1)>max_y)
        max_y=point(1);
    end
    if point(1)<min_y
        min_y=point(1);
    end
    if point(2)>max_x
        max_x=point(2);
    end
    if point(2)<min_x
        min_x=point(2);
    end
    point= lines(shape(i)).point2;
    if (point(1)>max_y)
        max_y=point(1);
    end
    if point(1)<min_y
        min_y=point(1);
    end
    if point(2)>max_x
        max_x=point(2);
    end
    if point(2)<min_x
        min_x=point(2);
    end
end

bb=[min_y,min_x,max_y-min_y, max_x-min_x];

end


function windCandidates = candidatesArbitration(windowCandidates, window_method, im)
% Window candidates arbitration
del=[];
for i=1:size(windowCandidates,1)
    if nnz(del==i)==0
        for j=i+1:size(windowCandidates,1)
            if nnz(del==j)==0
                switch(window_method)
                    case {'correlation', 'template_matching', 'hough'}
                        if abs(windowCandidates(i,2) - windowCandidates(j,2))<=max([windowCandidates(i,3),windowCandidates(j,3)])/2
                            windowCandidates(i,1)=min(windowCandidates(i,1),windowCandidates(j,1));
                            windowCandidates(i,2)=min(windowCandidates(i,2),windowCandidates(j,2));
                            windowCandidates(i,3)=max(windowCandidates(i,3),windowCandidates(j,3));
                            windowCandidates(i,4)=max(windowCandidates(i,4),windowCandidates(j,4));
                            del=[del j];
                        end
                        
                    otherwise
                        dist=norm(windowCandidates(i)-windowCandidates(j));
                        if dist<200
                            windowCandidates(i,1)=min(windowCandidates(i,1),windowCandidates(j,1));
                            windowCandidates(i,2)=min(windowCandidates(i,2),windowCandidates(j,2));
                            windowCandidates(i,3)=max(windowCandidates(i,3),windowCandidates(j,3));
                            windowCandidates(i,4)=max(windowCandidates(i,4),windowCandidates(j,4));
                            del=[del j];
                        end      
                end
            end
        end
    end
end
windowCandidates(del,:)=[];  
del=[];
windowCandidates(del,:)=[];  
windCandidates = windowCandidates;
end