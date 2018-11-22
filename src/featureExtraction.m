function[image, Ix, Iy, x, y] = featureExtraction(im,mask)
    if mask==zeros(size(mask))
        newim=mat2gray(im);
    else
        newim=mat2gray(im.*mask);
    end
    
    sigma1 = 1.7;
    sigma2 = 0.8;
    k = 0.16;

    %Feature extraction (Harris corner detection-sobel edge detection)
    [image, Ix, Iy, ~, cornerness] = myHarrisCornerDetector(double(rgb2gray(newim)), sigma1, sigma2, k);
    %Feature point construction
    cornerness = (cornerness>1e-4);
    [x,y] = find(cornerness);
end