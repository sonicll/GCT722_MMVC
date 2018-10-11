clear;

%% Initial Setting
ginger = imread('../materials/ginger.png');

[rows, columns, numberOfColorChannels] = size(ginger);

sourceCP = [[166, 55]; [40, 157]; [175, 185]; [270, 157]; [335, 157]; ...
            [181, 262]; [118, 369]; [252, 369]];
targetCP = [[166, 55]; [8, 268]; [175, 185]; [271, 111]; [338, 57]; ...
            [160, 266]; [147, 369]; [272, 369]];

[X, Y] = meshgrid(1:columns, 1:rows);

weight_alpha = 1;

%% Affine Transformation
% Calculate weight
weight = zeros(rows, columns, size(sourceCP, 1));
for itr=1:size(sourceCP, 1)
%     temp_x = sourceCP(itr, 1) - X;
%     temp_y = sourceCP(itr, 2) - Y;
%     weight(:,:,itr, 1) = 1./ sqrt(temp_x.^2 + temp_y.^2).^(2 * weight_alpha);
    v = reshape([X Y], [], 2);
    weightNorm = zeros(size(v));
    for itr2=1:size(v, 1)
        weightNorm(itr2) = 1./ norm(sourceCP(itr,:) - v(itr2, :), 2 * weight_alpha);
    end
    weight(:,:,itr) = reshape(weightNorm(:,1), [rows, columns, 1]);
end

% Calculate p_star & q_star
weightSum = sum(weight,3);

% p_star
weightp = {zeros(rows, columns, size(sourceCP, 1)), zeros(rows, columns, size(sourceCP, 1))};
for itr=1:size(sourceCP,1)
    weightp{1}(:,:,itr) = weight(:,:,itr)*sourceCP(itr, 1);
    weightp{2}(:,:,itr) = weight(:,:,itr)*sourceCP(itr, 2);
end

weightpSum = {sum(weightp{1}, 3), sum(weightp{2}, 3)};

p_star = {weightpSum{1}./weightSum, weightpSum{2}./weightSum};
 
% q_star
weightq = {zeros(rows, columns, size(targetCP, 1)), zeros(rows, columns, size(targetCP, 1))};
for itr=1:size(targetCP,1)
    weightq{1}(:,:,itr) = weight(:,:,itr)*targetCP(itr, 1);
    weightq{2}(:,:,itr) = weight(:,:,itr)*targetCP(itr, 2);
end

weightqSum = {sum(weightq{1}, 3), sum(weightq{2}, 3)};

q_star = {weightqSum{1}./weightSum, weightqSum{2}./weightSum};

% p_hat
p_hat = {zeros(rows, columns, size(sourceCP, 1)), zeros(rows, columns, size(sourceCP, 1))};
for itr=1:size(sourceCP, 1)
    p_hat{1}(:,:,itr) = sourceCP(itr, 1) - p_star{1};
    p_hat{2}(:,:,itr) = sourceCP(itr, 1) - p_star{2};
end

% q_hat
q_hat = {zeros(rows, columns, size(targetCP, 1)), zeros(rows, columns, size(targetCP, 1))};
for itr=1:size(targetCP, 1)
    q_hat{1}(:,:,itr) = targetCP(itr, 1) - q_star{1};
    q_hat{2}(:,:,itr) = targetCP(itr, 1) - q_star{2};
end

% Precompute fa(v) -> compute Aj
% phat^T * w * phat
% Though this solution requires the inversion of a matrix, the matrix is a contant size (2X2)
invMat = zeros(2, 2);

% Aj is a single scalar


%% Similarity Transformation

%% Rigid Transformation

%% Show the original image and result images
% figure('units','pixels','pos',[100 100 ((columns * 2) + 30) ((rows * 2) + 30)])
% subplot(2, 2, 1);
% image(ginger)
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

%% subplot
% subplot(2, 2, 2);
% imshow(ginger)
% title('Affine Transform')
% subplot(2, 2, 3);
% imshow(ginger)
% title('Similarity Transform')
% subplot(2, 2, 4);
% imshow(ginger)
% title('Rigid Transform')