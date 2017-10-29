function [out_value] = integral_image(in_img,x,y,sizex,sizey)
%The integral image computes a value at each pixel (x,y) that is the sum of the pixel 
%values above and to the left of (x,y), inclusive.


%in_img: Reordered image
%x: X position to evaluate
%y: Y position to evalueate
%sizex: width of the window
%sizey: height of the window

%out_value: Area of the window


%Sum = A - B - C + D
% D = (x,y) | Top-left corner
% B = (x+sizex,y) | Top-right corner
% C = (x,y+sizey) | Bottom-left corner
% A = (x+sizex,y+sizey) | Bottom-right corner
out_value = in_img(x+sizex,y+sizey) - in_img(x,y+sizey) - in_img(x+sizex,y) + in_img(x,y); 



end

