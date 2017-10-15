function [ out_img ] = mydualtophat( in_img, SE )
%Summary: This function applies an dual top-hat filter of an greyscale or binary image given a
%structuring element returned by the strel function. Erosion and Dilatation have been
%implemented and they are not Matlab's functions.
%   in_img - input image in greyscale
%   SE - structuring element returned by strel function.

out_img =  myclosing(in_img,SE) - in_img;

end

