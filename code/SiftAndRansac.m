function [besthomography] = SiftAndRansac(img1, img2, n, epsilon, p)
%UNTITLED Summary of this function goes here
%   the images are 2 rgb image arrays
%   the second image entered should be the panorama

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

%Now RANSAC method

k = round(log(1-bigP) / log(1 - (smallP ^ n)));
display(strcat('k: ', num2str(k)));


besthomography = zeros(3,3);
maxinliers = 0;
for i = 1:k
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
    clear inlierpoints1;
    clear inlierpoints2;
    currinliers = 0;
    %now iterate through all of matches and find the num of inliers..i.e.
    %the score for the current homography
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
            inlierpoints1(1:2,currinliers) = point1(1:2);
            inlierpoints2(1:2,currinliers) = point2(1:2);
        end
    end
    
    if (currinliers > maxinliers)
        maxinliers = currinliers;
        refinedhomography = ComputeHomography(inlierpoints1,inlierpoints2);
        besthomography = refinedhomography;
    end
end

display(strcat('The maximum number of inliers: ', num2str(maxinliers)));

end

