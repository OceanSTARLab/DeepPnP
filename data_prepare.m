%% data prepare forPnP
clc;clear;
%% load data
load('ssf_demean.mat')
ssp =  ssf(1:100, 1:100, 1:2:20);
[N_x, N_y, N_z] = size(ssp);
total = N_x * N_y * N_z;
%% preprocess
sigma = 0.3;
noisy_data = ssp + sigma * randn(size(ssp));
ssp_max = max(abs(noisy_data),[], 'all');
x = noisy_data / ssp_max;
%% sampling
sample_pattern = 'regular1';%sampling pattern
p = 0.1; %sampling rate
nmod = 3;
index = [];
switch sample_pattern
    case  'random'
        for i = 1:N_x
            for j = 1:N_y
                index = [index; [i, j]];
            end
        end
    N = int32(p * N_x * N_y);
    ind = index(randperm(size(index, 1), N), :);
    case 'regular1'
        for direction = 0:9
            if mod(direction, 2) == 0
                for i = direction*10:(direction*10+9)
                    for j = 0:99
                        if j/10 == (i-direction*10)
                            for k = 0:9
                                index = [index; [i+1, (i-direction*10)*10+k+1]];
                            end
                        end
                    end
                end
            else
                for i =int16(direction*10+10-1):-1:int16(direction*10)
                    for j = 0:99
                        if j/10 == ((direction)*10+10-1-i)
                            for k = 0:9
                                index = [index; [i+1, ((direction)*10+10-1-i)*10+k+1]];
                            end
                        end
                    end
                end
            end
        end

        ind = index;
        N = length(ind);
    
    case 'regular2'
            d = 20; % sampling rate = 0.1
            % d = 25;
            for i = 1:N_x
                for j = 1:N_y
                    if mod(i, d) == d/2 || mod(j, d) == d/2
                        % if mod(i, d) == 15 || mod(j, d) == 15
                        index = [index; [i, j]];
                    end
                end
            end
        ind = index;
        N = length(ind);
        
    otherwise
        disp('not implemented')
end

ob = zeros(size(ssp));
for n = 1:N
    ob(ind(n, 1), ind(n, 2), :) = ones(N_z,1);
end

x_ob = x .* ob;

%% save the sampled data
dataNew = 'init_data.mat';
noisy_data = x; I_1 = N_x; I_2 = N_y;I_3=N_z;
save(dataNew, 'ssp', 'noisy_data', 'I_1', 'I_2', 'I_3', 'ssp_max', 'x_ob', 'ob');

