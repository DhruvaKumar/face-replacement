
% reqToolboxes = {'Computer Vision System Toolbox', 'Image Processing Toolbox'};
% if( ~checkToolboxes(reqToolboxes) )
%  error('detectFaceParts requires: Computer Vision System Toolbox and Image Processing Toolbox. Please install these toolboxes.');
% end

img = imread('6.jpg');

detector = buildDetector();
[bbox bbimg faces bbfaces] = detectFaceParts(detector,img,2);
% bbox = flip(sortrows(bbox,3),1);
% bbox = bbox(1,:);
%Output parameters:
% bbox: bbox(:, 1: 4) is bounding box for face
%       bbox(:, 5: 8) is bounding box for left eye
%       bbox(:, 9:12) is bounding box for right eye
%       bbox(:,13:16) is bounding box for mouth
%       bbox(:,17:20) is bounding box for nose

%% CHOOSE feats lefteye = 1, righteye = 2; nose = 3, mouth = 4;
% choose = 4;
% u = img(bbox(1,4*choose+2):bbox(1,4*choose+2)+bbox(1,4*choose+4),...
%         bbox(1,4*choose+1):bbox(1,4*choose+1)+bbox(1,4*choose+3));
%     
% % Detect SURF features detectFASTFeatures, detectHarrisFeatures, ...
%  % detectMinEigenFeatures, detectMSERFeatures or detectSURFFeatures.
%  
% % detectMinEigenFeatures works brilliantly for eyes
% ftrs = detectSURFFeatures(u);
% %Plot facial features.
% imshow(u);hold on; plot(ftrs);


%%


% figure;imshow(bbimg);
% for i=1:size(bbfaces,1)
%  figure;imshow(bbfaces{i});
% end

% Please uncoment to run demonstration of detectRotFaceParts
%{
 img = imrotate(img,180);
 detector = buildDetector(2,2);
 [fp bbimg faces bbfaces] = detectRotFaceParts(detector,img,15,2);

 figure;imshow(bbimg);
 for i=1:size(bbfaces,1)
  figure;imshow(bbfaces{i});
 end
%}
