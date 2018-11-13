%% SBIR USING MHEC AND SOH
tic;

window_size = 8;

%Query image
q_im = imread('../SampleImages/CoffeMug/16.jpg');
% im=q_im;
% mask = imread('../SampleImages/CoffeMug/6.png');
% mask=mask./mask;
[im, mask] = textureDistinctMap(q_im);
% newim=double(uint8(q_im).*uint8(mask));
% figure(1), imshow(im);
% figure(2), imshow(mat2gray(newim));
% figure(3), imshow(mask);

[q_image, Ix, Iy, x, y] = featureExtraction(double(im),mask);
figure,imshow(mat2gray(mask.*im)),title('Query Image Salient points'), hold on, scatter(y,x,'filled','r');
q_h = soh(Ix, Iy, x, y, window_size);
Process the database
D = dir('../SampleImages/CoffeMug/WithMask/*.jpg'); % check dir command, in matlab documentation
score = zeros(length(D)-2);
D1 = dir('../SampleImages/CoffeMug/WithMask/*.png'); % check dir command, in matlab documentation
    
for i=3:length(D)% for each file in the directory(1 and 2 are '.' and '..')
     filename = strcat('../SampleImages/CoffeMug/WithMask/',D(i).name);
     X=imread(filename);
     filename = strcat('../SampleImages/CoffeMug/WithMask/',D1(i).name);
%      mask1=imread(filename);
%      mask1=mask1./mask1;
%      im=X;
     %figure,imshow(X)
     
     [im,mask1] = textureDistinctMap(X);
     newim1=double(uint8(X).*uint8(mask1));
%     figure, imshow(mat2gray(newim1));
%      figure, imshow(im);
%      figure, imshow(mask1);

     [image, Ix, Iy, x, y] = featureExtraction(double(im),mask1);
     cx=x;
     cy=y;
%      figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(y,x,'filled','r');
     h = soh(Ix, Iy, x, y, window_size);
     s = similarity_score(q_h, h);
     score(i-2)=s;
%      disp('Score: ');
%      disp(num2str(s));
     if s==0
%          figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(cy,cx,'filled','r');
         figure,imshow(mat2gray(image)),title('Found Image');
%          disp('Score: ');
%          disp(num2str(s));
     end
end
score = sum(score,2);
toc;