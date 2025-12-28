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

Ka = 1e-2;
Kb = 1e-1;
Ra = 1e-1;
La = 1e-2;
b  = 5e-3;

global Km;
global Tm;
Km = 6.6695;
Tm = 0.0343;

Tf = 20*Tm;
R = pi/2;

global Td;
global Kp;

Td = 0.15;
Kp = 17.5;

%% Extracting Simulation results
res_i = sim("Motor_part_2.slx");
Motor_Position_i = res_i.Position;
U_i = res_i.Motor_Input_Volt;
E_i = res_i.Error_Signal;
t_i = res_i.tout;

res = sim("Motor_part_3.slx");
Motor_Position = res.Position;
U = res.Motor_Input_Volt;
E = res.Error_Signal;
t = res.tout;

%% Modelled Motor vs Non-Linear Motor before Optimization

% Colors and background
axes_bg = [0.96 0.97 0.99];   % light background
blue    = [0.0, 0.5, 0.9];   % bright blue
purple  = [0.7, 0.3, 0.8];   % magenta/purple

figure('Color','w','Position',[100 100 950 520]);
ax = axes; 
set(ax,'Color',axes_bg); 
hold on

% --- Modeled Motor ---
plot(t_i, Motor_Position_i, ...
    'Color', blue, ...
    'LineWidth', 2.6);

% --- Nonlinear Motor ---
plot(t, Motor_Position, '--', ...
    'Color', purple, ...
    'LineWidth', 2.6);

% Labels and title
xlabel('Time (s)','Interpreter','latex','FontSize',13)
ylabel('Motor Position (rad)','Interpreter','latex','FontSize',13)
title('Modeled vs Nonlinear Motor Response (Before Optimization)', ...
      'Interpreter','latex','FontSize',14,'FontWeight','bold')

% Legend
legend({'Modeled Motor','Nonlinear Motor'}, ...
       'Interpreter','latex','Location','best')

% Grid styling
grid on
set(gca,'GridLineStyle','--', ...
        'MinorGridLineStyle',':', ...
        'XMinorGrid','on', ...
        'YMinorGrid','on', ...
        'GridAlpha',0.35, ...
        'FontSize',11)

hold off

%% Kp and Td Optimization
dt = diff(t);
AE = abs(E.Data);
IAE = sum(AE(1:end-1).*dt);
fprintf('Integral Absolute Error (IAE) with saturation = %.4f\n', IAE);

cost = abs(U.Data);
J_sat = sum(cost(1:end-1).*dt);
fprintf('Cost Function (J) with saturation = %.4f\n\n\n\n\n', J_sat);

Kp_vec = linspace(10,100,90); 
Td_vec = linspace(0,3,50); 
J = zeros(length(Kp_vec), length(Td_vec)); 
total_steps = length(Kp_vec) * length(Td_vec);  
counter = 0;  
hWait = waitbar(0, 'Running Optimization Sweep...'); 
%% Sweep of Kp and Td
for i = 1:length(Kp_vec) 
    for j = 1:length(Td_vec) 
        Kp = Kp_vec(i); 
        Td = Td_vec(j); 
        res = sim("Motor_part_3.slx",'FastRestart','on'); 
        E = res.Error_Signal.Data; 
        U = res.Motor_Input_Volt.Data; 
        t = res.tout; 
        dt = diff(t); 
        J(i,j) = sum(abs(E(1:end-1)).*dt) + 0.5*sum(abs(U(1:end-1)).*dt); 
        counter = counter + 1;  
        waitbar(counter/total_steps, hWait, ...
        sprintf('Progress: %.1f%%', counter/total_steps*100));

    end 
end 

close(hWait)
fprintf('Optimization sweep done!\nResults:\n');

%% Viewing Optimization Results
[Jmin, idx] = min(J(:)); 
[i_opt, j_opt] = ind2sub(size(J), idx); 
Kp_opt = Kp_vec(i_opt); 
Td_opt = Td_vec(j_opt); 

fprintf('Min J = %.4f\n',Jmin); 
fprintf('Optimal Kp = %.4f\n',Kp_opt); 
fprintf('Optimal Td = %.4f\n',Td_opt);  


%% Plotting Contour of Kp and Td Sweep
figure('Color','w','Position',[200 150 900 600]);

% --- Contour plot ---
contourf(Td_vec, Kp_vec, J, 30, 'LineColor','k'); % filled contours with black lines
colormap(turbo);   % perceptually uniform, visually appealing
colorbar;          % shows cost scale
hold on

