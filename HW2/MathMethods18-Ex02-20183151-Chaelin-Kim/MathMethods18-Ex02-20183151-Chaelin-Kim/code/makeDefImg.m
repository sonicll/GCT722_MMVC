function [ defImg ] = makeDefImg( originImg, defCoord )
%MAKEDEFIMG 이 함수의 요약 설명 위치
%   자세한 설명 위치
[rows, columns, numOfColorChannels] = size(originImg);
[X, Y] = meshgrid(1:columns, 1:rows);
reshapeImg = reshape(originImg, rows*columns, numOfColorChannels);

defImg = uint8(zeros(rows, columns, numOfColorChannels));
for itr = 1:numOfColorChannels
    defImg(:,:,itr) = uint8(griddata(defCoord(:,1), defCoord(:,2), double(reshapeImg(:,itr)), X, Y));
end

end

