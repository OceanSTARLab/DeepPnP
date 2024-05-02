%% PnP method
clc;clear;close all;
randn('seed', 1); rand('seed', 1);
addpath(genpath(pwd))
%% load the SSF data
load('init_data.mat')
x_true = ssp;
I_total=double(I_1*I_2*I_3);
sample_rate = numel(find(ob)) / I_total;
%% DP3LRTC
opts = [ ];
opts.tol   = 1e-4;
opts.maxit = 65;
opts.Xtrue = double((x_true/ssp_max+1)/2);
opts.debug = 1;

beta = 0.5;
sigma = 1.0;
opts.beta1 = beta;
opts.beta2 = beta;
opts.sigma =  sigma; %  std2(Xtrue - Xmiss); %  0.1*std2(Xtrue - Xmiss)
opts.rho = 1.1;
opts.reg = 50;
 
[X, Out] = DeepPnP( (x_ob+1)/2, logical(ob), opts );

X = (X*2 - 1)*ssp_max;

RMSE_PnP = norm( double(X(:)-x_true(:)) ,'fro')/sqrt(I_total);
%% plot the sampled field
num_methods = 3;
figure
figureUnits = 'centimeters';
figureWidth =15;
figureHeight = 15;
set(gcf, 'Units', figureUnits, 'Position', [22 16 figureWidth figureHeight]); 
set(gcf,'Color',[1 1 1])
dep = [1 6 10];

for i=1:3   
    subplot(3,num_methods,num_methods*(i-1)+1)
        pcolor( squeeze( x_true(:,:,dep(i)) ) )
            shading interp;
            colormap('jet');
            axis image
    title('ground-truth');
    set(gca,'xtick',[],'xticklabel',[])
    set(gca,'ytick',[],'yticklabel',[])
    set(gca, 'FontName', 'times new roman','FontSize', 12)

    subplot(3,num_methods,num_methods*(i-1)+2)
    a = x_ob(:,:,dep(i));
    a(a==0)=nan;
    [m,n]=size(a);
    [X_sample,Y_sample] = meshgrid(0:n-1,0:m-1);
    imagesc(X_sample(1,:),Y_sample(:,1),flipud(a));
    axis image
    colormap('jet');
    title('measurements')
    set(gca,'xtick',[],'xticklabel',[])
    set(gca,'ytick',[],'yticklabel',[])
    set(gca, 'FontName', 'times new roman','FontSize', 12)
    
     subplot(3,num_methods,num_methods*(i-1)+3)
    pcolor( squeeze( X(:,:,dep(i)))  )
            shading interp;
            colormap('jet');
            axis image
    title(' PnP'); 
        set(gca,'xtick',[],'xticklabel',[])
    set(gca,'ytick',[],'yticklabel',[])
    set(gca, 'FontName', 'times new roman','FontSize', 12)
end


