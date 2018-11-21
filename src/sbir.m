%% SBIR FOR QUERY IMAGE
tic;

window_size = 8;
top_im_num = 100;
norm_thres = 0.5;
keyword = 'DogJump';
database_dir = '../SampleImages/';

%Database Directory
dir_name = strcat(database_dir,keyword);

%Query image
q_im = imread('../../../THUR15000/DogJump/Src/1006.jpg');
[im, mask] = textureDistinctMap(q_im);
[q_image, Ix, Iy, x, y] = featureExtraction(double(q_im),mask); 
q_h = soh(Ix, Iy, x, y, window_size);

% Load the database SOH
soh_dir = strcat(strcat('../SOH_save/',keyword),'_full_mhec_sal_hists.mat');
H = load(soh_dir);
%score = zeros(length(D),1);
score_struct = struct();

D = dir(strcat('../../../THUR15000/DogJump/Src','/*.jpg'));
N=floor(length(D));

for i=1:N
    h = H.SALIENCY_HISTOGRAMS(:,:,i);
    [s] = similarity_score(q_h, h, norm_thres);
    score_struct(i).name = D(i).name;
    score_struct(i).score = s;
end

%Sort the scores to get top images
T = struct2table(score_struct);
T_sorted = sortrows(T, 'score');
score_struct_sorted = table2struct(T_sorted);

for j=1:top_im_num
    filename = strcat(strcat(dir_name,'/'),score_struct_sorted(j).name);
    %X = imread(filename);
    %figure,imshow(X),title('Found Image');
end

prec = ret_prec(score_struct_sorted, D, top_im_num, keyword, '../../../THUR15000/');

disp('Precision:');
disp(prec);

toc;