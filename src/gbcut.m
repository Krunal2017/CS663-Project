%% Grabcut Segmentation of thresholded mask
tic;

datapath = '../TestImages/CoffeeMug/101.jpg';
res_im = imread(datapath);
figure
imshow(res_im)
h1 = impoly(gca,[72,15; 1,21; 20,36; 14,39;34,37; 58,33; 51,39; 19,72]);
pause(60);
roiPoints = getPosition(h1);
roi = poly2mask(roiPoints(:,1),roiPoints(:,2),size(L,1),size(L,2));
[m1,n1,p1]=size(res_im);
L = superpixels(res_im,200);
thres_mask = grabcut(res_im,L,roi);
figure;
imshow(thres_mask);

toc;