function figure2(t, impulse, hrf, response)

figure(2); clf;
subplot(4,1,1); hold on;
plot(t, impulse);
title('Stimulus');
set(gca, 'TickLength', [0 0], 'XTick', [], 'YTick', [0 0.15 0.85 1], ...
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
title('Convolved: Neural Response \ast HRF');
set(gca, 'XTick', 0:3:length(hrf), 'TickLength', [0 0], 'YTick', []);