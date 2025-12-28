close all
clc
%% Motor Parameters
global Ka;
global Kb;
global Ra;
global La;
global b;

Ka = 1e-2;
Kb = 1e-1;
Ra = 1e-1;
La = 1e-2;
b  = 5e-3;

global Km;
global Tm;
Km = 6.6695;
Tm = 0.0343;

global Tf;
global Amplitude;
global frequency;

Tf = 30;
Amplitude = pi/2;
frequency = 0.1/Tm;

global Td;
global Kp;

Td = 1.8980;
Kp = 51.4607;

%% Extracting Simulation Results
res = sim("Motor_part_4.slx");
Motor_Position = res.Position;
Input_Signal = res.Input_Signal;
U = res.Motor_Input_Volt;
E = res.Error_Signal;
t = res.tout;



%% Plotting Motor Output vs Input

% --- Colors and background ---
axes_bg = [0.96 0.97 0.99];   % light background
brightBlue  = [0.0, 0.5, 1.0];   % vibrant bright blue
brightGreen = [0.2, 0.8, 0.3];   % vivid bright gre


figure('Color','w','Position',[100 100 950 520]);
ax = axes;
set(ax,'Color',axes_bg);
hold on

% --- Input signal ---
plot(Input_Signal, '-', 'Color', brightBlue, 'LineWidth', 2.6);

% --- Motor position ---
plot(t, Motor_Position, '-', 'Color', brightGreen, 'LineWidth', 2.6);

% --- Labels and title ---
xlabel('Time (s)', 'Interpreter','latex', 'FontSize',13)
ylabel('Signal / Position (rad)', 'Interpreter','latex', 'FontSize',13)
title('Motor Response vs Input Signal', 'Interpreter','latex', 'FontSize',14, 'FontWeight','bold')

% --- Legend ---
legend({'Input Signal','Motor Position'}, 'Interpreter','latex', 'FontSize',12, 'Location','best')

% --- Grid styling ---
grid on
set(gca,'GridLineStyle','--', ...
        'MinorGridLineStyle',':', ...
        'XMinorGrid','on', ...
        'YMinorGrid','on', ...
        'GridAlpha',0.35, ...
        'FontSize',11)

hold off

