function [X] = origami( X, dim)
dim = circshift(dim,[0 0]);
X = shiftdim(reshape(X, dim), length(dim));
for i = 2:2:dim(3)
   X(:,:,i) = fliplr(X(:,:,i)); 
end
end
