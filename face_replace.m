% clc;
% clear all;

function I_final = face_replace (img1, img2, video, single_ref)


%% Init
init_pipe;
detector = buildDetector();

%% Input 

% Input image (I1)
if (video == 0)
    if (img1 == 'b')
        iter = [1,2,3,5,6,7];
        single_ip = 0;
        test_set = 1;
    elseif(img1 == 'p')
        iter = 1:7;
        single_ip = 0;
        test_set = 1;
    elseif(img1 == 'm')
        iter = 1:4;
        single_ip = 0;
        test_set = 1;
    else % For single input image
        iter = 1;
        I1= imread(img1);
        single_ip = 1;
    end
else
    % Video
    vid = VideoReader(img1);
    vidFrames = read(vid);

    h_avi = VideoWriter('result.avi');
    h_avi.FrameRate = 10;
    h_avi.open();
    iter = 1:vid.NumberOfFrames;
end

% Reference image(s) (I2)
if (single_ref == 1)
    I2 = imread(img2);
else
    %load ref_images.mat
    load(img2)
end

%%   
for i = iter
tic;
   if (video == 0 && single_ip == 0)
        % Input image(s)
        I1 = imread(strcat(img1, num2str(i), '.jpg'));
   elseif (video == 1)
       I1 = vidFrames(:,:,:,i);
   end
   
fig = i;
I_final = im2double(I1);

%% Face detector + Facial feature detection
% I1 (Input)
[ctr1, prime_face1]=extfacedescs(opts,I1,detector);
if isempty(prime_face1)
    if video == 1
        figure(1), imshow(I1,'border','tight')
        h_avi.writeVideo(getframe(gcf));
    end
    continue;
end

% I2 (Reference)
if (single_ref == 1)
    [P2big, prime_face2]=extfacedescs(opts,I2,detector);
    % Extract extra custom feature points
    P22 = fliplr(getConvHull(P2big)');
    P22 = [P2big'; P22];
else
    % Do nothing. It's loaded!
end

%% Replace I2 | P22 | prime_face2
% Loop through number of faces in input image
for face_number = 1:size(prime_face1,3)

    % Detect the extra custom ones (I1) and append it to the original  
    % Detect pose
    [P11, pose] = getConvHull(ctr1(:,:,face_number));
    P1 = [ctr1(:,:,face_number)'; fliplr(P11')];
    if (single_ref == 0)
        % Get the correspoding I2 | P22 | prime_face2 depending on pose
        I2 = I2Ref{pose,1};
        P22 = I2Ref{pose,2};
        prime_face2 = I2Ref{pose,3};
    end

    % Crop faces
    I1_face = imcrop(I1, prime_face1(:,:,face_number));
    I2_face = imcrop(I2, prime_face2);

    [m, n, ~] = size(I1_face);

    % Resize (I2 according to I1)
    % - feature points
    P2(:,1) = P22(:,1)* size(I1_face,1)/size(I2_face,1);
    P2(:,2) = P22(:,2)* size(I1_face,2)/size(I2_face,2);
    % - I2
    I2_face = imresize(I2_face, [size(I1_face,1), size(I1_face,2)]);


    %% Transformation (I2 -> I1)
    % TPS
    % I2_morphed = morph_tps_wrapper(I2_face, I1_face, P1, P2, 1, 0);

    % Triangulation
    % % Delaunay traingulation of midway shape
    % tri = delaunay((P1(:,1) + P2(:, 1))/2, (P1(:,2) + P2(:, 2))/2);
    % img_morphed2 = morph(I2_face, I1_face, P1, P2, tri, 1, 0);

    % Affine
    tform = fitgeotrans(P2,P1,'affine');
    I2_morphed = imwarp(I2_face, tform, 'OutputView', imref2d(size(I2_face)));


    %% Refinement

    % Choose width/margin of convex hull (for blending) to be 11% of distance
    % between eyes
    width = round(0.11 * norm(P1(1,:) - P1(3,:)));
    % Convex hull
    K1 = convhull(P1(:,1), P1(:,2));
    BW = poly2mask(P1(K1,1), P1(K1,2), m, n);
    % Resized polymask (smaller than BW by a margin of width)
    BW2 = bwdist(~BW) > width;

    % Recoloring: Match histogram
    I1_crop = repmat(BW, [1,1,3]) .* im2double(I1_face);
    I2_crop = repmat(BW, [1,1,3]) .* im2double(I2_morphed);
    I2_crop_recolor = imhistmatch(I2_crop, I1_crop, 256);

    % Feathering
    blurh = fspecial('gauss',width*2,width*2); % feather the border
    maska = imfilter(im2double(BW2),blurh,'replicate');
    maskb = imfilter(im2double(1 - BW2),blurh,'replicate');

    % Refined image
    I = repmat(maska, [1,1,3]) .* im2double(I2_crop_recolor) + repmat(maskb, [1,1,3])  .* im2double(I1_face);

    % Place it back in the original coordinate system
    p = prime_face1(:,:,face_number);
    I_final(p(2):p(2)+p(4), p(1):p(1)+p(3), :) = I;

end
%% Final Image plot
toc;

if (video == 1)
    figure(1), imshow(I_final,'border','tight')
    h_avi.writeVideo(getframe(gcf));
else
    figure(fig), imshow(I_final,'border','tight')
    if (test_set == 1)
        imwrite(I_final, strcat('./Results/',img1, num2str(i), '_r.jpg'));
    end
end
end

% Close video handle
if (video == 1)
    h_avi.close();
end

%% For debugging (comment these out to check individual faces)

% bbox1 = [prime_face1(1), prime_face1(2); prime_face1(1)+prime_face1(3), prime_face1(2); prime_face1(1)+prime_face1(3), prime_face1(2)+prime_face1(4); prime_face1(1), prime_face1(2)+prime_face1(4); prime_face1(1), prime_face1(2)];
% bbox2 = [prime_face2(1), prime_face2(2); prime_face2(1)+prime_face2(3), prime_face2(2); prime_face2(1)+prime_face2(3), prime_face2(2)+prime_face2(4); prime_face2(1), prime_face2(2)+prime_face2(4); prime_face2(1), prime_face2(2)];
% 
% figure(1), imshow(I1, 'border', 'tight'), hold on, plot(bbox1(:,1), bbox1(:,2));
% figure(2), imshow(I2, 'border', 'tight'), hold on, plot(bbox2(:,1), bbox2(:,2));
% 
% %%
% figure(10), imshow(I1_face, 'border', 'tight'), hold on, plot(P1(:,1), P1(:,2), '*r')
% figure(11), imshow(I2_face, 'border', 'tight'), hold on, plot(P2(:,1), P2(:,2), '*r')
% 
% %%
% figure(3), imshow(I1_crop, 'border', 'tight')
% figure(4), imshow(I2_crop, 'border', 'tight')
% %%
% 
% figure(5), imshow(I2_crop_recolor, 'border', 'tight')
% 
% %%
% 
% % figure(6), imshow(Itemp, 'border', 'tight')
% 
% %%
% figure(7), imshow(I, 'border', 'tight')
% 
% %%
% figure(8), imshow(I_final, 'border', 'tight') 


%% Resize images
% 
% I = imread('me_LL2.JPG');
% I = imresize(I, [500 500]);
% I = imrotate(I, -90);
% imwrite(I, 'me_LL2.jpg')
% imshow(I)
% %%
% pause;
% close all;

%%

