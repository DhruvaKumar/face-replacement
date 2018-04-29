init_pipe;
%% sexy feature localization
%[PTS1, prime_face1]=extfacedescs(opts,'PHOTO.JPG',true, 1);
[PTS2, prime_face2]=extfacedescs(opts,'b3.jpg',true, 2);

% nose_center = mean(PTS(:,5:7),2);
% eye_center = mean(PTS(:,2:3),2);
% centers = [nose_center eye_center];
% nose_center_std = nose_center - eye_center;
% 
% atan2d(nose_center_std(1),nose_center_std(2))

% hold on;

% line(centers(1,:),centers(2,:));
%%
im1 = imread('PHOTO.JPG');
im2 = imread('b3.jpg');
% bbox1 = [prime_face1(1), prime_face1(2); prime_face1(1)+prime_face1(3), prime_face1(2); prime_face1(1)+prime_face1(3), prime_face1(2)+prime_face1(4); prime_face1(1), prime_face1(2)+prime_face1(4); prime_face1(1), prime_face1(2)];
% bbox2 = [prime_face2(1), prime_face2(2); prime_face2(1)+prime_face2(3), prime_face2(2); prime_face2(1)+prime_face2(3), prime_face2(2)+prime_face2(4); prime_face2(1), prime_face2(2)+prime_face2(4); prime_face2(1), prime_face2(2)];
% 
% figure(3), imshow(im1), hold on, plot(bbox1(:,1), bbox1(:,2));
% figure(4), imshow(im2), hold on, plot(bbox2(:,1), bbox2(:,2));
im1_face = imcrop(im1, prime_face1); im1_pts = PTS1' - repmat([prime_face1(1), prime_face1(2)], [length(PTS1),1]);
im2_face = imcrop(im2, prime_face2); im2_pts = PTS2' - repmat([prime_face2(1), prime_face2(2)], [length(PTS2),1]);

% Resize faces & control points
% Better rounding off? Control points resizing?
cpts = zeros(size(im1_face,1), size(im1_face,2));
lInd= sub2ind(size(cpts), round(im1_pts(:,2)), round(im1_pts(:,1)));
cpts(lInd) = 1;

m = size(im2_face,1); n = size(im2_face,2);
im1_face = imresize(im1_face, [m, n]);
cpts = imresize(cpts, [m,n]);
temp = sort(reshape(cpts, [numel(cpts),1]),'descend');
cpts = cpts > temp(length(im1_pts)+1);

[im1_ptss(:,2), im1_ptss(:,1)] = find(cpts);

figure(1), imshow(im1_face)
figure(2), imshow(cpts)
%%
figure(3), imshow(im1_face), hold on, plot(im1_ptss(:,1), im1_ptss(:,2), '*r'), hold off;
figure(4), imshow(im2_face), hold on, plot(im2_pts(:,1), im2_pts(:,2), '*r'), hold off;
%% tps?
% im1 = imread('PHOTO.JPG');
% im2 = imread('b3.jpg');

img_morphed = morph_tps_wrapper(im1_face, im2_face, im1_ptss, im2_pts, 1, 0);
