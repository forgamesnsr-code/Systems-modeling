%% ЛАБОРАТОРНАЯ РАБОТА №3 — ГРАФИКИ ПО ИСХОДНОЙ СХЕМЕ Simulink
% Исходная схема: lab3_pendulum.slx
% Уравнение
% phi' = w
% w' = Fm/(m*l^2)*sin(Om*t) - K1/(m*l^2)*w
%      - K2/(m*l^2)*w*abs(w) - (g/l)*sin(phi)
%
% Параметры исходного InitFcn схемы:
% g=9.81, l=1, m=1, K1=0, K2=0, Fm=0, Om=2, phi0=0.5.
% Int_w имеет начальное условие 0; Int_phi получает phi0.
% Решатель схемы: ode45, RelTol=1e-8, MaxStep=0.01.

clear; clc; close all;

% Базовые настройки, прочитанные из модели lab3_pendulum.slx
p.g = 9.81;
p.m = 1;
p.l = 1;
p.K1 = 0;
p.K2 = 0;
p.Fm = 0;
p.Om = 2;
phi0 = 0.5;
w0 = 0;
opts = odeset('RelTol',1e-8,'AbsTol',1e-10,'MaxStep',0.01);
energy = @(U,pp) 0.5*U(:,2).^2 + (pp.g/pp.l)*(1-cos(U(:,1)));

%% РИСУНОК 2 — φ(t) и ω(t), маятник без потерь
p.K1=0; p.K2=0; p.Fm=0;
[t,U] = ode45(@(t,u) pendulum_rhs(t,u,p),[0 10],[phi0;w0],opts);
figure('Name','Рисунок 2 — Маятник без трения','Color','w');
tiledlayout(2,1,'TileSpacing','compact');
nexttile; plot(t,U(:,1),'LineWidth',1.2); grid on;
xlabel('t, с'); ylabel('\phi, рад'); title('Угол отклонения \phi(t)');
nexttile; plot(t,U(:,2),'LineWidth',1.2); grid on;
xlabel('t, с'); ylabel('\omega, рад/с'); title('Угловая скорость \omega(t)');

%% РИСУНОК 3 — фазовая траектория без трения
figure('Name','Рисунок 3 — Фазовая траектория без трения','Color','w');
plot(U(:,1),U(:,2),'LineWidth',1.2); grid on;
xlabel('\phi, рад'); ylabel('\omega, рад/с');
title('Фазовая траектория маятника без трения');

%% РИСУНОК 4 — вязкое трение K1=0.2
p.K1=0.2; p.K2=0; p.Fm=0;
[t,U] = ode45(@(t,u) pendulum_rhs(t,u,p),[0 10],[phi0;w0],opts);
figure('Name','Рисунок 4 — Вязкое трение K1=0.2','Color','w');
plot(t,U(:,1),'LineWidth',1.2); grid on;
xlabel('t, с'); ylabel('\phi, рад');
title('Затухающие колебания при K_1=0.2');

%% РИСУНОК 5 — φ(t) при K1=0.1; 0.5; 1.0
K1values=[0.1 0.5 1.0];
figure('Name','Рисунок 5 — Влияние вязкого трения','Color','w'); hold on;
for K1=K1values
    p.K1=K1; p.K2=0; p.Fm=0;
    [t,U]=ode45(@(t,u) pendulum_rhs(t,u,p),[0 20],[phi0;w0],opts);
    plot(t,U(:,1),'DisplayName',sprintf('K_1 = %g',K1));
end
grid on; xlabel('t, с'); ylabel('\phi, рад');
title('\phi(t) при разных коэффициентах вязкого трения');
legend('Location','best');

%% РИСУНОК 6 — фазовые траектории при разных K1
figure('Name','Рисунок 6 — Фазовые траектории при разных K1','Color','w'); hold on;
for K1=K1values
    p.K1=K1; p.K2=0; p.Fm=0;
    [~,U]=ode45(@(t,u) pendulum_rhs(t,u,p),[0 20],[phi0;w0],opts);
    plot(U(:,1),U(:,2),'DisplayName',sprintf('K_1 = %g',K1));
end
grid on; xlabel('\phi, рад'); ylabel('\omega, рад/с');
title('Фазовые траектории при разных K_1'); legend('Location','best');

%% РИСУНОК 7 — энергия при разных K1
figure('Name','Рисунок 7 — Энергия при разных K1','Color','w'); hold on;
for K1=K1values
    p.K1=K1; p.K2=0; p.Fm=0;
    [t,U]=ode45(@(t,u) pendulum_rhs(t,u,p),[0 20],[phi0;w0],opts);
    plot(t,energy(U,p),'DisplayName',sprintf('K_1 = %g',K1));
end
grid on; xlabel('t, с'); ylabel('E/(ml^2)');
title('Изменение энергии при разных K_1'); legend('Location','best');

%% РИСУНОК 8 — φ(t), K1=0.1 и K2=0; 0.05; 0.2
K2values=[0 0.05 0.2];
figure('Name','Рисунок 8 — Квадратичное сопротивление','Color','w'); hold on;
for K2=K2values
    p.K1=0.1; p.K2=K2; p.Fm=0;
    [t,U]=ode45(@(t,u) pendulum_rhs(t,u,p),[0 20],[phi0;w0],opts);
    plot(t,U(:,1),'DisplayName',sprintf('K_2 = %g',K2));
end
grid on; xlabel('t, с'); ylabel('\phi, рад');
title('\phi(t) при K_1=0.1 и разных K_2'); legend('Location','best');

