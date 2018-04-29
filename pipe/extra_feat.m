function [corner_points] = extra_feat(points, prime_face)

% Given facial feat detected (points) and boundary box of face (prime_face)
% gives the extra points

nose_center = mean(points(:,5:7),2);
% nose_center = mean([points(:,5) points(:,7)],2);
eye_center = mean(points(:,2:3),2);
mouth_center = mean(points(:,8:9),2);
centers = [nose_center eye_center];

% make eye_center as the origin , then caluclate theta
nose_center_std = nose_center - eye_center;
theta = atan2d(nose_center_std(1),nose_center_std(2));

inter_eye = norm(points(:,2) - points(:,3));
inter_nose_mouth = norm(nose_center-mouth_center);
inter_mouth = norm(points(:,8) - points(:,9));
eye_length = norm(points(:,1)-points(:,2));

% detect a rough estimate for pose
% pose = 1 if head oriented towards right, 0 if center, -1 if left
left_dist = abs(points(1,1)-points(1,8));
right_dist = abs(points(1,4)-points(1,9));
pose_ratio = left_dist/right_dist;

% if (pose_ratio<=0.5 || pose_ratio>=1.5)
%     if (pose_ratio>1)
%         pose = 1;
% %         fprintf('RIGHT\n');
%         s = 'RIGHT';
%     else
%         pose = -1;
% %         fprintf('LEFT\n');
%         s = 'LEFT';
%     end
% else
%     pose = 0;
% %     fprintf('FRONTAL\n');
%     s = 'FRONTAL';
% end

% hold on;
face_size = max(prime_face(1,3),prime_face(1,4));
%line(centers(1,:),centers(2,:));

scale_lower = 1.25;
scale_upper = 1.0;
scale_mouth_right = 0.9;
scale_mouth_left = 0.9;
scale_eye_left = 0.5;
scale_eye_right = 0.5;


upper_point = [eye_center(2,1)-scale_upper*inter_eye*cos(deg2rad(theta)) ; ...
                eye_center(1,1)-scale_upper*inter_eye*sin(deg2rad(theta))];
            
lower_point = [mouth_center(2,1)+scale_lower*inter_nose_mouth*cos(deg2rad(theta)) ;...
                mouth_center(1,1)+scale_lower*inter_nose_mouth*sin(deg2rad(theta))];
            
mouth_right = [points(2,9)+scale_mouth_right*inter_mouth*sin(deg2rad(theta))/4 ; ...
                points(1,9)+scale_mouth_right*inter_mouth*cos(deg2rad(theta))/4];
            
mouth_left = [points(2,8)-scale_mouth_left*inter_mouth*sin(deg2rad(theta))/4 ; ...
                points(1,8)-scale_mouth_left*inter_mouth*cos(deg2rad(theta))/4];

eye_left = [points(2,1)-scale_eye_left*eye_length*sin(deg2rad(theta)); ...
                points(1,1)-scale_eye_left*eye_length*cos(deg2rad(theta))];

eye_right = [points(2,4)+scale_eye_right*eye_length*sin(deg2rad(theta)); ...
                points(1,4)+scale_eye_right*eye_length*cos(deg2rad(theta))];

corner_points = [upper_point lower_point mouth_right mouth_left eye_left eye_right];


end