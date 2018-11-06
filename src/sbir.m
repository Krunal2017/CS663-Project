%% SBIR USING MHEC AND SOH
tic;

window_size = 8;

%Query image
q_im = imread('../SampleImages/TestBase/5.jpg');
[im, mask] = textureDistinctMap(q_im);
figure, imshow(im);
figure, imshow(mask);
[q_image, Ix, Iy, x, y] = featureExtraction(double(im),mask);
q_h = soh(Ix, Iy, x, y, window_size);

%Process the database
D = dir('../SampleImages/TestBase'); % check dir command, in matlab documentation
score = zeros(length(D)-2);

for i=3:length(D)% for each file in the directory(1 and 2 are '.' and '..')
     filename = strcat('../SampleImages/TestBase/',D(i).name);
     X=imread(filename);
     %figure,imshow(X)
     [im,mask] = textureDistinctMap(X);
     figure, imshow(im);
     figure, imshow(mask);
     [image, Ix, Iy, x, y] = featureExtraction(double(im),mask);
     h = soh(Ix, Iy, x, y, window_size);
     score(i-2) = similarity_score(q_h, h);
     %disp(['Score: ',num2str(score)]);
end
score = sum(score,2);

toc;