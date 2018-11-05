function [image ,Ix, Iy, eigen_value, cornerness] = myHarrisCornerDetector(original_img, sigma1, sigma2, k)

    % rescale the intensities in the image to lie within the range [0, 1]
    minIntensity = min(original_img(:));
    maxIntensity = max(original_img(:));
    image = (original_img - minIntensity)/(maxIntensity - minIntensity);

    % smoothen the image
    filt1 = fspecial('gaussian', 2*ceil(3*sigma1)+1, sigma1);
    smooth_img = imfilter(image, filt1);

    % get derivative image along X and Y axes
    [Ix, Iy] = imgradientxy(smooth_img);

    % compute the matrices for structure tensor
    filt2 = fspecial('gaussian', 2*ceil(3*sigma2)+1, sigma2);
    Ixx = conv2(Ix.*Ix, filt2, 'same');
    Iyy = conv2(Iy.*Iy, filt2, 'same');
    Ixy = conv2(Ix.*Iy, filt2, 'same');

    % finding the eigenvalues and cornerness
    [x, y]= size(Ixx);
    eigen_value = zeros(x,y,2);
    corners = zeros(x,y);
    cornerness = zeros(x,y);
    for i = 1:x
        for j = 1:y
            M = [Ixx(i,j), Ixy(i,j); Ixy(i,j), Iyy(i,j)];
            e = eig(M);
            eigen_value(i,j,:) = [e(1),e(2)];
            corners(i,j) = det(M) - k*trace(M)*trace(M);
        end
    end

    %non maximum cornerness suppression
    index = imregionalmax(corners,8);
    cornerness(index) = corners(index);
end