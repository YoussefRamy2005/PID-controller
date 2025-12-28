close all
clc
%% Motor Parameters
global Ka;
global Kb;
global Ra;
global La;
global b;
global Tf;
global Ea;

Ka = 1e-2;
Kb = 1e-1;
Ra = 1e-1;
La = 1e-2;
b  = 5e-3;

Ea = 10;
Tf = 0.5;

%% Extracting Simulation Results
res = sim("Motor_part_1.slx");
c_t = res.simout;
t = res.tout;

%% Calculating Motor Gain
uss = Ea;
N = 50;
yss = mean(c_t(end-N:end));
Km = yss/uss;

%% Calculating Motor Time Constant
y_63 = 0.63212*yss;
idx_y_63 = find(c_t >= y_63 , 1);
Tm = t(idx_y_63);

%% Modelling Motor Using Tm and Km
y_model = uss*Km*(1 - exp(-t/Tm));

%% Comparing Modelled Motor with the Exact Model

figure('Color','w','Position',[100 100 900 550]);

% --- Axes with light background ---
ax = axes;
set(ax, 'Color', [0.96 0.97 0.99]);   % light background
hold(ax, 'on')

% --- Main plots ---
plot(t, c_t, ...
    'Color',[0 0.4470 0.7410], ...
    'LineWidth',2.5);

plot(t, y_model, ...
    '--', ...
    'Color',[0.8500 0.3250 0.0980], ...
    'LineWidth',2.5);

% --- Error (shaded area) ---
error_signal = c_t - y_model;
fill([t; flipud(t)], ...
     [c_t; flipud(y_model)], ...
     [0.75 0.75 0.75], ...
     'FaceAlpha',0.25, ...
     'EdgeColor','none');

% --- Axes labels ---
xlabel('Time (s)','Interpreter','latex','FontSize',13)
ylabel('Angular Velocity $\omega$ (rad/s)','Interpreter','latex','FontSize',13)

% --- Title ---
title('Modeled Motor vs Measured Motor Response', ...
      'Interpreter','latex','FontSize',14,'FontWeight','bold')

% --- Legend ---
legend({'Measured Motor','Modeled Motor','Model Error'}, ...
       'Interpreter','latex','FontSize',11, ...
       'Location','best')

% --- Grid formatting (tuned for tinted background) ---
grid on
set(gca, ...
    'GridLineStyle','--', ...
    'MinorGridLineStyle',':', ...
    'XMinorGrid','on', ...
    'YMinorGrid','on', ...
    'GridAlpha',0.35, ...
    'MinorGridAlpha',0.2, ...
    'FontSize',11, ...
    'LineWidth',1.2)

% --- Axis limits ---
xlim([t(1) t(end)])

% --- Peak annotation ---
[peak_val, idx] = max(c_t);
text(t(idx), peak_val, ...
     sprintf('  Peak = %.2f rad/s', peak_val), ...
     'FontSize',10, ...
     'Interpreter','latex', ...
     'VerticalAlignment','bottom')

hold off

%% Parameter Annotation

paramText = {
    '\bf Identified Motor Parameters'
    ''
    sprintf('Gain $K_m$ = %.4f', Km)
    sprintf('Time Constant $T_m$ = %.4f s', Tm)
};

annotation('textbox', [0.62 0.18 0.3 0.22], ...
    'String', paramText, ...
    'Interpreter', 'latex', ...
    'FontSize', 12, ...
    'BackgroundColor', [0.95 0.95 0.95], ...
    'EdgeColor', [0.2 0.2 0.2], ...
    'LineWidth', 1.2);



