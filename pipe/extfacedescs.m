function [PTS, face]=extfacedescs(opts,img,detector)

PTS = 0; face = 0;
if ischar(img)
    I=imread(img);
else
    I = img;
end
%% sexy face detector
% detector = buildDetector();
bbox = detectFaceParts(detector,I,2);
face = bbox(:,1:4);
face = flip(sortrows(face,4),1);
face = [face bsxfun(@times,face(:,3),face(:,4));];
if ~isempty(face)
    
    
    % face
    %% Outlier rejection % can only remove extreme large outliers
    if size(face,1) > 5
        outliers = 1;
        while outliers == 1;     
            if (std(face(:,5)) - std(face(2:end,5)) > std(face(2:end,5)))
                face(1,:) = [];
            else
                outliers = 0;
            end
        end
    end
    face(:,5) =[];
    %%
    DETS = zeros(size(face,1),4)';
    for choose = 1:size(face,1);
        DETS(:,choose) = [face(choose,1)+face(choose,3)/2; face(choose,2)+face(choose,4)/2; max(face(choose,3),face(choose,4))/2; 1.0];
    end
    % face = reshape(face,[1 4 size(face,1)]);
    %%
    % face
    PTS=zeros(0,0,size(DETS,2));
    for i=1:size(DETS,2)
        P=findparts(opts.model,I,DETS(:,i));
        PTS(1:size(P,1),1:size(P,2),i)=P;   
    end
    face = reshape(face',[1 4 size(face,1)]);

    PTS = bsxfun(@minus,PTS,permute(face(1,1:2,:),[2 1 3]));
end

end

