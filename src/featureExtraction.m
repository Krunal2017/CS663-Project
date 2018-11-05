function[image, Ix, Iy, x, y] = featureExtraction(im)
    %Corner detection parameters
    sigma1 = 1.7;
    sigma2 = 0.8;
    k = 0.16;

    %Feature extraction (Harris corner detection-sobel edge detection)
    [image, Ix, Iy, ~, cornerness] = myHarrisCornerDetector(im, sigma1, sigma2, k);

    %Feature point construction
    cornerness = (cornerness>1e-4);
    [x,y] = find(cornerness);
end