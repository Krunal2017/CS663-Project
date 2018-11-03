I=imread('../src/1.jpg');
mask1=imread('../src/1.png');
mask=mask1(:,:,1);
mask=mask./mask;
% I=I.*mask;
original_img = I(:,:,1);
original_img=original_img.*mask;
original_img=double(original_img);
sigma1 = 1.7;
sigma2 = 0.8;
k = 0.16;

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
Rmod=zeros(x,y);
for i = 1:x
    for j = 1:y
        M = [Ixx(i,j), Ixy(i,j); Ixy(i,j), Iyy(i,j)];
        e = eig(M);
        eigen_value(i,j,:) = [e(1),e(2)];
        Rmod(i,j)=max(e(1),e(2));
        corners(i,j) = det(M) - k*trace(M)*trace(M);
    end
end

%non maximum cornerness suppression
index = imregionalmax(corners,8);
cornerness(index) = corners(index);
[modx, mody] = imgradientxy(Rmod);
% figure, myColorbar(Ix), title('Derivative Image along X axis');
% 
% figure, myColorbar(Iy), title('Derivative Image along Y axis');
% 
% figure, myColorbar(eigen_value(:,:,1)), title('First eigenvalue of the structure tensor');

feature_points=[];
Tmax=1e+2;
for i=2:x-1
    for j=2:y-1
        if Rmod(i,j)>Tmax
            maximum=max(max(Rmod(i-1:i+1,j-1:j+1)));
            feature_points=cat(1,feature_points,maximum);
        end
    end
end

figure, myColorbar(Rmod), title('Second eigenvalue of the structure tensor');


cornerness = (cornerness>1e-3);
[x,y] = find(cornerness);
disp(['Number of corners detected: ',num2str(size(x,1))]);
disp(['Parameter sigma1: ',num2str(sigma1)]);
disp(['Parameter sigma2: ',num2str(sigma2)]);
disp(['Parameter k: ',num2str(k)]);
figure, imagesc(I), axis image, colormap(gray), colorbar, hold on
scatter(y,x,'r.'), title('Corners Detected!');
