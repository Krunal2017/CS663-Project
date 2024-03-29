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
%q_im = imread(strcat(database_dir,keyword,'/',num2str(ind),'.jpg'));
q_im = imread('../../Corel100/0_20.jpg');
k = '0';
[im, mask] = textureDistinctMap(q_im);
[q_image, Ix, Iy, x, y] = featureExtraction(double(q_im),mask); 
figure;
subplot(1,4,1), imshow(mat2gray(q_im));
subplot(1,4,2), imshow(mat2gray(im));
subplot(1,4,3), imshow(mat2gray(mask));
subplot(1,4,4), imshow(mat2gray(q_im)),title('Salient points'), hold on, scatter(y,x,'filled','r.');

q_h = soh(Ix, Iy, x, y, window_size);

% Load the database SOH
soh_dir = strcat('../SOH_save/Corel100full.mat');
H = load(soh_dir);
score_struct = struct();

dir_name1=strcat('../../Corel100/');
D = dir(strcat('../../Corel100/*.jpg'));
N=floor(length(D)/3);

for i=1:100
    starting=1+(i-1)*100;
    ending=min(10000,starting+200-1);
    hist = H.SALIENCY_HISTOGRAMS(:,:,starting:ending);
    n=D(starting).name;
    num=strrep(n,'.jpg','');
    C = strsplit(num,'_');
    save(strcat('../SOH_save/corel_split_100/CLASS_',string(C(1)),'.mat'),'hist');
%     [s] = similarity_score(q_h, h, norm_thres);
%     score_struct(i).name = D(i).name;
%     score_struct(i).hist = h;
end

% %Sort the scores to get top images
% T = struct2table(score_struct);
% T_sorted = sortrows(T, 'score');
% score_struct_sorted = table2struct(T_sorted);
% 
% figure;
% for j=1:top_im_num
%     filename = strcat(dir_name1,score_struct_sorted(j).name);
%     X = imread(filename);
%     if j<26
%      subplot(5,5,j);
%      imshow(mat2gray(X));
%     end
% end
% 
% prec = ret_prec_corel(score_struct_sorted, D, top_im_num, keyword, '../../../Corel100/', k);
% disp('Precision:');
% disp(prec);

toc;