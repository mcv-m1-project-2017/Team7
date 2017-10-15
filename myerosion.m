function [out_img] = myerosion(in_img, SE)
%Summary: This function eroses an greyscale or binary image given a
%structuring element returned by the strel function. The image padding
%selected for this case is Mirroring.
%   in_img - input image in greyscale
%   SE - structuring element returned by strel function.

%Size of SE
[SEy,SEx] = size(SE.Neighborhood);
SEcenter = [round(SEy/2);round(SEx/2)];

%Padding - Mirroring
%X Axis
for i=1:1:(SEcenter(2))
    padImg(i,:) = in_img(1,:);
    padImg2(i,:) = in_img(size(in_img,1),:);
end
padImg = [padImg;in_img;padImg2];
%Y Axis
for i=1:1:(SEcenter(1))
    padImgy(:,i) = padImg(:,1);
    padImgy2(:,i) = padImg(:,size(padImg,2));
end
padImg = [padImgy,padImg,padImgy2];


%Erose
StructE = uint16(SE.Neighborhood);
for i=1:1:size(in_img,1)
    for j=1:1:size(in_img,2)
        output(i,j) = min(min(StructE.*uint16(padImg(i:(i+SEx-1),j:(j+SEy-1)))));
    end
end

out_img = uint8(output);


end