% --- Optimal point marker ---
plot(Td_opt, Kp_opt, 'rx', 'MarkerSize',10, 'LineWidth',2);

% --- Labels ---
xlabel('$T_d$', 'Interpreter','latex','FontSize',13);
ylabel('$K_p$', 'Interpreter','latex','FontSize',13);

% --- Title ---
title('Contour of Cost Function $J(K_p, T_d)$', 'Interpreter','latex','FontSize',14,'FontWeight','bold');

% --- Grid and axes styling ---
grid on
ax = gca;
ax.LineWidth = 1.2;
ax.FontSize = 12;
ax.Box = 'on';
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.GridAlpha = 0.3;
ax.MinorGridAlpha = 0.15;

% --- Optional: add text label at optimal point ---
text(Td_opt, Kp_opt, sprintf('  Optimal'), 'Color','r', 'FontSize',12, 'FontWeight','bold');

hold off


%% Extracting Simulation Results after Optimization of PD Controller
Kp = Kp_opt ; 
Td = Td_opt ; 

res_opt = sim("Motor_part_3.slx");
Motor_Position_opt = res_opt.Position;
t_opt = res_opt.tout;

%% Modelled Motor vs Non-Linear Motor after Optimization

% Colors and background
axes_bg = [0.96 0.97 0.99];   % light background
blue    = [0.0, 0.5, 0.9];   % bright blue
purple  = [0.7, 0.3, 0.8];   % magenta/purple


figure('Color','w','Position',[100 100 950 520]);
ax = axes; 
set(ax,'Color',axes_bg); 
hold on

% --- Modeled Motor ---
plot(t_i, Motor_Position_i, ...
    'Color', blue, ...
    'LineWidth', 2.6);

% --- Nonlinear Motor after optimization ---
plot(t_opt, Motor_Position_opt, '--', ...
    'Color', purple, ...
    'LineWidth', 2.6);

% Labels and title
xlabel('Time (s)','Interpreter','latex','FontSize',13)
ylabel('Motor Position (rad)','Interpreter','latex','FontSize',13)
title('Modeled vs Nonlinear Motor Response (After Optimization)', ...
      'Interpreter','latex','FontSize',14,'FontWeight','bold')

% Legend
legend({'Modeled Motor','Nonlinear Motor'}, ...
       'Interpreter','latex','Location','best')

% Grid styling
grid on
set(gca,'GridLineStyle','--', ...
        'MinorGridLineStyle',':', ...
        'XMinorGrid','on', ...
        'YMinorGrid','on', ...
        'GridAlpha',0.35, ...
        'FontSize',11)

hold off

%% Plotting 3D plot of Sweep 
figure('Color','w','Position',[200 100 900 650])

% Surface plot
surf(Td_vec, Kp_vec, J, ...
    'EdgeColor','none', ...
    'FaceAlpha',0.95)

% Colormap and lighting
colormap(cool)
shading interp
colorbar

% Axes labels
xlabel('Derivative Time $T_d$','Interpreter','latex','FontSize',13)
ylabel('Proportional Gain $K_p$','Interpreter','latex','FontSize',13)
zlabel('Cost Function $J$','Interpreter','latex','FontSize',13)

% Title
title('Cost Surface $J(K_p, T_d)$','Interpreter','latex','FontSize',14)

% View and axis styling
view(45,30)
grid on
box on
set(gca,'FontSize',11,'LineWidth',1)

% Light blue axes background
ax = gca;
ax.Color = [0.85 0.92 1];  % light blue RGB
axis tight

% Annotation textbox
annotation('textbox',[0.02 0.78 0.32 0.18], ...
    'String',{ ...
        '\bf Optimization Results', ...
        '', ...
        sprintf('Min $J$ = %.4f', Jmin), ...
        sprintf('Optimal $K_p$ = %.4f', Kp_opt), ...
        sprintf('Optimal $T_d$ = %.4f', Td_opt)}, ...
    'Interpreter','latex', ...
    'FontSize',12, ...
    'BackgroundColor',[0.98 0.98 0.98], ...
    'EdgeColor',[0.15 0.15 0.15], ...
    'LineWidth',1.4, ...
    'Margin',8);



% Automatic rotation
az = 0;
while ishandle(ax)
    az = az + 0.2;
    view(ax, az, 30);
    drawnow;
end
