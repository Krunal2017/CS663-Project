%% SBIR FOR QUERY IMAGE
tic;

% images = [171;179;2234;2240];
% path = '../TestImages/Butterfly/';
% images = [101;105;108;111;113;1140;2231;2246;3143];
% path = '../TestImages/CoffeeMug/';
% images = [2;3;4;7;8;17;18;21;24;32;40;44;47;49];
% path = '../TestImages/DogJump/';
% images = [8;13;31;41;96;1007;1307];
% path = '../TestImages/Giraffe/';
% images = [1;3;6;9;10;19;33;40;1919;2735;2736;2740];
% path = '../TestImages/plane/';

[s,s1] = size(images);
for ind = 1:s
    datapath = strcat(path,num2str(images(ind)),'/');
    if ~exist(datapath,'dir')
        mkdir(datapath);
    end
    q_im = imread(strcat(path,num2str(images(ind)),'.jpg'));
    imwrite(mat2gray(q_im),strcat(datapath,num2str(images(ind)),'.jpg'));
    
    [im, mask] = textureDistinctMap(q_im);
    imwrite(mat2gray(im),strcat(datapath,num2str(images(ind)),'_tex.jpg'));
    imwrite(mat2gray(mask),strcat(datapath,num2str(images(ind)),'_mask.jpg'));
    
    [q_image, Ix, Iy, x, y] = featureExtraction(double(q_im),mask);
    imwrite(c,strcat(datapath,num2str(images(ind)),'_edge.jpg'));
    
    f = figure('visible','off');
    imshow(mat2gray(q_im)), hold on, scatter(y,x,'r.');
    saveas(f,strcat(datapath,num2str(images(ind)),'_mhec.jpg'));
    
    q_im = double(q_im);
    if mask==zeros(size(mask))
        newim=mat2gray(q_im);
    else
        newim=mat2gray(q_im.*mask);
    end
    H = detectHarrisFeatures(rgb2gray(newim));
    f = figure('visible','off');
    imshow(mat2gray(q_im)), hold on, plot(H.Location(:,1),H.Location(:,2),'r.','MarkerSize',10);
    saveas(f,strcat(datapath,num2str(images(ind)),'_hec.jpg'));
    
end

toc;