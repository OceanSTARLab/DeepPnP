function [X] = unorigami( X, dim)
    X = reshape(X, dim(1), []);
    for i = dim(2)+1:2*dim(2):dim(2)*dim(3)
        X(:,i:i+dim(2)-1)=fliplr(X(:,i:i+dim(2)-1));
    end
end
