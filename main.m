% Implementation of the flux tensor algorithm for motion detection in a
% video.

% paper: Bunyak, Palaniappan, Nath: "FLux Tensor Constrained Geodesic Active Contours with Sensor Fusion for Persistent Object Tracking"

% steps: 
% for imcoming input video v, take gradient on only & both x, y dirs 
% and take gradient on t dir
% and integrate 
% finally compute the trace.. .




% read the data

listing = dir('taxi');
names = {listing.name};

sampleimg = imread(strcat('taxi/',char(names(size(names,2)))));
height = size(sampleimg,1);
width = size(sampleimg,2);
frame_num = size(names,2) - 3;

video = zeros(height,width,frame_num);
t = 1;
for k = 1:size(names,2)-3
    name = char(names(k));
    frame = zeros(height,width);
    if name(1) ~= '.'
        frame = imread(strcat('taxi/',char(name)));
        video(:,:,t) = frame;
        t = t + 1
    end
   
end

% compute the flux tensor trace values 
motion_blob = flux_tensor_filter(video);