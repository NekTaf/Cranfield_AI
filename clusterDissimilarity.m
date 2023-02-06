function []= clusterDissimilarity(IMG,centersCentres)
%DISSIMILARITYCLUSTERS Summary of this function goes here
%   Detailed explanation goes here





Ims=double(IMG);

n_sample = size(Ims,1);
diss = zeros(n_sample);

for ii = 1:n_sample
for jj = ii+1:n_sample
    diss(ii,jj) = norm(Ims(ii,:) - Ims(jj,:));
end
end

% original ordering
figure, imagesc(diss+diss'); colorbar;
title('Dissimilarity in raw data')

%clustering ordering
[~, idx] = sort(centersCentres);
new_diss = diss;
new_diss = new_diss(idx,:);
new_diss = new_diss(:,idx);

figure, imagesc(new_diss+new_diss'); colorbar;
title ('Dissimilarity in clusters')





end

