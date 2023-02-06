function [gabormag,L] = gaborFilter(image,K_sm,numSegments,imagesSize)
%GABORFILTER Summary of this function goes here
%   Detailed explanation goes here


wavelengthMin = 4/sqrt(2);
wavelengthMax = hypot(imagesSize(1,2),imagesSize(1,1));
n = floor(log2(wavelengthMax/wavelengthMin));
wavelength = 2.^(0:(n-2)) * wavelengthMin;

deltaTheta = 45;
orientation = 0:deltaTheta:(180-deltaTheta);

g = gabor(wavelength,orientation);


Agray = imcomplement(im2single(im2gray(image)));

gabormag = imgaborfilt(Agray,g);

for i = 1:length(g)
    sigma = 0.5*g(i).Wavelength;
    gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),K_sm*sigma); 
end

X=1:imagesSize(1,2);
Y=1:imagesSize(1,1);
[X,Y] = meshgrid(X,Y);

featureSet = cat(3,Agray,gabormag,X,Y);

numPoints = imagesSize(1,1)*imagesSize(1,2);
X = reshape(featureSet,numPoints,[]);

X = bsxfun(@minus, X, mean(X));
X = bsxfun(@rdivide,X,std(X));

coeff = pca(X);
feature2DImage = reshape(X*coeff(:,1),imagesSize(1,1),imagesSize(1,2));
numSegments
L = kmeans(X,numSegments);

L = reshape(L,[imagesSize(1,1) imagesSize(1,2)]);


% gaborLabelsReshape=reshape(X,[imagesSize(1,1),imagesSize(1,2)]);


end

