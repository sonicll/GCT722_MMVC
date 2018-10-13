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
vLen = size(v,1);

weightAlpha = 1.1;

%% Calculate weight, star, hat
% Calculate weight
weight = zeros(vLen, size(sourceCP, 1));
for itr=1:size(sourceCP, 1)
    dis_x = sourceCP(itr, 1) - v(:,1);
    dis_y = sourceCP(itr, 2) - v(:,2);
    weight(:, itr) = 1./ sqrt(dis_x.^2 + dis_y.^2).^(2 * weightAlpha);
end
weight(weight==inf) = 1;

% Calculate pstar & phat
pstar = calStar(weight, vLen, sourceCP);
phat = calHat(vLen, sourceCP, pstar);
 
% Calculate qstar & qhat
qstar = calStar(weight, vLen, targetCP);
qhat = calHat(vLen, targetCP, qstar);

%% Affine Transformation
% affineDeformCoord = doAffineDeform(weight, v, sourceCP, targetCP, pstar, phat, qstar, qhat);
% 
% reshapeGinger = reshape(ginger, size(v, 1), numberOfColorChannels);
% affineImg = uint8(zeros(rows, columns, numberOfColorChannels));
% affineImg(:,:,1) = uint8(griddata(affineDeformCoord(:,1), affineDeformCoord(:,2), double(reshapeGinger(:,1)), X, Y));
% affineImg(:,:,2) = uint8(griddata(affineDeformCoord(:,1), affineDeformCoord(:,2), double(reshapeGinger(:,2)), X, Y));
% affineImg(:,:,3) = uint8(griddata(affineDeformCoord(:,1), affineDeformCoord(:,2), double(reshapeGinger(:,3)), X, Y));

%% Similarity Transformation
mphat_ortho = zeros(size(phat));
for itr=1:size(sourceCP, 1)
    mphat_ortho(:,1,itr) = -phat(:,2,itr);
    mphat_ortho(:,2,itr) = phat(:,1,itr);
end

pMatrix = zeros(2, 2, vLen, size(sourceCP, 1));
for itr=1:size(sourceCP,1)
    for itr2=1:vLen
        pMatrix(1,:,itr2,itr) = phat(itr2,:,itr);
        pMatrix(2,:,itr2,itr) = -mphat_ortho(itr2,:,itr);
    end
end

vSubpstar = [v(:,1)-pstar(:,1), v(:,2)-pstar(:,2)];
mvSubpstar_ortho = [-vSubpstar(:,2) vSubpstar(:,1)];

vSubpMatrix = zeros(2, 2, vLen);
for itr=1:vLen
    vSubpMatrix(1,:,itr) = vSubpstar(itr,:);
    vSubpMatrix(2,:,itr) = -mvSubpstar_ortho(itr,:);
end

wphatphatT = zeros(vLen, size(sourceCP, 1));
for itr=1:size(sourceCP, 1)
    for itr2=1:vLen
        wphatphatT(itr2,itr) = weight(itr2,itr) * phat(itr2,:,itr) * phat(itr2,:,itr)';
    end
end
myus = sum(wphatphatT, 2);

A = zeros(2, 2, vLen, size(sourceCP, 1));
myusA = zeros(2, 2, vLen, size(sourceCP, 1));
for itr=1:size(sourceCP, 1)
    for itr2=1:vLen
        A(:,:,itr2,itr) = weight(itr2, itr).* pMatrix(:,:,itr2,itr) * vSubpMatrix(:,:,itr2)';
        myusA(:,:,itr2,itr) = (1/myus(itr2)).* A(:,:,itr2,itr);
    end
end

qA = zeros(vLen,2,size(targetCP, 1));
for itr=1:size(targetCP,1)
    for itr2=1:vLen
        qA(itr2,:,itr) = qhat(itr2,:,itr) * myusA(:,:,itr2,itr);
    end
end

similarityDef = [sum(qA(:,1,:), 3) + qstar(:,1), sum(qA(:,2,:), 3) + qstar(:,2)];

reshapeGinger = reshape(ginger, size(v, 1), numberOfColorChannels);
similarityImg = uint8(zeros(rows, columns, numberOfColorChannels));
similarityImg(:,:,1) = uint8(griddata(similarityDef(:,1), similarityDef(:,2), double(reshapeGinger(:,1)), X, Y));
similarityImg(:,:,2) = uint8(griddata(similarityDef(:,1), similarityDef(:,2), double(reshapeGinger(:,2)), X, Y));
similarityImg(:,:,3) = uint8(griddata(similarityDef(:,1), similarityDef(:,2), double(reshapeGinger(:,3)), X, Y));

%% Rigid Transformation

%% Show the original image and result images
% figure('units','pixels','pos',[100 100 ((columns * 2) + 30) ((rows * 2) + 30)])
subplot(2, 2, 1);
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

% subplot(2, 2, 2);
% imshow(affineImg)
% title('Affine Transform')
% hold on;
% plot(sourceCP(:, 1), sourceCP(:, 2), 'o', 'Color', 'g')
% plot(targetCP(:, 1), targetCP(:, 2), 'x', 'Color', 'r')
hold off;

subplot(2, 2, 3);
imshow(similarityImg)
title('Similarity Transform')
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