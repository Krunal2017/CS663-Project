function [s] = soh(Ix, Iy, x, y, window_size)
    h_gauss = 0.5;
    %Gradient magnitude and direction
    gradMag = sqrt(Ix.^2 + Iy.^2);
    gradDir = atan(Iy./Ix);
    [m,n] = size(gradMag);
    
    %Major orientation and histogram construction
    [p,~] = size(x);
    maj_orient = zeros(size(x));
    H = zeros(180,p);

    for i=1:p
            %Gradient and direction in window
            window_Mag = gradMag(max(x(i)-window_size/2-1, 1): min(x(i)+ window_size/2, m), max(y(i)-window_size/2-1, 1): min(y(i)+ window_size/2, n));
            window_Dir = gradDir(max(x(i)-window_size/2-1, 1): min(x(i)+ window_size/2, m), max(y(i)-window_size/2-1, 1): min(y(i)+ window_size/2, n));
        
            prev = 0;
            %Gaussian kernel for smoothening
            for j=-90:90
                w_kernel = exp(-((repmat(j,size(window_Dir,1),size(window_Dir,2))-window_Dir)/h_gauss).^2);

                z = sum(sum((1/h_gauss)*(window_Mag.*w_kernel)));
                u = sum(sum(window_Mag));

                %Weighted density of orientation of ith feature point(-90 to 90)
                w_dense = z / u;

                %Major orientation and histogram of ith feature point
                %[maj_val ,~] = max(w_dense);
                if(prev < w_dense)
                    prev = w_dense;
                    maj_orient(i) = j;
                end
                    
            end
            H(maj_orient(i)+91,i) = 1;
    end

    %SOH for the image
     s = (1/p)*sum(H,2);
end