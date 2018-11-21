%% SAVE SOH FOR DATABASE
tic;

window_size = 8;
keyword = 'DogJump';
database_dir = '../../../THUR15000/';

% Process the database
dir_name = strcat(database_dir,keyword);
D = dir(strcat(dir_name,'/Src/*.jpg')); % check dir command, in matlab documentation

N=floor(length(D));

SALIENCY_HISTOGRAMS=[];
f = waitbar(0,"Please Wait...");

for i=1:N
    msg=strcat('Computing SOH ',num2str(i),'/',num2str(N));
    f = waitbar(i/N,f,msg);
     filename = strcat(strcat(dir_name,'/Src/'),D(i).name);
     X=double(imread(filename));
     filename = strcat('../output_texture/',keyword,'/masks/',D(i).name);
     mask1 = imread(filename);
%      [im,mask1] = textureDistinctMap(X);
     [image, Ix, Iy, x, y] = featureExtraction(double(X),mask1);
     cx=x;
     cy=y;
%      figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(y,x,'filled','r');

     h = soh(Ix, Iy, x, y, window_size);
     SALIENCY_HISTOGRAMS(:,:,i)=h;
end
close(f);
soh_file = strcat(strcat('../SOH_save/',keyword),'_full_mhec_sal_hists.mat');
save(soh_file,'SALIENCY_HISTOGRAMS');

toc;