%% SBIR USING MHEC AND SOH
tic;

window_size = 8;

%Query image
q_im = imread('../SampleImages/CoffeMug/6.jpg');
[im, mask] = textureDistinctMap(q_im);
% figure(1), imshow(mat2gray(im));
% figure(2), imshow(mat2gray(mask));

[q_image, Ix, Iy, x, y] = featureExtraction(double(q_im),mask);
% figure,imshow(q_image),title('Query Image Salient points'), hold on, scatter(y,x,'filled','r');

q_h = soh(Ix, Iy, x, y, window_size);
% Process the database
D = dir('../SampleImages/CoffeMug/WithMask/*.jpg'); % check dir command, in matlab documentation
score = zeros(length(D)-2);
    
for i=3:length(D)% for each file in the directory(1 and 2 are '.' and '..')
     filename = strcat('../SampleImages/CoffeMug/WithMask/',D(i).name);
     X=imread(filename);
     [im,mask1] = textureDistinctMap(X);

     [image, Ix, Iy, x, y] = featureExtraction(double(X),mask1);
     cx=x;
     cy=y;
%      figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(y,x,'filled','r');

     h = soh(Ix, Iy, x, y, window_size);
     norm_thres=0.5;    % can be 0.5 for squared diff or 0.9 of normalized diff
     [s] = similarity_score(q_h, h, norm_thres);
     score(i-2)=s;
     if s<0.5
%          figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(cy,cx,'filled','r');
         figure,imshow(mat2gray(image)),title('Found Image');
%          disp('Score: ');
%          disp(num2str(s));
     end
end
score = sum(score,2);
toc;