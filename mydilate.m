function [ out_img ] = mydilate( in_img, SE )
%Summary: This function dialtes an greyscale or binary image given a
%structuring element returned by the strel function. The image padding
%selected for this case is Mirroring.
%   in_img - input image in greyscale
%   SE - structuring element returned by strel function.

%Flip SE
fSE = fliplr(SE.Neighborhood);
invSE = flip(fSE);

%Size of SE
[SEy,SEx] = size(SE.Neighborhood);
SEcenter = [round(SEy/2);round(SEx/2)];

%Padding - Mirroring
%X axis
for i=1:1:(SEcenter(2))
    padImg(i,:) = in_img(1,:);
    padImg2(i,:) = in_img(size(in_img,1),:);
end
padImg = [padImg;in_img;padImg2];
%Y axis
for i=1:1:(SEcenter(1))
    padImgy(:,i) = padImg(:,1);
    padImgy2(:,i) = padImg(:,size(padImg,2));
end
padImg = [padImgy,padImg,padImgy2];


%Dilate
StructE = uint16(SE.Neighborhood);
for i=1:1:size(in_img,1)
    for j=1:1:size(in_img,2)
        output(i,j) = max(max(StructE.*uint16(padImg(i:(i+SEx-1),j:(j+SEy-1)))));
    end
end

out_img = uint8(output);

%%Notes 
%     For all shapes except 'arbitrary', structuring elements are constructed
%     using a family of techniques known collectively as "structuring element
%     decomposition."  The principle is that dilation by some large
%     structuring elements can be computed faster by dilation with a sequence
%     of smaller structuring elements.  For example, dilation by an 11-by-11
%     square structuring element can be accomplished by dilating first with a
%     1-by-11 structuring element and then with an 11-by-1 structuring
%     element.  This results in a theoretical performance improvement of a
%     factor of 5.5, although in practice the actual performance improvement
%     is somewhat less.  Structuring element decompositions used for the
%     'disk' and 'ball' shapes are approximations; all other decompositions
%     are exact.

