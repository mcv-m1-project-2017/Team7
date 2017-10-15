function [ out_img ] = mytophat( in_img, SE )
%Summary: This function applies an top-hat filter of an greyscale or binary image given a
%structuring element returned by the strel function. Erosion and Dilatation have been
%implemented and they are not Matlab's functions.
%   in_img - input image in greyscale
%   SE - structuring element returned by strel function.


out_img = in_img - myopening(in_img,SE);


end

