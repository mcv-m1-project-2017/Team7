testImage='Lena.png';

I = imread(testImage);
in_img = rgb2gray(I);
SE = strel('square', 11);


%Morpholofical operators
%Measuring the computational efficiency of the implemented code
tic
dilout1 = mydilate(in_img,SE);
toc
tic
erout1 = myerosion(in_img,SE);
toc


%Measuring the computational efficiency of Matlab code
tic
dilout2 = imdilate(in_img,SE);
toc
tic
erout2 = imerode(in_img,SE);
toc


%Show the difference between operators
o_myresult = dilout1 - dilout2;
figure('Name','Error result between mydilate and imdilate')
imshow(o_myresult)

o_myresult = erout1 - erout2;
figure('Name','Error result between myerosion and imerode')
imshow(o_myresult)


figure('Name','Morphological operators');
subplot(2,2,1);
imshow(dilout1);
title('Mydilate');

subplot(2,2,2);
imshow(erout1);
title('Myerosion');

subplot(2,2,3);
imshow(dilout2);
title('Matlab Dilation');

subplot(2,2,4);
imshow(erout2);
title('Matlab Erosion');

%Morphological filters
closing = myclosing(in_img,SE);
opening = myopening(in_img,SE);
tophat = mytophat(in_img,SE);
dualtophat = mydualtophat(in_img,SE);

figure('Name', 'Morphological filters (example)');
subplot(2,2,1);
imshow(closing);
title('Closing');

subplot(2,2,2);
imshow(opening);
title('Opening');

subplot(2,2,3);
imshow(tophat);
title('Top-Hat');

subplot(2,2,4);
imshow(dualtophat);
title('Dual Top-Hat');




