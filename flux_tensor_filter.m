function [ motion_blob ] = flux_tensor_filter( video )

% make three videos that contain frames: Ixs, Iys, Iss
% Ixs: smooth on y direction and take dir on x direction
% Iys: smooth on x direction and take dir on y direction 
% Iss: smooth on both direction 

Vxs = zeros(size(video));
Vys = zeros(size(video));
Vss = zeros(size(video));


sigma = 5;
gsize = 30;
x = linspace(-gsize/2, gsize/2, gsize);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum(gaussFilter);


for k = 1:size(video,3)
    % make a gauss_x image, a gauss_y image and a smoothed image in both
    %  directions 
    curr_frame = video(:,:,k);
    sx_curr_frame = zeros(size(curr_frame));
    sy_curr_frame = zeros(size(curr_frame));
    ss_curr_frame = zeros(size(curr_frame));
    
    % smooth the image
    height = size(curr_frame,1);
    width = size(curr_frame,2);
    for i = 1:size(k,1)
       row = curr_frame(i,:);
       g_row = conv(row, gaussFilter);
       sx_curr_frame(i,:) = g_row(15: width + 14);
    end
    
    for j = 1:size(k,2)
        col = curr_frame(:,j);
        g_col = conv(col, gaussFilter');
        sy_curr_frame(:,j) = g_col(15: height + 14);
    end
    
    for j = 1:size(k,2)
        col = sx_curr_frame(:,j);
        g_col = conv(col, gaussFilter');
        ss_curr_frame(:,j) = g_col(15: height + 14);
    end
    
    % take the gradients
    [Ixs, foo] = imgradientxy(sx_curr_frame);
    [foo, Ixy] = imgradientxy(sy_curr_frame);
    
    % store the result 
    Vxs(:,:,k) = Ixs;
    Vys(:,:,k) = Ixy;
    Vss(:,:,k) = ss_curr_frame;
    
end

% differentiate over time
%switch the 2nd and 3nd dimension
%VxsT = zeros(size(video,1),size(video,3),size(video,2));
%VysT = zeros(size(video,1),size(video,3),size(video,2));
%VssT = zeros(size(video,1),size(video,3),size(video,2));

%for i = 1:size(Vxs,3)
 %   VxsT(:,i,:) = Vxs(:,:,i);
 %   VysT(:,i,:) = Vys(:,:,i);
 %   VssT(:,i,:) = Vss(:,:,i);
%end

[fx,fy,Vxt] = gradient(Vxs);
[fx,fy,Vyt] = gradient(Vys);
[fx,fy,Vt] = gradient(Vss);
[fx,fy,Vtt] = gradient(Vt);


%get the image of Ixt^2 + Iyt^2 + Itt^2
sum_of_squared = zeros(size(Vxt));
for i = 1:size(Vxt,3)
    sum_of_squared(:,:,i) = Vxt(:,:,i).^2 + Vyt(:,:,i).^2 + Vtt(:,:,i).^2; 
end

% average in the neighborhood
% now choose 3x3
kernel = [1/9,1/9,1/9;1/9,1/9,1/9;1/9,1/9,1/9];
trace_I = conv( sum_of_squared,kernel);





