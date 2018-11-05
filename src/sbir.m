%% CBIR USING MHEC AND SOH
tic;

window_size = 8;

%Query image
q_im = imread('../SampleImages/Butterfly/10.jpg');
im = textureDistinctMap(q_im);
figure, imshow(im);
[q_image, Ix, Iy, x, y] = featureExtraction(double(im));
q_h = soh(Ix, Iy, x, y, window_size);

%Process the database
D = dir('../SampleImages/Butterfly'); % check dir command, in matlab documentation
score = zeros(length(D)-2);

for i=3:length(D)% for each file in the directory(1 and 2 are '.' and '..')
     filename = strcat('../SampleImages/Butterfly/',D(i).name);
     X=imread(filename);
     %figure,imshow(X)
     im = textureDistinctMap(X);
     figure, imshow(im);
     [image, Ix, Iy, x, y] = featureExtraction(double(im));
     h = soh(Ix, Iy, x, y, window_size);
     score(i-2) = similarity_score(q_h, h);
     %disp(['Score: ',num2str(score)]);
end
toc;