%% SAVE SOH FOR DATABASE
tic;

window_size = 8;
keyword = 'CoffeeMug';
database_dir = '../SampleImages/';

% Process the database
dir_name = strcat(database_dir,keyword);
D = dir(strcat(dir_name,'/*.jpg')); % check dir command, in matlab documentation
N=floor(length(D));

SALIENCY_HISTOGRAMS=[];
f = waitbar(0,"Please Wait...");

for i=1:N
    msg=strcat('Computing SOH ',num2str(i),'/',num2str(N));
    f = waitbar(i/N,f,msg);
    filename = strcat(strcat(dir_name,'/'),D(i).name);
    X=double(imread(filename));
    [im,mask1] = textureDistinctMap(X);
    [image, Ix, Iy, x, y] = featureExtraction(double(X),mask1);
    cx=x;
    cy=y;
    h = soh(Ix, Iy, x, y, window_size);
    SALIENCY_HISTOGRAMS(:,:,i)=h;
end
close(f);
soh_file = strcat(strcat('../SOH_save/',keyword),'_200_mhec_sal_hists.mat');
save(soh_file,'SALIENCY_HISTOGRAMS');
toc;