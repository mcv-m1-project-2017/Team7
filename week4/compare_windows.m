function corr_list = compare_windows(im, im_seg, windowCandidates, templates)
    %Function that compared window candidates with different templates and
    %returns the correlation between them.
    if nargin < 4
        temp_A = imread('template_A.png'); temp_B = imread('template_B.png');
        temp_C = imread('template_C.png'); temp_D = imread('template_D.png');
        temp_E = imread('template_E.png'); temp_F = imread('template_F.png');
        templates = {temp_A, temp_B, temp_C, temp_D, temp_E, temp_F};
    end
    num_win = length(windowCandidates);
    corr_list = zeros(num_win, 6);
   for i=1:num_win
       if i ==2
           i;
       end
       xmax = windowCandidates(i).x + windowCandidates(i).w - 1;
       ymax = windowCandidates(i).y + windowCandidates(i).h - 1;
       im_bounded = im(windowCandidates(i).y:ymax, windowCandidates(i).x:xmax);
       mask_bounded = im_seg(windowCandidates(i).y:ymax, windowCandidates(i).x:xmax);
       candidate = im_bounded .* uint8(mask_bounded);
       for k=1:length(templates)
          if ~isempty(candidate)
            template = imresize(templates{k}, [size(candidate,1) size(candidate,2)]);
            corr_list(i,k) = corr2(candidate, template); 
          end
       end
   end
end