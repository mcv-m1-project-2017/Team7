function [ out_img ] = myopening( in_img, SE )
%Summary: This function applies an opening filter of an greyscale or binary image given a
%structuring element returned by the strel function. Erosion and Dilatation have been
%implemented and they are not Matlab's functions.
%   in_img - input image in greyscale
%   SE - structuring element returned by strel function.

eroded = myerosion(in_img,SE);
out_img = mydilate(eroded,SE);


end

