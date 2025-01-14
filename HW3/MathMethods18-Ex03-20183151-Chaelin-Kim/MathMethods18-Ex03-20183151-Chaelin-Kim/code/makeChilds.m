function [ firstChild, secondChild ] = makeChilds( currentSpace, circleRad, points )
% makeChilds: split the current space into two children.

% Split the current space into two children subspaces in half along the longest dimension
if (currentSpace{3}(2) - currentSpace{3}(1)) >= (currentSpace{4}(2) - currentSpace{4}(1))
    % Split x range in half
    halfRangeX = (currentSpace{3}(2) - currentSpace{3}(1)) / 2;
    
    % Compute first child space
    firstChildSpace = {[currentSpace{3}(1), currentSpace{3}(1) + halfRangeX], [currentSpace{4}(1), currentSpace{4}(2)]};
    [fcLowerBound, fcUpperBound, ~, ~] = calBounds(firstChildSpace, circleRad, points);
    firstChild = [fcLowerBound, fcUpperBound, firstChildSpace];
    
    % Compute second child space
    secondChildSpace = {[currentSpace{3}(1) + halfRangeX, currentSpace{3}(2)], [currentSpace{4}(1), currentSpace{4}(2)]};
    [scLowerBound, scUpperBound, ~, ~] = calBounds(secondChildSpace, circleRad, points);
    secondChild = [scLowerBound, scUpperBound, secondChildSpace];
else
    % Split y range in half
    halfRangeY = (currentSpace{4}(2) - currentSpace{4}(1)) / 2;
    
    % Compute first child space
    firstChildSpace = {[currentSpace{3}(1), currentSpace{3}(2)], [currentSpace{4}(1), currentSpace{4}(1) + halfRangeY]};
    [fcLowerBound, fcUpperBound, ~, ~] = calBounds(firstChildSpace, circleRad, points);
    firstChild = [fcLowerBound, fcUpperBound, firstChildSpace];
    
    % Compute second child space
    secondChildSpace = {[currentSpace{3}(1), currentSpace{3}(2)], [currentSpace{4}(1) + halfRangeY, currentSpace{4}(2)]};
    [scLowerBound, scUpperBound, ~, ~] = calBounds(secondChildSpace, circleRad, points);
    secondChild = [scLowerBound, scUpperBound, secondChildSpace];
end

end

