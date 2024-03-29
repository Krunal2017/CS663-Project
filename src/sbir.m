%% SBIR FOR QUERY IMAGE
tic;

window_size = 8;
norm_thres = 0.5;
top_im_num = 5;
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
arr = [0,10:19,2,20:29,3,30:39,4,40:49,5,50:59,6,60:69,7,70:79,8,80:89,9,90:99];
k = '2';
q_im = imread(strcat('../../Corel100/',k,'_232.jpg'));
[im, mask] = textureDistinctMap(q_im);
[q_image, Ix, Iy, x, y] = featureExtraction(double(q_im),mask); 
figure;
subplot(1,4,1), imshow(mat2gray(q_im));
subplot(1,4,2), imshow(mat2gray(im));
subplot(1,4,3), imshow(mat2gray(mask));
subplot(1,4,4), imshow(mat2gray(q_im)),title('Salient points'), hold on, scatter(y,x,'filled','r.');

q_h = soh(Ix, Iy, x, y, window_size);

% Load the database SOH
soh_dir = strcat('../SOH_save/corel_split_100/CLASS_',k,'.mat');
H = load(soh_dir);
histograms=H.hist;
score_struct = struct();

dir_name1=strcat('../../Corel100/');
D = dir(strcat('../../Corel100/','*.jpg'));
N=size(histograms,3);

scores=zeros(N,1);
for i=1:N
%     starting=1+(i-1)*100;
%     ending=starting+20-1;
%     hist = H.SALIENCY_HISTOGRAMS(:,:,starting:ending);
%     n=D(starting).name;
%     num=strrep(n,'.jpg','');
%     C = strsplit(num,'_');
%     save(strcat('../SOH_save/corel_split/CLASS_',string(C(1)),'.mat'),'hist');
    h= histograms(:,:,i);
    [s] = similarity_score(q_h, h, norm_thres);
    scores(i)=s;
%     score_struct(i).name = strcat((k,'_',i)).name;
%     score_struct(i).score = s;
end

[sorted_scores,ori_indices]=sort(scores);
top_scores=sorted_scores(1:top_im_num);
top_indices=ori_indices(1:top_im_num);
falses=find(top_indices>100);

prec=(1-length(falses)/top_im_num)*100;
% indices=find(scores>norm_thres);

% %Sort the scores to get top images
% T = struct2table(score_struct);
% T_sorted = sortrows(T, 'score');
% score_struct_sorted = table2struct(T_sorted);
% 
figure;
for j=1:top_im_num
    if top_indices(j)<101
        D1 = dir(strcat('../../Corel100/',k,'_*.jpg'));
        filename=strcat('../../Corel100/',D1(top_indices(j)).name);
%         num=strcat(k,'_',num2str(top_indices(j)) );
    else
        n=str2num(k);
        ind=find(arr==n);
        next=num2str(arr(ind+1));
        D1 = dir(strcat('../../Corel100/',next,'_*.jpg'));
        %disp(top_indices(j));
        filename=strcat('../../Corel100/',D1(top_indices(j)-100).name);
    end
%         num=strcat(n,'_',num2str(top_indices(j)-100);
%     filename = strcat(dir_name1,num);
    X = imread(filename);
    if j<26
     subplot(5,5,j);
     imshow(mat2gray(X));
    end
end
% 
% prec = ret_prec_corel(score_struct_sorted, D, top_im_num, keyword, '../../../Corel100/', k);
disp('Precision:');
disp(prec);

toc;