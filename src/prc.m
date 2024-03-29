load('train_harris_sal_hists_1.mat');
h1=SALIENCY_HISTOGRAMS;
load('train_harris_sal_hists_2.mat');
h2=SALIENCY_HISTOGRAMS;
hist=cat(3,h1,h2);
load('train_harris_sal_hists_3.mat');
h3=SALIENCY_HISTOGRAMS;
hist=cat(3,hist,h3);
load('test_harris_sal_hists.mat');
test=TEST_SALIENCY_HISTOGRAMS;

%% Compute scores
M=size(hist,3);
N=size(test,3);
scores=zeros(M,N);
m=0.5;

tic;
f = waitbar(0,"Please Wait...");
for i=1:N
    msg='Computing scores...';
    f = waitbar(i/N,f,msg);
    for j=1:M
        s=similarity_score(test(:,:,i),hist(:,:,j),m);
        scores(j,i)=s;
    end
end
close(f);
toc;

%% GT
D = dir('../../THUR15000/CoffeeMug/Src/*.png');
GT=zeros(M+N,1);
for i=1:length(D)
    n=D(i).name;
    num=strrep(n,'.png','');
    indices(i)=str2num(num);
end
GT(indices)=1;

%%
subGT=GT(1:M);
indices=find(scores<0.08);
labels=zeros(M,N);
labels(indices)=1;
acc=labels==subGT;

%%
trueLabels=GT(M+1:M+N);
positives=sum(acc);
indices=find(trueLabels==1);
TP=sum(positives(indices));
FN=sum(sum(subGT)-positives(indices));
indices=find(trueLabels==0);
FP=sum(positives(indices));

recall=TP/(TP+FN);
precision=TP/(TP+FP);

b2=0.3;
Fb=( (1+b2)*precision*recall )/( b2*precision+recall );
disp(strcat('Fb: ',num2str(Fb)));