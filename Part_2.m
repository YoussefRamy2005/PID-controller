close all
clc
%% Motor Parameters
global Ka;
global Kb;
global Ra;
global La;
global b;
global Tf;
global R;

Ka = 1e-2
Kb = 1e-1
Ra = 1e-1
La = 1e-2
b  = 5e-3

global Km;
global Tm
Km = 6.6695;
Tm = 0.0343

Tf = 20*Tm;
R = pi/2;

global Td;
global Kp;

Td = 0.15;
Kp = 17.5;
%% Extracting Simulation Results
res = sim("Motor_part_2.slx");
Motor_Position = res.Position;
U = res.Motor_Input_Volt;
E = res.Error_Signal;
t = res.tout;

res_sat = sim("Motor_part_3.slx");
Motor_Position_sat = res_sat.Position;
U_sat = res_sat.Motor_Input_Volt;
E_sat = res_sat.Error_Signal;
t_sat = res_sat.tout;

%% Verifying T Settle from Motor Step Response
yss2 = mean(Motor_Position(end-50:end));
idx2 = find(abs(Motor_Position - yss2) >= 0.02*yss2 ,1, 'last');
Tsettle = t(idx2);

%% Calculating T Settle from Motor Step Response after Saturation
yss2_sat = mean(Motor_Position_sat(end-50:end));
idx2_sat = find(abs(Motor_Position_sat - yss2_sat) >= 0.02*yss2_sat ,1, 'last');
Tsettle_sat = t_sat(idx2_sat);

%% Verifying Zeta using Maximum Overshoot (MP)
Mp = (max(Motor_Position) - yss2)/yss2;
variable1 = -log(Mp)/pi;
%%variable1 = zeta/sqrt(1-zeta^2) 
zeta = sqrt(variable1^2/(1+variable1^2));

%% Calculating Zeta using Maximum Overshoot (MP) after Saturation
Mp_sat = (max(Motor_Position_sat) - yss2_sat)/yss2_sat;
variable1_sat = -log(Mp_sat)/pi;
%%variable1 = zeta/sqrt(1-zeta^2) 
zeta_sat = sqrt(variable1_sat^2/(1+variable1_sat^2));

%% Calculating Integral Absolute Error (IAE) without saturation
dt = diff(t);
AE = abs(E.Data);
IAE = sum(AE(1:end-1).*dt);

%% Calculating Integral Absolute Error (IAE) with saturation
dt_sat = diff(t_sat);
AE_sat = abs(E_sat.Data);
IAE_sat = sum(AE_sat(1:end-1).*dt_sat);

%% Plotting Motor Output and its Time Domain Characteristics

axes_bg = [0.96 0.97 0.99];   % light background
blue    = [0 0.4470 0.7410];
orange  = [0.8500 0.3250 0.0980];
gray    = [0.75 0.75 0.75];

figure('Color','w','Position',[100 100 950 520]);
ax = axes; set(ax,'Color',axes_bg); hold on

plot(t, Motor_Position, ...
    'Color', blue, ...
    'LineWidth', 2.6);

% --- Steady-state reference ---
yline(yss2,'--', ...
    'Color', gray, ...
    'LineWidth',1.8);

% --- Settling time marker ---
xline(Tsettle,':', ...
    'Color', orange, ...
    'LineWidth',2);

xlabel('Time (s)','Interpreter','latex','FontSize',13)
ylabel('Position (rad)','Interpreter','latex','FontSize',13)

title('Motor Position Response', ...
      'Interpreter','latex','FontSize',14,'FontWeight','bold')

legend({'Position','Steady State','Settling Time'}, ...
       'Interpreter','latex','Location','best')

grid on
set(gca,'GridLineStyle','--',...
        'MinorGridLineStyle',':',...
        'XMinorGrid','on',...
        'YMinorGrid','on',...
        'GridAlpha',0.35,...
        'FontSize',11)

% --- Performance metrics box ---
annotation('textbox',[0.62 0.18 0.3 0.22], ...
    'String',{...
        '\bf Time-Domain Metrics', ...
        '', ...
        sprintf('Settling Time = %.4f s', Tsettle), ...
        sprintf('Overshoot $M_p$ = %.3f', Mp), ...
        sprintf('Damping Ratio $\\zeta$ = %.4f', zeta)}, ...
    'Interpreter','latex', ...
    'FontSize',11, ...
    'BackgroundColor',[0.95 0.95 0.95], ...
    'EdgeColor',[0.2 0.2 0.2], ...
    'LineWidth',1.2);

hold off

%% Plotting control Signal
figure('Color','w','Position',[100 100 950 480]);
ax = axes; set(ax,'Color',axes_bg); hold on

plot(t, U.Data, ...
    'Color', orange, ...
    'LineWidth', 2.4);

