function [mask] = textureSeg(I)
%TEXTURESEG Summary of this function goes here
%   Detailed explanation goes here


E = entropyfilt(I);
S = stdfilt(I,ones(9));
R = rangefilt(I,ones(9));


Eim = rescale(E);
Sim = rescale(S);

% figure;montage({Eim,Sim,R},'Size',[1 3],'BackgroundColor','w',"BorderSize",20)
% title('Texture Images Showing Local Entropy, Local Standard Deviation, and Local Range')

BW1 = imbinarize(Eim,0.8);
% figure;imshow(BW1)
% title('Thresholded Texture Image')

BWao = bwareaopen(BW1,2000);
% figure;imshow(BWao)
% title('Area-Opened Texture Image')


nhood = ones(9);
closeBWao = imclose(BWao,nhood);
% figure;imshow(closeBWao)
% title('Closed Texture Image')



mask = imfill(closeBWao,'holes');
% figure;imshow(mask);
% title('Mask of Bottom Texture')



textureTop = I;
textureTop(mask) = 0;
textureBottom = I;
textureBottom(~mask) = 0;
% figure;montage({textureTop,textureBottom},'Size',[1 2],'BackgroundColor','w',"BorderSize",20)
% title('Segmented Top Texture (Left) and Segmented Bottom Texture (Right)')





end