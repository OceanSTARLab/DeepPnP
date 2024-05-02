function [p, pvec] = myPSNR(x,y)
sz = size(x);
N = prod(sz(3:end));
pvec = zeros(1,N);
for k=1:N
    pvec(k)=psnr(y(:,:,k),x(:,:,k));
end
p = mean(pvec);
end
    
