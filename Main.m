 
clear all
close all
clc


% path to the data set
path = 'C:\Users\Nekta\Documents\Matlab Git Projects\AI\';
cd (path)
imgDirTest = 'Assignment data\data\images\test\';
imgDirVal='Assignment data\data\images\val\';
gtDir = 'Assignment data\data\groundTruth\test\';
D= dir(fullfile([path imgDirTest],'*.jpg'));
 



%Filter and Segmentation Tuning Values
numSegments=3;
K_sm= 2;
fuzzyExponent=2;
listIndex=13;

% Choose images
for i =1:listIndex %numel(D)
IMG = imread ([path imgDirTest D(i).name(1:end-4) '.jpg']);
% figure, imshow(IMG);
title([D(i).name(1:end-4) '.jpg'])
GT = load([path gtDir D(i).name(1:end-4) '.mat']);
% figure ('name', ['Ground truth for ' D(i).name(1:end-4) '.jpg']) 
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k=1:1
segmentsGT = double(GT.groundTruth{k}.Segmentation);
% subplot(2,3,k)
imagesc(segmentsGT)
title(num2str(k))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number of Clusters GT
[unqGT,~,id] = unique(segmentsGT);
out = unqGT(accumarray(id(:),1)>1);
segmNumGT=length(out)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% STart Image Segmentation
RGB=IMG;
figure;imshow(RGB);




%Get Image Size
imagesSize=size(RGB(:,:,1));

%Guassian Smoothing for noise bluring
RGB=imgaussfilt(RGB,6);



%Convert RGB to LAB and Remove Luminance and increase contrast  
LAB=rgb2lab(RGB);
LAB=imfill(LAB);
LAB(:,:,1)=zeros(imagesSize(1),imagesSize(2));
LAB=imadjust(LAB,stretchlim(LAB));

figure;imshow(LAB);

%Convert to HSV and increase contrast 
HSV=rgb2hsv(RGB);
HSV=imadjust(HSV,stretchlim(HSV));



% Texture information extraction 
mask=textureSeg(im2gray(IMG));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % Texture information extraction using Gabor filters

% [gaborMag,L]=gaborFilter((IMG),K_sm,numSegments,imagesSize);
% figure;montage(gaborMag,"Size",[4 6])
% figure;imshow(imfill(label2rgb(L)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





% Concatenate diffrent Color maps and Texture information
Features=cat(3,LAB,HSV);


%Dimensions of Features fed into segmentation algorithms 
[x, y, dimn]=size(Features);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%FCM Clustering Algorithm 
[segmentationMask,centers]=clusterFCM(Features,numSegments,fuzzyExponent,imagesSize);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Layover = labeloverlay(IMG,imfill(segmentationMask));

figure;imshow(Layover);






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %Kmeans Plus

% 
% % % Reshape into 1D
featureRESHAPE=reshape(Features,[imagesSize(1)*imagesSize(2),dimn]);

[segmentationMask,centers]=(kmeans((featureRESHAPE),numSegments,"Start", 'plus'));


distance = dist(centers,featureRESHAPE');
[~,indexDistance] = min(distance',[],2);
outimgindx=reshape(indexDistance,imagesSize(1),imagesSize(2)); % pixel indexed image

% % % Kmeans Plus Mask
segmentationMask=outimgindx;
[segmentationMask,centers]=(imsegkmeans(uint8(Features),numSegments,"NormalizeInput",true));
segmentationMask=double(segmentationMask);
centers=double(centers);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



clusterDissimilarity(IMG,centers);


Layover = labeloverlay(IMG,segmentationMask);
Layover = labeloverlay(IMG,imfill(segmentationMask));

figure;imshow(Layover);
title("Labeled Image") 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of Clusters Segmentation ALgo
[unqSA,~,id] = unique(segmentationMask);
out = unqSA(accumarray(id(:),1)>1);
segmNumSA=length(out);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% compareSegments(IMG,segmentationMask,segmentsGT,imagesSize,segmNumGT,unqGT,segmNumSA,unqSA);






    



%% 



% Ncs = 10;
% 
% interClusterDistances = zeros(1, Ncs);
% 
% for k1 = 1: Ncs
%     [clust, centers] = kmeans(Features,k1,"Start", 'plus');
%     for k2= 1:k1
%         interClusterDistances(k1) = interClusterDistances(k1) + sum(sum((meas(find(clust==k2),:)-centers(k2,:)).^2));
%     end
% end
% distMeasure = sqrt(interClusterDistances);
% 
% straightLine = linspace(max(distMeasure),min(distMeasure), 10);
% figure, plot(1:Ncs, straightLine, 'm-o', 1:Ncs, distMeasure, 'b-o')
% xlabel('Number of clusters'), ylabel('Objective function value')
% 
% figure, plot(1:Ncs, straightLine - distMeasure)
% 
%     
    
    
    