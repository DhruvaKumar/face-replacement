%% Face replacement!

clc;
clear all;

%% To replace faces, call face_replace(img1, img2, video, single_ref)
% ============ Parameters   ============

% % img1 = The input image whose faces have to be replaced by img2
% % img2 = The reference image wwhich contains the replacing face
% % video = Boolean parameter to set if img1 is image | video 
% % single_ref = Boolean parameter to set if single reference image (img2) or reference face library

% ============ Examples ============
%% Replace all the 'Blend' images by face_library
face_replace('b', 'ref_images', 0, 0);

%% Replace all the 'Pose' images by face_library
face_replace('p', 'ref_images', 0, 0);

%% Replace all the 'More' images by a single image, say 'b3.jpg'
face_replace('m', 'b3.jpg', 0, 1);

%% Replace single 'b3.jpg' by a single image, say 'b5.jpg'
face_replace('b3.jpg', 'b5.jpg', 0, 1);

%% Replace video 'videoclip.avi' by the face_library
% The video is saved as 'result.avi'
face_replace('videoclip.avi', 'ref_images', 1, 0);

% face_replace('sherlock_10fps.avi', 'ref_images', 1, 0);

%% Runs replacement on the official test set and saves results in ./TestSet 

face_replace('b', 'ref_images', 0, 0);
face_replace('p', 'ref_images', 0, 0);
face_replace('m', 'ref_images', 0, 0);