xlabel('Time (s)','Interpreter','latex','FontSize',13)
ylabel('Control Voltage $U$ (V)','Interpreter','latex','FontSize',13)

title('Control Signal (Actuator Effort)', ...
      'Interpreter','latex','FontSize',14,'FontWeight','bold')

grid on
set(gca,'GridLineStyle','--',...
        'MinorGridLineStyle',':',...
        'XMinorGrid','on',...
        'YMinorGrid','on',...
        'GridAlpha',0.35,...
        'FontSize',11)

% --- Peak voltage annotation ---
[Umax, idxU] = max(U.Data);
text(t(idxU), Umax, ...
    sprintf('  Max = %.2f V', Umax), ...
    'Interpreter','latex', ...
    'FontSize',10, ...
    'VerticalAlignment','bottom');

hold off

%% Plotting Error Signal and IAE
figure('Color','w','Position',[100 100 950 480]);
ax = axes; set(ax,'Color',axes_bg); hold on

plot(t, E.Data, ...
    'Color', blue, ...
    'LineWidth', 2.4);

% --- Zero reference ---
yline(0,'--','Color',gray,'LineWidth',1.6);

xlabel('Time (s)','Interpreter','latex','FontSize',13)
ylabel('Error (rad)','Interpreter','latex','FontSize',13)

title('Tracking Error Signal', ...
      'Interpreter','latex','FontSize',14,'FontWeight','bold')

grid on
set(gca,'GridLineStyle','--',...
        'MinorGridLineStyle',':',...
        'XMinorGrid','on',...
        'YMinorGrid','on',...
        'GridAlpha',0.35,...
        'FontSize',11)

% --- IAE annotation ---
annotation('textbox',[0.62 0.2 0.3 0.15], ...
    'String',sprintf('\\bf IAE = %.4f', IAE), ...
    'Interpreter','latex', ...
    'FontSize',12, ...
    'BackgroundColor',[0.95 0.95 0.95], ...
    'EdgeColor',[0.2 0.2 0.2], ...
    'LineWidth',1.2);

hold off

%% Plotting Error Signal and IAE
figure('Color','w','Position',[100 100 950 480]);
ax = axes; set(ax,'Color',axes_bg); hold on

plot(E_sat.Data, ...
    'Color', blue, ...
    'LineWidth', 2.4);

% --- Zero reference ---
yline(0,'--','Color',gray,'LineWidth',1.6);

xlabel('Time (s)','Interpreter','latex','FontSize',13)
ylabel('Error (rad)','Interpreter','latex','FontSize',13)

title('Tracking Error Signal with Controller Saturation', ...
      'Interpreter','latex','FontSize',14,'FontWeight','bold')

grid on
set(gca,'GridLineStyle','--',...
        'MinorGridLineStyle',':',...
        'XMinorGrid','on',...
        'YMinorGrid','on',...
        'GridAlpha',0.35,...
        'FontSize',11)

% --- IAE annotation ---
annotation('textbox',[0.62 0.2 0.3 0.15], ...
    'String',sprintf('\\bf IAE = %.4f', IAE_sat), ...
    'Interpreter','latex', ...
    'FontSize',12, ...
    'BackgroundColor',[0.95 0.95 0.95], ...
    'EdgeColor',[0.2 0.2 0.2], ...
    'LineWidth',1.2);

hold off

%% Combined Error Signals Plot
figure('Color','w','Position',[100 100 950 480]);
ax = axes; set(ax,'Color',axes_bg); hold on

% Plot original error
plot(t, E.Data, 'Color', blue, 'LineWidth', 2.4, 'DisplayName','Error');

% Plot saturated error
plot(t_sat, E_sat.Data, 'Color', [1 0 0], 'LineWidth', 2.4, 'DisplayName','Saturated Error'); % red for distinction

% Zero reference
yline(0,'--','Color',gray,'LineWidth',1.6);

xlabel('Time (s)','Interpreter','latex','FontSize',13)
ylabel('Error (rad)','Interpreter','latex','FontSize',13)

title('Tracking Error Signals','Interpreter','latex','FontSize',14,'FontWeight','bold')

grid on
set(gca,'GridLineStyle','--',...
        'MinorGridLineStyle',':',...
        'XMinorGrid','on',...
        'YMinorGrid','on',...
        'GridAlpha',0.35,...
        'FontSize',11)

% Legend
legend('Location','best','Interpreter','latex')

% Combined IAE annotation
annotation('textbox',[0.62 0.2 0.3 0.15], ...
    'String',sprintf('IAE = %.4f, IAE_{sat} = %.4f', IAE, IAE_sat), ...
    'Interpreter','latex', ...
    'FontSize',12, ...
    'BackgroundColor',[0.95 0.95 0.95], ...
    'EdgeColor',[0.2 0.2 0.2], ...
    'LineWidth',1.2);

