%% denoise SSF with FFDNet
clc;clear;close all;
randn('seed', 1); rand('seed', 1);

%% pre set
format compact;
global sigmas; % input noise level or input noise level map
addpath(fullfile('utilities'));

folderModel = 'models';
folderTest  = 'testsets';
folderResult= 'results';
imageSets   = {'BSD68','Set12'}; % testing datasets
setTestCur  = imageSets{1};      % current testing dataset

showResult  = 1;
useGPU      = 0; % CPU or GPU. For single-threaded (ST) CPU computation, use "matlab -singleCompThread" to start matlab.
pauseTime   = 0;

imageNoiseSigma = 50;  % image noise level
inputNoiseSigma = 50;  % input noise level

folderResultCur       =  fullfile(folderResult, [setTestCur,'_',num2str(imageNoiseSigma),'_',num2str(inputNoiseSigma)]);
if ~isdir(folderResultCur)
    mkdir(folderResultCur)
end

load(fullfile('models','FFDNet_gray.mat'));
net = vl_simplenn_tidy(net);
%% load data
addpath('C:\Users\Administrator\Desktop\share\记录\DeepPnP')
load('init_data.mat')
load('ssf.mat')
day = 1;
I_total = I_1 * I_2 * I_3;
x_true = double(ssp);
ssf_max = max(x_true(:));
ssf_min = min(x_true(:));
nc = ssf_max - ssf_min;
x_true = (x_true - ssf_min )/ nc ;

%% 
% add noise
label = reshape(x_true,[100,1000]);
sigma = 1;
noise = sigma/(ssf_max - ssf_min).*randn(size(label));
% noise = imageNoiseSigma/255.*randn(size(label));
input = single(label + noise);
% set noise level map
% sigmas = inputNoiseSigma/255; % see "vl_simplenn.m".
sigmas = sigma/(ssf_max - ssf_min);
res    = vl_ffdnet_matlab(net, input); % use this if you did  not install matconvnet; very slow
output = res(end).x;

RMSE = norm( double(output-label) * nc ,'fro')/sqrt(100000);
% MAE = sum(abs(output-label),'all') / 100000;

%% plot
dep = [1 6 10];
num_methods = 3;
noisy_data = reshape(input,[100,100,10]);
denoise_data = reshape(output,[100,100,10]);
figure
figureUnits = 'centimeters';
figureWidth = 20;
figureHeight = 20;
set(gcf, 'Units', figureUnits, 'Position', [10 8 figureWidth figureHeight]); 
% 背景颜色
set(gcf,'Color',[1 1 1])
set(gca, 'FontName', 'times new roman','FontSize', 12)

ha = tight_subplot(3,3,[.03 .03],[.03 .03],[.03 .03]);

for i=1:3   
%     subplot(3,num_methods,num_methods*(i-1)+1)%,'Position',[0 0.3*(i-1) .3 1]
    subplot('Position',[0.1 0.95-0.3*i 0.25 0.25])%,'Position',[0 0.3*(i-1) .3 1]
        h = pcolor( squeeze( x_true(:,:,dep(i)) ) );
            %axis xy
            shading interp;
            colormap('jet');
            axis image
%             colorbar;
    title('ground-truth');
            set(gca,'xtick',[],'xticklabel',[])
        set(gca,'ytick',[],'yticklabel',[])
        
    
%         subplot(3,num_methods,num_methods*(i-1)+2)
    subplot('Position',[0.4 0.95-0.3*i 0.25 0.25])
        pcolor( squeeze( noisy_data(:,:,dep(i)) ) )
            %axis xy
            shading interp;
            colormap('jet');
            axis image
%             colorbar;
                set(gca,'xtick',[],'xticklabel',[])
        set(gca,'ytick',[],'yticklabel',[])
    title('noisy-data');
    
%         subplot(3,num_methods,num_methods*(i-1)+3)
    subplot('Position',[0.7 0.95-0.3*i 0.25 0.25])
        pcolor( squeeze( denoise_data(:,:,dep(i)) ) * nc + mean(ssf(:,:,dep(i)),'all') )
            %axis xy
            shading interp;
            colormap('jet');
            axis image
            colorbar;
                set(gca,'xtick',[],'xticklabel',[])
        set(gca,'ytick',[],'yticklabel',[])
    title('denoised-ssf');

end



