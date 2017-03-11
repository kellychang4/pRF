% pRF-Tutorial.m

clear all; close all;
cd('~/Desktop/pRFFinal'); % delete this when done

% mention dependencies

%% Introduction

% Functional Magnetic Resonance Imaging (fMRI), is an indirect measure the
% activity of a population of neurons (voxel). When a population of neurons
% is activated, the neurons induces an increase in blood flow'

n = 3;
tau = 1.5;
delta = 2.5;
t = linspace(0,30,1000);
hrf = gammaHRF(n, tau, delta, t);

figure(1); clf;
plot(t, hrf);
xlabel('Time (s)');
ylabel('Response');
title('Hemodynamic Response Function (HRF)');
set(gca, 'YTick', []);

%% Convolve

impulse = zeros(length(t),1);
impulse(100,1) = 1; % impulse response function, delta function
response = conv(impulse, hrf(:));
response = response(1:length(t));

figure(2); clf;
subplot(4,1,1);
h = plot(t, impulse);
title('Stimulus');
set(gca, 'TickLength', [0 0], 'XTick', [], 'YTick', [0 0.1 0.9 1], ...
    'YTickLabel', {'OFF', 'Stimulus', 'ON', 'Stimulus'});

subplot(4,1,2);
plot(t, impulse);
ylabel('Neural Response');
title('Neuronal Response to Stimulus');
set(gca, 'XTick', [], 'YTick', []);

subplot(4,1,3);
plot(t, hrf);
ylabel('Response');
title('Hemodynamic (Impulse) Response Function (HRF)');
set(gca, 'XTick', [], 'YTick', []);

subplot(4,1,4);
plot(t, response);
xlabel('Time (s)');
ylabel('Voxel Response');
title('Convolved: Neural Response + HRF');
set(gca, 'TickLength', [0 0], 'YTick', []);

%%

impulse = zeros(length(t),3);
impulse(100,1) = 1;
impulse(200,2) = 1;
impulse(300,3) = 1;

neural = impulse;
neural(300,3) = 0.5;