hold off


%% Combined Control Signals Plot
figure('Color','w','Position',[100 100 950 480]);
ax = axes; set(ax,'Color',axes_bg); hold on

% Plot original control signal
plot(t, U.Data, 'Color', blue, 'LineWidth', 2.4, 'DisplayName','U');

% Plot saturated control signal
plot(t_sat, U_sat.Data, 'Color', [1 0 0], 'LineWidth', 2.4, 'DisplayName','U_sat'); % red for distinction

xlabel('Time (s)','Interpreter','latex','FontSize',13)
ylabel('Control Voltage $U$ (V)','Interpreter','latex','FontSize',13)

title('Control Signals (Actuator Effort)','Interpreter','latex','FontSize',14,'FontWeight','bold')

grid on
set(gca,'GridLineStyle','--',...
        'MinorGridLineStyle',':',...
        'XMinorGrid','on',...
        'YMinorGrid','on',...
        'GridAlpha',0.35,...
        'FontSize',11)

% Legend
legend('Location','best','Interpreter','latex')

% --- Peak voltage annotations ---
[Umax, idxU] = max(U.Data);
text(t(idxU), Umax, sprintf('  Max U = %.2f V', Umax), ...
    'Interpreter','latex', 'FontSize',10, 'VerticalAlignment','bottom');

[UsatMax, idxUsat] = max(U_sat.Data);
text(t(idxUsat), UsatMax, sprintf('  Max U_{sat} = %.2f V', UsatMax), ...
    'Interpreter','latex', 'FontSize',10, 'VerticalAlignment','bottom', 'Color',[1 0 0]);

hold off

%% Combined Motor Position Plot
axes_bg = [0.96 0.97 0.99];   % light background
blue    = [0 0.4470 0.7410];
orange  = [0.8500 0.3250 0.0980];
gray    = [0.75 0.75 0.75];

figure('Color','w','Position',[100 100 950 520]);
ax = axes; set(ax,'Color',axes_bg); hold on

% Plot original motor position
plot(t, Motor_Position, 'Color', blue, 'LineWidth', 2.6, 'DisplayName','Position');

% Plot saturated motor position
plot(t_sat, Motor_Position_sat, 'Color', [1 0 0], 'LineWidth', 2.6, 'DisplayName','Position_{sat}');

% --- Steady-state reference ---
yline(yss2,'--', 'Color', gray, 'LineWidth',1.8, 'DisplayName','Steady State');

% --- Settling time marker ---
xline(Tsettle,':', 'Color', orange, 'LineWidth',2, 'DisplayName','Settling Time');
xline(Tsettle_sat, '--', 'Color', [0 0.5 0], 'LineWidth',1.8, 'DisplayName','Settling Time_{sat}'); 

xlabel('Time (s)','Interpreter','latex','FontSize',13)
ylabel('Position (rad)','Interpreter','latex','FontSize',13)

title('Motor Position Response','Interpreter','latex','FontSize',14,'FontWeight','bold')

% Legend
legend('Location','northeast','Interpreter','latex')

grid on
set(gca,'GridLineStyle','--',...
        'MinorGridLineStyle',':',...
        'XMinorGrid','on',...
        'YMinorGrid','on',...
        'GridAlpha',0.35,...
        'FontSize',11)


% --- First Performance metrics box ---
annotation('textbox',[0.62 0.18 0.3 0.22], ...
    'String',{...
        'Time-Domain Metrics after Saturation', ...
        '', ...
        sprintf('Settling Time = %.4f s', Tsettle_sat), ...
        sprintf('Overshoot $M_p$ = %.3f', Mp_sat), ...
        sprintf('Damping Ratio $\\zeta$ = %.4f', zeta_sat)}, ...
    'Interpreter','latex', ...
    'FontSize',11, ...
    'BackgroundColor',[0.95 0.95 0.95], ...
    'EdgeColor',[0.2 0.2 0.2], ...
    'LineWidth',1.2);

% --- Second Performance metrics box ---
annotation('textbox',[0.62 0.42 0.3 0.22], ...  
    'String',{...
        'Time-Domain Metrics', ...
        '', ...
        sprintf('Settling Time = %.4f s', Tsettle), ...
        sprintf('Overshoot $M_p$ = %.3f', Mp), ...
        sprintf('Damping Ratio $\\zeta$ = %.4f', zeta)}, ...
    'Interpreter','latex', ...
    'FontSize',11, ...
    'BackgroundColor',[0.95 0.95 0.95], ...
    'EdgeColor',[0.2 0.2 0.2], ...
    'LineWidth',1.2);
