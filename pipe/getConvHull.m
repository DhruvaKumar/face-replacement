function [corner_points, pose] = getConvHull(points)

% INPUT : FEATURE POINTS (2x9xn) output(PTS) of extfacedescs
% OUTPUT : CORNER_POINTS (2x8xn) convex hull points adjusted to pose
% n = number of faced detected

nose_center = mean(points(:,5:7),2);
% nose_center = mean([points(:,5) points(:,7)],2);
eye_center = mean(points(:,2:3),2);
mouth_center = mean(points(:,8:9),2);
% centers = [nose_center eye_center];

% make eye_center as the origin , then caluclate theta
nose_center_std = nose_center - eye_center;
theta_align = atan2d(nose_center_std(1),nose_center_std(2));
theta_noseCenter_rightEye = atan2d(points(1,4)-nose_center(1,1),points(2,4)-nose_center(2,1))-theta_align;
theta_mouthCenter_rightEye = atan2d(points(1,4)-mouth_center(1,1),points(2,4)-mouth_center(2,1))-theta_align;

inter_eye = norm(points(:,2) - points(:,3));
inter_nose_mouth = norm(nose_center-mouth_center);
inter_mouth = norm(points(:,8) - points(:,9));
eye_length = norm(points(:,1)-points(:,2));

% detect a rough estimate for pose
% pose = 1 if head oriented towards right, 0 if center, -1 if left
left_dist = abs(points(1,1)-points(1,8));       % dist between leftmost eye and mouth point
right_dist = abs(points(1,4)-points(1,9));      % dist between rightmost eye and mouth point
pose_ratio = left_dist/right_dist;
pose = 2; s = 'FRONTAL';
if (pose_ratio<0.5 || pose_ratio>=1.5 && theta_align ~= 0)
    if (pose_ratio>1 && theta_align > 8.5)
        pose = 3;
%         fprintf('RIGHT\n');
        s = 'Right';
    elseif (pose_ratio<0.5 && theta_align < -8.5)
        pose = 1;
%         fprintf('LEFT\n');
        s = 'Left';
    end
else
    pose = 2;
%     fprintf('FRONTAL\n');
    s = 'Frontal';
end

%% estimate the points required for a proper convex hull
% face_size = max(prime_face(1,3),prime_face(1,4));
scale_lower = 1.25;
scale_upper = 1.0;
scale_mouth_right = 0.9;
scale_mouth_left = 0.9;
scale_eye_left = 0.5;
scale_eye_right = 0.5;
scale_eye_right_upper = 0.8;
scale_eye_left_upper = 0.8;

upper_a = 2;
if upper_a == 1
    upper_angle = theta_noseCenter_rightEye;
else
    upper_angle = theta_mouthCenter_rightEye;
end

upper_point = [eye_center(2,1)-scale_upper*inter_eye*cos(deg2rad(theta_align)) ; ...
                eye_center(1,1)-scale_upper*inter_eye*sin(deg2rad(theta_align))];
            
lower_point = [mouth_center(2,1)+scale_lower*inter_nose_mouth*cos(deg2rad(theta_align)) ;...
                mouth_center(1,1)+scale_lower*inter_nose_mouth*sin(deg2rad(theta_align))];
            
mouth_right = [points(2,9)+scale_mouth_right*inter_mouth*sin(deg2rad(theta_align))/4 ; ...
                points(1,9)+scale_mouth_right*inter_mouth*cos(deg2rad(theta_align))/4];
            
mouth_left = [points(2,8)-scale_mouth_left*inter_mouth*sin(deg2rad(theta_align))/4 ; ...
                points(1,8)-scale_mouth_left*inter_mouth*cos(deg2rad(theta_align))/4];

eye_left = [points(2,1)-scale_eye_left*eye_length*sin(deg2rad(theta_align)); ...
                points(1,1)-scale_eye_left*eye_length*cos(deg2rad(theta_align))];

eye_right = [points(2,4)+scale_eye_right*eye_length*sin(deg2rad(theta_align)); ...
                points(1,4)+scale_eye_right*eye_length*cos(deg2rad(theta_align))];

eye_right_upper = [points(2,4)-scale_eye_right_upper*eye_length*sin(deg2rad(upper_angle)); ...
                points(1,4)-scale_eye_right_upper*eye_length*cos(deg2rad(upper_angle))];
            
eye_left_upper = [points(2,1)-scale_eye_left_upper*eye_length*sin(deg2rad(upper_angle)); ...
                points(1,1)+scale_eye_left_upper*eye_length*cos(deg2rad(upper_angle))];
            
corner_points = [upper_point lower_point mouth_left mouth_right eye_left eye_right ...
                    eye_right_upper eye_left_upper];

%% discard the points which get out of the face due to pose
if (pose == 1)                             % pose = left
%     fprintf('LEFT\n');
    corner_points(:,5) = flip(points(:,1));       % retain leftmost eye point
    corner_points(:,3) = flip(points(:,8));       % retain left mouth point
    corner_points(2,8) = points(1,1);
    
elseif (pose == 3)                          % pose = left
%     fprintf('RIGHT\n');
    corner_points(:,6) = flip(points(:,4));       % retain rightmostmost eye point
    corner_points(:,4) = flip(points(:,9));       % retain right mouth point
    corner_points(2,7) = points(1,4);    
    
elseif (pose == 2)                          % pose = frontal
    if theta_align < -10                    % face rotated left
        corner_points(2,8) =  points(1,1);
        corner_points(:,5) = flip(points(:,1));
    elseif theta_align > 10                 % face rotated right
        corner_points(2,7) = points(1,4);
        corner_points(:,6) = flip(points(:,4)); 
    end
end
fprintf('%s Pose of the face detected\n',s);
end