response = cellfun(@(x) conv(x,hrf), num2cell(neural,1), 'UniformOutput', false);
response = cell2mat(cellfun(@(x) x(1:length(t))', response, 'UniformOutput', false));

cMap = [0 0.4470 0.7410];
figure(3); clf;
subplot(4,1,1);
plot(impulse, 'Color', cMap);
title('Stimulus');
set(gca, 'TickLength', [0 0], 'XTick', [], 'YTick', [0 0.1 0.9 1], ...
    'YTickLabel', {'OFF', 'Stimulus', 'ON', 'Stimulus'});

subplot(4,1,2);
plot(t, neural, 'Color', cMap);
ylabel('Neural Response');
title('Neuronal Response to Stimulus');
set(gca, 'XTick', [], 'YTick', []);

subplot(4,1,3);
plot(t, hrf);
ylabel('Response');
title('Hemodynamic (Impulse) Response Function (HRF)');
set(gca, 'XTick', [], 'YTick', []);

subplot(4,1,4); hold on;
plot(t, sum(response,2));
plot(t, response, 'r--');
xlabel('Time (s)');
ylabel('Voxel Response');
title('Convolved: Neural Response + HRF');
set(gca, 'TickLength', [0 0], 'YTick', []);

%% Convolved Stimulus Matrix

TR = 2; % seconds
stimuli = 1:6;
paradigm = [stimuli(1:(length(stimuli)/2)) NaN(1,6) ...
    stimuli(((length(stimuli)/2)+1):end) NaN(1,6)];
nVols = length(paradigm);
cMap = hsv(length(stimuli));

t = 0:TR:30; % time
hrf = gammaHRF(n, tau, delta, t); % hrf in steps of TRs

stimulusMatrix = zeros(length(stimuli), nVols);
for i = 1:length(paradigm)
    if ~isnan(paradigm(i))
        stimulusMatrix(:,i) = stimuli == paradigm(i);
    end
end

figure(4); clf;
subplot('Position', [0.1 0.38 0.85 0.55]);
imagesc(stimulusMatrix);
ylabel('Stimuli');
title('Stimulus Matrix');
set(gca, 'XTick', '', 'YTick', 1:length(stimuli), ...
    'YTickLabel', arrayfun(@(x) sprintf('S%d',x), 1:length(stimuli), 'UniformOutput', false));
colormap gray

intensity = [1 1 1 0.5 0.5 0.5];
indx = [(find(sum(stimulusMatrix))*TR)-TR; find(sum(stimulusMatrix))*TR]';
t = linspace(0,TR*nVols,1000);
stimulusImpulse = zeros(length(t), length(stimuli));
for i = 1:length(stimuli)
    [~,tmp] = arrayfun(@(x) min((t-x).^2), indx(i,:));
    stimulusImpulse(tmp(1):tmp(2),i) = intensity(i);
end
subplot('Position', [0.1 0.08 0.85 0.25]); hold on;
h = plot(t, stimulusImpulse);
xlabel('Time (s)');
ylabel('Neural Response');
set(h, {'Color'}, num2cell(cMap,2));
set(gca, 'XLim', [0 TR*nVols], 'XTick', 0:TR:(TR*nVols), ...
    'TickLength', [0 0], 'YTick', []);

%%

convolvedMatrix = TR * convn(diag([1 1 1 0.5 0.5 0.5])*stimulusMatrix, hrf);
convolvedMatrix = convolvedMatrix(:,1:nVols);
figure(5); clf;
subplot('Position', [0.1 0.38 0.85 0.55]);
imagesc(convolvedMatrix);
ylabel('Stimuli');
title('Convolved: Stimulus Matrix * HRF');
set(gca, 'XTick', '', 'YTick', 1:length(stimuli), ...
    'YTickLabel', arrayfun(@(x) sprintf('S%d',x), 1:length(stimuli), 'UniformOutput', false));
colormap gray

convolvedImpulse = convn(stimulusImpulse, gammaHRF(n,tau,delta,t)');
convolvedImpulse = convolvedImpulse(1:length(t),:);
subplot('Position', [0.1 0.08 0.85 0.25]); hold on;
h = plot(t, convolvedImpulse, '--');
plot(t, sum(convolvedImpulse,2), 'Color', [0.25 0.25 0.25]);
xlabel('Time (s)');
ylabel('Voxel Response');
yLim = get(gca, 'YLim');
set(h, {'Color'}, num2cell(cMap,2));
set(gca, 'XLim', [0 TR*nVols], 'XTick', 0:TR:(TR*nVols), 'YTick', []);

%%

mu = 3;
sigma = 1;
tuning = gaussian(mu, sigma, stimuli);

figure(6); clf;
subplot('Position', [0.1 0.38 0.85 0.55]);
imagesc(stimulusMatrix);
ylabel('Stimuli');
title('Stimulus Matrix');
set(gca, 'XTick', '', 'YTick', 1:length(stimuli), ...
    'YTickLabel', arrayfun(@(x) sprintf('S%d',x), 1:length(stimuli), 'UniformOutput', false));
colormap gray

indx = [(find(sum(stimulusMatrix))*TR)-TR; find(sum(stimulusMatrix))*TR]';
t = linspace(0,TR*nVols,1000);
stimulusImpulse = zeros(length(t), length(stimuli));
for i = 1:length(stimuli)
    [~,tmp] = arrayfun(@(x) min((t-x).^2), indx(i,:));
    stimulusImpulse(tmp(1):tmp(2),i) = tuning(i);
end
subplot('Position', [0.1 0.08 0.85 0.25]); hold on;
h = plot(t, stimulusImpulse);
xlabel('Time (s)');
ylabel('Neural Response');
set(h, {'Color'}, num2cell(cMap,2));
set(gca, 'XLim', [0 TR*nVols], 'XTick', 0:TR:(TR*nVols), ...
    'TickLength', [0 0], 'YTick', []);

convolvedMatrix = TR * convn(diag(tuning)*stimulusMatrix, hrf);
convolvedMatrix = convolvedMatrix(:,1:nVols);
figure(7); clf;
subplot('Position', [0.1 0.38 0.85 0.55]);
imagesc(convolvedMatrix);
ylabel('Stimuli');
title('Convolved: Stimulus Matrix * HRF');
set(gca, 'XTick', '', 'YTick', 1:length(stimuli), ...
    'YTickLabel', arrayfun(@(x) sprintf('S%d',x), 1:length(stimuli), 'UniformOutput', false));
colormap gray

convolvedImpulse = convn(stimulusImpulse, gammaHRF(n,tau,delta,t)');
convolvedImpulse = convolvedImpulse(1:length(t),:);
subplot('Position', [0.1 0.08 0.85 0.25]); hold on;
h = plot(t, convolvedImpulse, '--');
plot(t, sum(convolvedImpulse,2), 'Color', [0.25 0.25 0.25]);
xlabel('Time (s)');
ylabel('Response');
yLim = get(gca, 'YLim');
set(h, {'Color'}, num2cell(cMap,2));
set(gca, 'XLim', [0 TR*nVols], 'XTick', 0:TR:(TR*nVols), 'YTick', []);

%%

t = linspace(0,TR*nVols,1000);
stimulusImpulse = zeros(length(t), length(stimuli));
for i = 1:length(stimuli)
    [~,tmp] = arrayfun(@(x) min((t-x).^2), indx(i,:));
    stimulusImpulse(tmp(1):tmp(2),i) = intensity(i);
end

figure(8); clf;
subplot(2,2,1);
h = plot(t, stimulusImpulse);
xlabel('Time (s)');
ylabel('Neural Response');
set(h, {'Color'}, num2cell(cMap,2));
set(gca, 'XLim', [0 TR*nVols], 'XTick', 0:(TR*2):(TR*nVols), ...
    'TickLength', [0 0], 'YTick', []);

subplot(2,2,2);
stem(stimuli, intensity);
xlabel('Stimuli');
set(gca, 'XTick', stimuli, 'XLim', [min(stimuli)-1 max(stimuli)+1], ...
    'XTickLabel', arrayfun(@(x) sprintf('S%d',x), stimuli, 'UniformOutput', false), ...
    'TickLength', [0 0], 'YTick', [0 0.5 1]);

stimulusImpulse = zeros(length(t), length(stimuli));
for i = 1:length(stimuli)
    [~,tmp] = arrayfun(@(x) min((t-x).^2), indx(i,:));
    stimulusImpulse(tmp(1):tmp(2),i) = tuning(i);
end

subplot(2,2,3);
h = plot(t, stimulusImpulse);
xlabel('Time (s)');
ylabel('Neural Response');
set(h, {'Color'}, num2cell(cMap,2));
set(gca, 'XLim', [0 TR*nVols], 'XTick', 0:(TR*2):(TR*nVols), ...
    'TickLength', [0 0], 'YTick', []);

subplot(2,2,4);
stem(stimuli, tuning);
xlabel('Stimuli');
set(gca, 'XTick', stimuli, 'XLim', [min(stimuli)-1 max(stimuli)+1], ...
    'XTickLabel', arrayfun(@(x) sprintf('S%d',x), stimuli, 'UniformOutput', false), ...
    'TickLength', [0 0], 'YTick', [0 0.5 1]);