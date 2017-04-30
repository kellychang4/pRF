function [opt] = plotParams(collated, opt)
% [opt] = plotParams(collated, opt)
%
% Plot histograms of the estimated pRF parameters. Maximum of 16 parameters
% will be plotted on a single figure.
%
% Inputs:
%   collated        A structure containing all fitted pRF information as
%                   as given by [collated] = estpRF(scan, seeds, hrf, opt)
%   opt             A 1 x M structure containing options for plotting
%                   the parameters histograms where M is the number of
%                   plots desired with fields:
%       params      Parameter names to be plotted (default: first 16
%                   parameters available in 'collated' except tau + delta)
%       bestSeed    Plot best seed parameters (true) OR not (false),
%                   logical (default: false)
%       corrThr     Correlation threshold to index parameter values by,
%                   numeric (default: 0.01)
%       subplot     A vector specifing the number of rows and columns the
%                   the figure divided into (default: maximum 4 graphs per
%                   row)
%       measure     A function used to specify where to draw a vertical
%                   line on the plot (default: @median)
%       bins        Number of bins used in the histogram, numeric
%                   (default: 25)
%
% Output:
%   opt             The same 'opt' structure with additional fields filled
%                   in if previously empty

% Written by Kelly Chang - July 25, 2016

%% Input Control

if ~exist('opt', 'var')
    opt = struct();
end

bestSeed = cat(2, collated.pRF.bestSeed);
for i = 1:length(opt)
    if ~isfield(opt(i), 'bestSeed') || isempty(opt(i).bestSeed)
        opt(i).bestSeed = false;
    end
    
    if ~isfield(opt(i), 'params') || isempty(opt(i).params)
        if ~opt(i).bestSeed % pRF parameters
            opt(i).params = setdiff(fieldnames(collated.pRF), ...
                {'id', 'didFit', 'tau', 'delta', 'bestSeed'});
        else % best seed parameters
            opt(i).params = setdiff(fieldnames(bestSeed), {'seedID'});
        end
    end
    
    if ~ischar(opt(i).params) && length(opt(i).params) > 16
        warning('Too many parameters to plot\nParameter(s) will not be plotted: %s', ...
            strjoin(opt(i).params(17:end), ', '));
        opt(i).params = opt(i).params(1:16);
    end
    
    if ~isfield(opt(i), 'corrThr') || isempty(opt(i).corrThr)
        opt(i).corrThr = 0.01;
    end
    
    if ~isfield(opt(i), 'measure') || isempty(opt(i).measure)
        opt(i).measure = @median;
    end
    
    if ~isfield(opt(i), 'subplot') || isempty(opt(i).subplot)
        [err,indx] = min((((1:4).^2) - length(opt(i).params)).^2);
        if err == 0 % if perfect square
            opt(i).subplot = repmat(indx,1,2);
        else
            opt(i).subplot = [ceil(length(opt(i).params)/4) 4];
        end
    end
    
    if ~isfield(opt(i), 'bins') || isempty(opt(i).bins)
        opt(i).bins = 25;
    end
    
    % error check
    if ~opt(i).bestSeed % if pRF estimated parameters
        if ~all(ismember(opt(i).params, fieldnames(collated.pRF)))
            errFlds = opt(i).params(~ismember(opt(i).params, fieldnames(collated.pRF)));
            error('Parameter(s) for plot %d could not be plotted: %s', ...
                i, strjoin(errFlds, ', '));
        end
    else % else best seed parameters
        if ~all(ismember(opt(i).params, fieldnames(bestSeed)))
            errFlds = opt(i).params(~ismember(opt(i).params, fieldnames(bestSeed)));
            error('Best Seed parameter(s) for plot %d could not be plotted: %s', ...
                i, strjoin(errFlds, ', '));
        end
    end
end
opt = orderfields(opt, {'params', 'bestSeed', 'corrThr', 'measure', 'subplot', 'bins'});

%% Plot Parameters

for i = 1:length(opt)
    figure();
    for i2 = 1:length(opt(i).params)
        if ~opt(i).bestSeed % if pRF estimated parameters
            tmp = eval(sprintf('[collated.pRF.%s];', opt(i).params{i2}));
            tmp = eval(sprintf('tmp([collated.pRF.corr]>%d);', opt(i).corrThr));
            tmpTitle = sprintf('pRF: %s', opt(i).params{i2});
        else % if best seed parameter
            tmp = eval(sprintf('[bestSeed.%s];', opt(i).params{i2}));
            tmp = eval(sprintf('tmp([bestSeed.corr]>%d);', opt(i).corrThr));
            tmpTitle = sprintf('Best Seed: %s', opt(i).params{i2});
        end
        
        subplot(opt(i).subplot(1), opt(i).subplot(2), i2); hold on;
        hist(tmp, opt(i).bins);
        ylabel('Number of Voxels');
        title(tmpTitle);
        axis tight
        
        if ~isempty(opt(i).measure)
            plot(repmat(opt(i).measure(tmp),1,2), ylim, 'r');
            title(sprintf('%s\n%s = %5.4f', tmpTitle, upper1(func2str(opt(i).measure)), ...
                opt(i).measure(tmp)));
        end
    end
end