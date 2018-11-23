H1 = load('../SOH_save/harris/train_harris_sal_hists_1.mat');
H2 = load('../SOH_save/harris/train_harris_sal_hists_2.mat');
H3 = load('../SOH_save/harris/train_harris_sal_hists_3.mat');
H4 = load('../SOH_save/harris/test_harris_sal_hists.mat');

hist=cat(3,H1.SALIENCY_HISTOGRAMS, H2.SALIENCY_HISTOGRAMS);
hist=cat(3,hist, H3.SALIENCY_HISTOGRAMS);
hist=cat(3,hist, H4.TEST_SALIENCY_HISTOGRAMS);

save('../SOH_save/CoffeeMug_harris_sal_hist.mat', 'hist');

dir_name = '../../../Corel100/';
D = dir(strcat(dir_name,'*.jpg')); % check dir command, in matlab documentation

N=floor(length(D)); % Save files in 3 parts 1:N1, N1+1:N2, N2+1:N
N1=floor(length(D))/3;
N2=2*N1;