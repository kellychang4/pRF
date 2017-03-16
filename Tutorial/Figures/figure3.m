function figure3(t, impulse, neural, hrf, response)

figure(3); clf;
subplot(4,1,1);
plot(impulse, 'Color', [0 0.4470 0.7410]);
title('Stimulus');
set(gca, 'TickLength', [0 0], 'XTick', [], 'YTick', [0 0.15 0.85 1], ...
    'YTickLabel', {'OFF', 'Stimulus', 'ON', 'Stimulus'});

subplot(4,1,2);
plot(t, neural, 'Color', [0 0.4470 0.7410]);
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
title('Convolved: Neural Response \ast HRF');
set(gca, 'YLim', [0 max(get(gca,'YLim'))], 'YTick', [], ...
    'TickLength', [0 0], 'XTick', 0:3:length(hrf));