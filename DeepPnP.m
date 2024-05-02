function [X, Out] = DeepPnP(Xmiss,Omega,opts)
global sigmas
minsigma = 0.01;
if isfield(opts,'reg');       reg = opts.reg;                  else  reg = 5e1;    end
if isfield(opts,'sigma');       sigma = opts.sigma;                  else  sigma = 0.1;                end
if isfield(opts,'beta1');       beta1 = opts.beta1;                  else  beta1 = 1e-2;                end
if isfield(opts,'beta2');       beta2 = opts.beta2;                  else  beta2 = 1e-2;                end

if isfield(opts,'maxit');      maxit = opts.maxit;      else   maxit=200;     end
if isfield(opts,'tol');       tol= opts.tol;                  else  tol = 1e-4;                end

if isfield(opts,'rho');       rho= opts.rho;                  else  rho = 1;                end
if isfield(opts,'maxbeta');       maxbeta= opts.maxbeta;                  else  maxbeta = 10000;                end
if isfield(opts,'debug');       debug= opts.debug;                  else  debug = 0;                end
Xtrue = opts.Xtrue;
useGPU  = 0;


%% initialization
[w, h, c] = size(Xmiss);

X = rand(size(Xmiss));
X(Omega) = Xmiss(Omega);

Lambda1 = zeros(size(X));
Lambda2 = zeros(size(X));

%% FFDnet parameter
load(fullfile('FFDNet_Clip_gray.mat'))

net = vl_simplenn_tidy(net);
if useGPU
    net = vl_simplenn_move(net, 'gpu') ;
end

process = {};
for r = 1:maxit
    Xlast = X;
    %% update Y
        [Y] = prox_TNN(X+Lambda1/beta1,1/beta1);
    
    %% update Z
        input = unorigami(X + Lambda2/beta2,[w h c]);
        sigX = unorigami(Xmiss,[w h c]);
      
    input = single(input); %
    
    if useGPU
        input = gpuArray(input);
    end
    max_in = max(input(:));min_in = min(input(:));
    input = (input-min_in)/(max_in-min_in);

    sigmas = sigma/(max_in-min_in);
    
%     res    = vl_simplenn(net,input,[],[],'conserveMemory',true,'mode','test');
    res    =  vl_ffdnet_matlab(net,input);
    output = res(end).x;
    
    output(output<0)=0;output(output>1)=1;
    output = output*(max_in-min_in)+min_in;   
    
    if useGPU
        output = gather(output);
    end
    
     Z = origami(double(output),[w h c]);

    
    %% update X
    X = (beta1*Y+beta2*Z-Lambda1-Lambda2)/(beta1+beta2);
    
    % if there is no noise
%     X(Omega) = Xmiss(Omega);

    % noise exist
    s = (beta1*Y+beta2*Z-Lambda1-Lambda2)/(beta1+beta2);
    X(Omega) = beta1/(beta1+reg)*s(Omega) + reg/(beta1+reg)*Xmiss(Omega);

    X(X>1) = 1;
    X(X<0) = 0;
    
    %% stopping criterion
    psnrrec(r) = myPSNR(X,Xtrue);
    relerr(r) = abs(norm(X(:)-Xlast(:)) / norm(Xlast(:)));
    if  mod(r-1,2) ==0 && debug ==1
        process = [process,X-Xtrue];
%         fprintf('%d: RSE:   %f \n',r-1,relerr(r));
        fprintf('Iter = %d, PSNR:  %4.2f \n',r,psnrrec(r));
    end
    real(r) = abs(norm(X(:)-Xtrue(:)) / norm(Xtrue(:)));
    
    if r > maxit || relerr(r) < tol
        break
    end
    

    
    %% update Lambda
    Lambda1 = Lambda1 + beta1*(X-Y);
    Lambda2 = Lambda2 + beta2*(X-Z);
    
    if rho ~= 1  &&  r>20
        beta1 = min(maxbeta,beta1*rho);
        beta2 = min(maxbeta,beta2*rho);
        sigma = max(minsigma, sigma/rho);
        if debug ==2
            fprintf('beta=%.4f\n',beta)
        end
    end
    
end
process = [process,X];
Out.res = relerr;
Out.real = real;
Out.psnr = psnrrec;
Out.process = process;
fprintf('total iterations = %d.',r);
end


