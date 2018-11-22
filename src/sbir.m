%% SBIR FOR QUERY IMAGE
tic;

window_size = 8;
norm_thres = 0.5;
top_im_num = 100;
keyword = 'DogJump';
database_dir = '../TestImages/';
ind = 44;
%Database Directory
dir_name = strcat(database_dir,keyword);
iter=1;
precisions=[];
%%

%Query image
q_im = imread(strcat(database_dir,keyword,'/',num2str(ind),'.jpg'));
[im, mask] = textureDistinctMap(q_im);
[q_image, Ix, Iy, x, y] = featureExtraction(double(q_im),mask); 
q_h = soh(Ix, Iy, x, y, window_size);

% Load the database SOH
soh_dir = strcat(strcat('../SOH_save/mhec/',keyword),'_full_mhec_sal_hists.mat');
H = load(soh_dir);
score_struct = struct();

D = dir(strcat('../../../THUR15000/',keyword,'/Src/*.jpg'));
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
end

prec = ret_prec(score_struct_sorted, D, top_im_num, keyword, '../../../THUR15000/');
disp('Precision:');
disp(prec);

toc;