%% РИСУНОК 9 — фазовая траектория, K1=0.1, K2=0.2
p.K1=0.1; p.K2=0.2; p.Fm=0;
[~,U]=ode45(@(t,u) pendulum_rhs(t,u,p),[0 20],[phi0;w0],opts);
figure('Name','Рисунок 9 — Фазовая траектория с квадратичным сопротивлением','Color','w');
plot(U(:,1),U(:,2),'LineWidth',1.2); grid on;
xlabel('\phi, рад'); ylabel('\omega, рад/с');
title('Фазовая траектория при K_1=0.1 и K_2=0.2');

%% РИСУНОК 10 — вынужденные колебания, Fm=1, beta=0.2, K1=0.4
% Из отчёта: K1=2*beta*m*l^2; K2=0; начальные условия нулевые.
beta=0.2; p.K1=2*beta*p.m*p.l^2; p.K2=0; p.Fm=1;
Omegas=[1 2 3 5];
figure('Name','Рисунок 10 — Вынужденные колебания','Color','w');
tiledlayout(2,2,'TileSpacing','compact');
for j=1:numel(Omegas)
    p.Om=Omegas(j);
    [t,U]=ode45(@(t,u) pendulum_rhs(t,u,p),[0 50],[0;0],opts);
    nexttile; plot(t,U(:,1),'LineWidth',1.1); grid on;
    xlabel('t, с'); ylabel('\phi, рад');
    title(sprintf('\Omega = %g рад/с',p.Om));
end
sgtitle('Вынужденные колебания при разных частотах возбуждения');

%% РИСУНОК 11 — фазовая траектория при Omega=2 рад/с
p.Om=2;
[t,U]=ode45(@(t,u) pendulum_rhs(t,u,p),[0 50],[0;0],opts);
figure('Name','Рисунок 11 — Фазовая траектория вынужденного режима','Color','w');
plot(U(:,1),U(:,2),'LineWidth',1.1); grid on;
xlabel('\phi, рад'); ylabel('\omega, рад/с');
title('Фазовая траектория при \Omega=2 рад/с');

%% РИСУНОК 12 — АЧХ, Omega=0.5:0.05:6, амплитуда на 60–100 с
OmegaValues=0.5:0.05:6;
AmpNumerical=zeros(size(OmegaValues));
for j=1:numel(OmegaValues)
    p.Om=OmegaValues(j);
    [t,U]=ode45(@(t,u) pendulum_rhs(t,u,p),[0 100],[0;0],opts);
    idx=t>=60;
    AmpNumerical(j)=0.5*(max(U(idx,1))-min(U(idx,1)));
end
w0natural=sqrt(p.g/p.l); F0=p.Fm/(p.m*p.l^2);
AmpLinear=F0./sqrt((w0natural^2-OmegaValues.^2).^2+(2*beta*OmegaValues).^2);
figure('Name','Рисунок 12 — Амплитудно-частотная характеристика','Color','w');
plot(OmegaValues,AmpNumerical,'LineWidth',1.4,'DisplayName','Нелинейная модель'); hold on;
plot(OmegaValues,AmpLinear,'--','LineWidth',1.2,'DisplayName','Линейная теория');
grid on; xlabel('\Omega, рад/с'); ylabel('Амплитуда, рад');
title('Амплитудно-частотная характеристика'); legend('Location','best');

%% РИСУНОК 13 — энергия в разных режимах
figure('Name','Рисунок 13 — Энергия в разных режимах','Color','w'); hold on;
% Без трения
p.K1=0; p.K2=0; p.Fm=0;
[t,U]=ode45(@(t,u) pendulum_rhs(t,u,p),[0 20],[phi0;w0],opts);
plot(t,energy(U,p),'DisplayName','Без трения');
% Только вязкое трение
p.K1=0.5; p.K2=0; p.Fm=0;
[t,U]=ode45(@(t,u) pendulum_rhs(t,u,p),[0 20],[phi0;w0],opts);
plot(t,energy(U,p),'DisplayName','Вязкое трение K_1=0.5');
% Вязкое + квадратичное сопротивление
p.K1=0.1; p.K2=0.2; p.Fm=0;
[t,U]=ode45(@(t,u) pendulum_rhs(t,u,p),[0 20],[phi0;w0],opts);
plot(t,energy(U,p),'DisplayName','K_1=0.1, K_2=0.2');
% Вынужденный режим: нулевые начальные условия
p.K1=2*beta*p.m*p.l^2; p.K2=0; p.Fm=1; p.Om=2;
[t,U]=ode45(@(t,u) pendulum_rhs(t,u,p),[0 50],[0;0],opts);
plot(t,energy(U,p),'DisplayName','Внешняя сила, \Omega=2');
grid on; xlabel('t, с'); ylabel('E/(ml^2)');
title('Энергия маятника в различных режимах'); legend('Location','best');

disp('Готово: построены рисунки 2–13 по уравнениям и настройкам lab3_pendulum.slx.');

%% Правая часть системы, повторяющая блоки Sum, Gain, Abs, Product, Sin
function du=pendulum_rhs(t,u,p)
phi=u(1); w=u(2);
external = (p.Fm/(p.m*p.l^2))*sin(p.Om*t);
viscous  = (p.K1/(p.m*p.l^2))*w;
quadratic= (p.K2/(p.m*p.l^2))*w*abs(w);
gravity  = (p.g/p.l)*sin(phi);
du=[w; external-viscous-quadratic-gravity];
end
