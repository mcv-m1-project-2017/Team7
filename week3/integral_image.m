function [out_value] = integral_image(in_img,x,y,sizex,sizey)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

ii = cumsum(cumsum(double(in_img)), 2);

%Sum = A - B - C + D
% D = (x,y)
% B = (x+sizex,y)
% C = (x,y+sizey)
% A = (x+sizex,y+sizey)


out_value = ii(y+sizey,x+sizex) - ii(y,x+sizex) - ii(y+sizey,x) + ii(y,x); 



end

