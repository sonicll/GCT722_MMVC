clear;

%% Initial Setting
ginger = imread('../materials/ginger.png');

[rows, columns, numberOfColorChannels] = size(ginger);

sourceCP = [[166, 55]; [40, 157]; [175, 185]; [270, 157]; [335, 157]; ...
            [181, 262]; [118, 369]; [252, 369]];
targetCP = [[166, 55]; [8, 268]; [175, 185]; [271, 111]; [338, 57]; ...
            [160, 266]; [147, 369]; [272, 369]];

[X, Y] = meshgrid(1:columns, 1:rows);
v = reshape([X Y], [], 2);
vLength = size(v,1);

weight_alpha = 1.1;

%% Affine Transformation
% Calculate weight
weight = zeros(size(v, 1), size(sourceCP, 1));
for itr=1:size(sourceCP, 1)
    dis_x = sourceCP(itr, 1) - v(:,1);
    dis_y = sourceCP(itr, 2) - v(:,2);
    weight(:, itr) = 1./ sqrt(dis_x.^2 + dis_y.^2).^(2 * weight_alpha);
end
weight(weight==inf) = 1;

% Calculate p_star & q_star
weightSum = sum(weight,2);

% p_star
wp = zeros(vLength, 2, size(sourceCP, 1));
for itr=1:size(sourceCP,1)
    wp(:,1,itr) = weight(:,itr).*sourceCP(itr, 1);
    wp(:,2,itr) = weight(:,itr).*sourceCP(itr, 2);
end

wpSum = sum(wp,3);

pstar = [wpSum(:,1)./weightSum, wpSum(:,2)./weightSum];
 
% q_star
wq = zeros(size(v,1), 2, size(targetCP, 1));
for itr=1:size(targetCP,1)
    wq(:,1,itr) = weight(:,itr).*targetCP(itr, 1);
    wq(:,2,itr) = weight(:,itr).*targetCP(itr, 2);
end

wqSum = sum(wq, 3);

qstar = [wqSum(:,1)./weightSum, wqSum(:,2)./weightSum];

% p_hat
phat = zeros(size(v,1), 2, size(sourceCP,1));
for itr=1:size(sourceCP, 1)
    phat(:,1,itr) = sourceCP(itr, 1) - pstar(:,1);
    phat(:,2,itr) = sourceCP(itr, 2) - pstar(:,2);
end

% q_hat
qhat = zeros(size(v,1), 2, size(targetCP,1));
for itr=1:size(targetCP, 1)
    qhat(:,1,itr) = targetCP(itr, 1) - qstar(:,1);
    qhat(:,2,itr) = targetCP(itr, 2) - qstar(:,2);
end

% Precompute fa(v) -> compute Aj
% phat^T * w * phat
% Though this solution requires the inversion of a matrix, the matrix is a contant size (2 X 2)
phatTWphat = zeros(2, 2, size(v,1), size(sourceCP, 1));
wphatT = zeros(2, size(v,1), size(targetCP,1));
for itr=1:size(sourceCP, 1)
    for itr2=1:size(v, 1)
        phatTWphat(:,:,itr2,itr) = phat(itr2,:,itr)' * weight(itr2,itr) * phat(itr2,:,itr);
    end
    wphatT(:, :, itr) = (weight(:,itr).*phat(:,:,itr))';
end

phatTwphatSum = sum(phatTWphat, 4);

invphatTwphatSum = zeros(2, 2, size(v,1));
for itr=1:size(v, 1)
    invphatTwphatSum(:,:,itr) = inv(phatTwphatSum(:,:,itr));
end

vSubpstar = [v(:,1)-pstar(:,1), v(:,2)-pstar(:,2)];

% Aj is a single scalar
A = zeros(size(v, 1), size(targetCP, 1));
for itr=1:size(targetCP, 1)
    for itr2=1:size(v, 1)
        A(itr2, itr) = vSubpstar(itr2,:)*invphatTwphatSum(:,:,itr2)*wphatT(:,itr2,itr);
    end
end
qhat_reshape_x = reshape(qhat(:,1,:), size(v,1), size(targetCP,1));
qhat_reshape_y = reshape(qhat(:,2,:), size(v,1), size(targetCP,1));
affineDef = [sum(A.* qhat_reshape_x, 2) + qstar(:,1), sum(A.* qhat_reshape_y, 2) + qstar(:,2)];

reshapeGinger = reshape(ginger, size(v, 1), numberOfColorChannels);
affineGinger = uint8(zeros(rows, columns, numberOfColorChannels));
affineGinger(:,:,1) = uint8(griddata(affineDef(:,1), affineDef(:,2), double(reshapeGinger(:,1)), X, Y));
affineGinger(:,:,2) = uint8(griddata(affineDef(:,1), affineDef(:,2), double(reshapeGinger(:,2)), X, Y));
affineGinger(:,:,3) = uint8(griddata(affineDef(:,1), affineDef(:,2), double(reshapeGinger(:,3)), X, Y));

%% Similarity Transformation

%% Rigid Transformation

%% Show the original image and result images
% figure('units','pixels','pos',[100 100 ((columns * 2) + 30) ((rows * 2) + 30)])
subplot(1, 2, 1);
imshow(ginger)
title('Original Image')
hold on;
plot(sourceCP(:, 1), sourceCP(:, 2), 'o', 'Color', 'g')
plot(targetCP(:, 1), targetCP(:, 2), 'x', 'Color', 'r')

% Select some input and output control points
% [sourceCP_x, sourceCP_y] = ginput(8);
% plot(sourceCP_x, sourceCP_y, 'o')
% [targetCP_x, targetCP_y] = ginput(8);
% plot(targetCP_x, targetCP_y, 'x')
hold off;
subplot(1, 2, 2);
imshow(affineGinger)
title('Affine Transform')
hold on;
plot(sourceCP(:, 1), sourceCP(:, 2), 'o', 'Color', 'g')
plot(targetCP(:, 1), targetCP(:, 2), 'x', 'Color', 'r')
hold off;
%% subplot
% subplot(2, 2, 3);
% imshow(ginger)
% title('Similarity Transform')
% subplot(2, 2, 4);
% imshow(ginger)
% title('Rigid Transform')