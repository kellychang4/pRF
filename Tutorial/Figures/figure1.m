function figure1(t, hrf)

figure(1); clf;
plot(t, hrf);
xlabel('Time (s)');
ylabel('Response');
title('Hemodynamic Response Function (HRF)');
set(gca, 'XTick', 0:3:length(hrf), 'YTick', []);