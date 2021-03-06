%  SiftAndRansacRandomEps - Finds SIFT features and then use a variation 
%       of the RANSAC method to
%       calculate the best homography between the two images passed in.  
%       This variation does NOT use a set epsilon but instead randomly 
%       tries different epsilons between 1 and 20 on each iteration
%       and takes the ratio of numInliers / epsilonSize to choose best
%       Note the first image should be on the left of the right one.
%--------------------------------------------------------------------------
%   Author: Saikat Gomes
%           Steve Lazzaro
%   CS 766 - Assignment 2
%   Params: img1 - first image
%           img2 - second image
%           n - the number of points to use to calculate the homography for
%                   each RANSAC iteration
%           p - the small p value
%   
%   Returns: besthomography - the best homography calculated for the images
%                               given
%--------------------------------------------------------------------------

function [besthomography] = SiftAndRansacRandomEps(img1, img2, n, p)

threshold = 1.5; %default threshold
bigP = 0.99;
smallP = p;

if (n < 4)
    n = 4;
end

gray1 = GetGrayImageFrom3DArray(img1);
gray2 = GetGrayImageFrom3DArray(img2);
%the sift arrays will be 4 x featurenum arrays
[sift1, d1] = vl_sift(gray1);
[sift2, d2] = vl_sift(gray2);

%this gives us a 2 x matchnum array where the first row represents column
%in 1st sift feature array and 2nd row represents its matching column in
%2nd sift feature array
matcharr = vl_ubcmatch(d1, d2, threshold);
display(strcat('Number of matches: ', num2str(size(matcharr,2))));

%Remove matches that are outside of bounds of smaller image columns(this
%will fix any problem with blending in the same image at the beginning and
%end)
minColSize = size(img1,2);
if (size(img2,2) < minColSize)
    minColSize = size(img2,2);
end

MAX_OVERLAP_X = minColSize;

colNewMatches = 1;
newMatchesArr = zeros(2, size(matcharr,2));
for i=1:size(matcharr,2)
    i1=matcharr(1,i);
    i2=matcharr(2,i);

    %x1=sift1(1,i1);
    x2=sift2(1,i2);

    if(x2 < size(img2, 2) - MAX_OVERLAP_X)
        continue;
    end
    % within regions wanted
    newMatchesArr(1,colNewMatches) = i1;
    newMatchesArr(2,colNewMatches) = i2;
    colNewMatches = colNewMatches + 1;
end

matcharr = newMatchesArr(:, 1:(colNewMatches - 1));

display(strcat('Number of matches: ', num2str(size(matcharr,2))));

if (n > size(matcharr,2))
    display('n is larger than the number of feature matches, please try again');
    return;
end

%Now RANSAC method where epsilon is randomly chosen on each iteration

k = round(log(1-bigP) / log(1 - (smallP ^ n)));
display(strcat('The k is ', ' ', num2str(k)));


besthomography = zeros(3,3);
maxinliers = 0;
for i = 1:k
    epsilon = rand(1)*19 + 1;
    [points, idx] = datasample(matcharr,n,2); %get n random points
    %these will be 2 x n arrays of the points used for computing the
    %homography matrix
    firstPoints = zeros(2,n);
    secondPoints = zeros(2,n);
    for j = 1:size(points,2);
        firstPoints(:,j) = sift1(1:2, points(1,j));
        secondPoints(:,j) = sift2(1:2, points(2,j));
    end
    homography = ComputeHomography(firstPoints, secondPoints);
    currinliers = 0;
    %now iterate through all of matches and find the num of inliers
    for index = 1:size(matcharr,2)
        point1 = zeros(3);
        point1(1:2) = sift1(1:2, matcharr(1, index));
        point1(3) = 1;
        
        point2predicted = homography * point1;
        
        point2 = zeros(3);
        point2(1:2) = sift2(1:2, matcharr(2, index));
        point2(3) = 1;
        
        dist = norm(point2predicted - point2);
        if (dist < epsilon) 
            currinliers = currinliers + 1;
        end
    end
    currinliers = currinliers / epsilon;
    
    if (currinliers > maxinliers)
        maxinliers = currinliers;
        besthomography = homography;
    end
end
display(strcat('The maximum inlier ratio is ', num2str(maxinliers)));


end

