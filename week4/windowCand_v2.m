function [im_seg,windowCandidates] = windowCand_v2(im_seg, w, h, ff, fr, BoundingBoxes,windMethod)

    switch(windMethod)

     case 1 %Method used for week 3
        s=0;
        for i=1:size(BoundingBoxes,1)
            width=BoundingBoxes(i,3);
            height=BoundingBoxes(i,4);
            bbox_area=width*height;
            form_factor=width/height;
            TL=BoundingBoxes(i,1:2); %Bounding box Top-Left corner coordinate.
            BR=[TL(1)+width-1 TL(2)+height-1]; %Bounding box Bottom-Right corner coordinate.
            mask_area=sum(sum(im_seg(TL(2):BR(2),TL(1):BR(1))));
            filling_ratio = mask_area/bbox_area;
            if (width>=w(1) && width<=w(2))&&(height>=h(1) && height<=h(2))&&(form_factor>=ff(1) && form_factor<=ff(2))&&(filling_ratio>=fr(1) && filling_ratio<=fr(2))
                s=s+1;
                windowCandidates(s).x=BoundingBoxes(i,1);
                windowCandidates(s).y=BoundingBoxes(i,2);
                windowCandidates(s).w=BoundingBoxes(i,3);
                windowCandidates(s).h=BoundingBoxes(i,4);
            end    
        end

        case 2 %Improvement for week 4
        s=0;
        for i=1:size(BoundingBoxes,1)
            width=BoundingBoxes(i,3);
            height=BoundingBoxes(i,4);
            bbox_area=width*height;
            form_factor=width/height;
            TL=BoundingBoxes(i,1:2); %Bounding box Top-Left corner coordinate.
            BR=[TL(1)+width-1 TL(2)+height-1]; %Bounding box Bottom-Right corner coordinate.
            mask_area=sum(sum(im_seg(TL(2):BR(2),TL(1):BR(1))));
            filling_ratio = mask_area/bbox_area;
            if (width>=(w(3)-1.7*w(4))&&(height>=(h(3)-1.7*h(4)))&&(form_factor>=ff(1)-1.5*ff(4) && form_factor<=ff(2)+1.5*ff(4))&&(filling_ratio>=fr(1)-1.5*fr(4) && filling_ratio<=fr(2)+1.5*fr(4)))
                s=s+1;
                windowCandidates(s).x=BoundingBoxes(i,1);
                windowCandidates(s).y=BoundingBoxes(i,2);
                windowCandidates(s).w=BoundingBoxes(i,3);
                windowCandidates(s).h=BoundingBoxes(i,4);
            end    
        end      

        otherwise
         disp('Error, not a valid method')

    end
        
    mask_windows=zeros(size(im_seg));
    if s==0
            windowCandidates(1).x=1;
            windowCandidates(1).y=1;
            windowCandidates(1).w=0;
            windowCandidates(1).h=0; 
    end
    
    for j=1:size(windowCandidates,2)
        mask_windows(windowCandidates(j).y:windowCandidates(j).y+windowCandidates(j).h-1,windowCandidates(j).x:windowCandidates(j).x+windowCandidates(j).w-1)=1;
    end
    im_seg=im_seg.*mask_windows;
        
end
