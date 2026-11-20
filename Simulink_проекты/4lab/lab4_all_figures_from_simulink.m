%% ЛАБОРАТОРНАЯ РАБОТА №4 — ГРАФИКИ ПО ЧЕТЫРЁМ ИСХОДНЫМ СХЕМАМ Simulink
% task1_oscillator.slx, task2_firm_Shapovalov.slx,
% task3_Bieber.slx, task4_Kpop.slx.
%
% Все правые части ниже переписаны из Expr соответствующих блоков Fcn;
% начальные условия и параметры взяты из InitFcn и Integrator исходных SLX.
% Решатель исходных моделей: ode45, RelTol=1e-6, AbsTol=1e-9.

clear; clc; close all;
opts=odeset('RelTol',1e-6,'AbsTol',1e-9);

%% ЗАДАНИЕ 1. ЛИНЕЙНЫЙ ОСЦИЛЛЯТОР — РИСУНКИ 2, 3, 4
% InitFcn task1_oscillator.slx: m=1; k=0.5; l=4; x0=1; v0=0.
m=1; k=0.5; l=4; x0=1; v0=0;
kValues=[0 0.5 2 4 6];

% Рисунок 2 — x(t) и фазовые траектории при пяти значениях k
figure('Name','Рисунок 2 — Линейный осциллятор','Color','w');
tiledlayout(1,2,'TileSpacing','compact');
nexttile; hold on;
for kk=kValues
    [t,U]=ode45(@(t,u) oscillator_rhs(t,u,kk,l,m),[0 30],[x0;v0],opts);
    plot(t,U(:,1),'DisplayName',sprintf('k = %g',kk));
end
grid on; xlabel('t, с'); ylabel('x(t)'); title('Интегральные кривые'); legend('Location','best');
nexttile; hold on;
for kk=kValues
    [~,U]=ode45(@(t,u) oscillator_rhs(t,u,kk,l,m),[0 30],[x0;v0],opts);
    plot(U(:,1),U(:,2),'DisplayName',sprintf('k = %g',kk));
end
grid on; xlabel('x'); ylabel('v=x'''); title('Фазовые траектории'); legend('Location','best');

% Рисунок 3 — влияние начальных условий при k=0.5
k=0.5; initialPairs=[1 0; 0 1; 1 1; 2 0];
figure('Name','Рисунок 3 — Начальные условия осциллятора','Color','w');
tiledlayout(1,2,'TileSpacing','compact');
nexttile; hold on;
for j=1:size(initialPairs,1)
    ic=initialPairs(j,:)';
    [t,U]=ode45(@(t,u) oscillator_rhs(t,u,k,l,m),[0 30],ic,opts);
    plot(t,U(:,1),'DisplayName',sprintf('x_0=%g, v_0=%g',ic(1),ic(2)));
end
grid on; xlabel('t, с'); ylabel('x(t)'); title('Зависимость от начальных условий'); legend('Location','best');
nexttile; hold on;
for j=1:size(initialPairs,1)
    ic=initialPairs(j,:)';
    [~,U]=ode45(@(t,u) oscillator_rhs(t,u,k,l,m),[0 30],ic,opts);
    plot(U(:,1),U(:,2),'DisplayName',sprintf('(%g; %g)',ic(1),ic(2)));
end
grid on; xlabel('x'); ylabel('v'); title('Фазовые траектории'); legend('Location','best');

% Рисунок 4 — влияние жёсткости l=1,4,9,16 при k=0.5
lValues=[1 4 9 16];
figure('Name','Рисунок 4 — Влияние жёсткости','Color','w'); hold on;
for ll=lValues
    [t,U]=ode45(@(t,u) oscillator_rhs(t,u,0.5,ll,m),[0 30],[1;0],opts);
    plot(t,U(:,1),'DisplayName',sprintf('l = %g',ll));
end
grid on; xlabel('t, с'); ylabel('x(t)'); title('Влияние жёсткости пружины'); legend('Location','best');

%% ЗАДАНИЕ 2. МОДЕЛЬ ШАПОВАЛОВА — РИСУНКИ 6, 7, 8, 9
% InitFcn task2_firm_Shapovalov.slx:
% alpha=5; beta=8; delta=1; mu=2.1; sigma=4.1; gamma=1;
% x0=y0=z0=1. Интеграторы int_x/int_y/int_z имеют эти IC.
firm.alpha=5; firm.beta=8; firm.delta=1; firm.mu=2.1; firm.sigma=4.1;
gammas=[0.5 1 2 5]; icFirm=[1;1;1];

% Рисунок 6 — временные зависимости при gamma=0.5,1,2,5
figure('Name','Рисунок 6 — Модель фирмы','Color','w');
tiledlayout(4,1,'TileSpacing','compact');
for j=1:numel(gammas)
    firm.gamma=gammas(j);
    [t,U]=ode45(@(t,u) firm_rhs(t,u,firm),[0 200],icFirm,opts);
    nexttile; plot(t,U,'LineWidth',0.9); grid on;
    ylabel('Значение'); title(sprintf('\gamma = %g',firm.gamma));
    if j==1, legend('x','y','z','Location','best'); end
end
xlabel('t, усл. ед.');

% Рисунок 7 — 3D фазовые траектории в пространстве (x,y,z)
figure('Name','Рисунок 7 — Фазовые траектории фирмы','Color','w');
tiledlayout(2,2,'TileSpacing','compact');
for j=1:numel(gammas)
    firm.gamma=gammas(j);
    [~,U]=ode45(@(t,u) firm_rhs(t,u,firm),[0 200],icFirm,opts);
    nexttile; plot3(U(:,1),U(:,2),U(:,3),'LineWidth',0.9); grid on;
    xlabel('x'); ylabel('y'); zlabel('z'); title(sprintf('\gamma = %g',firm.gamma)); view(35,25);
end
sgtitle('Фазовые траектории в пространстве (x,y,z)');

% Рисунок 8 — локальные максимумы z(t) после переходного процесса
% Параметрический прогон gamma по диапазону [0;10], начальные условия [1;1;1].
gammaScan=0.1:0.025:10; Gmax=[]; Zmax=[];
for gg=gammaScan
    firm.gamma=gg;
    [t,U]=ode45(@(t,u) firm_rhs(t,u,firm),[0 200],icFirm,opts);
    z=U(:,3); keep=t>=50; tz=t(keep); zz=z(keep); %#ok<NASGU>
    loc=find(zz(2:end-1)>zz(1:end-2) & zz(2:end-1)>=zz(3:end))+1;
    if ~isempty(loc)
        Gmax=[Gmax; repmat(gg,numel(loc),1)]; %#ok<AGROW>
        Zmax=[Zmax; zz(loc)]; %#ok<AGROW>
    end
end
figure('Name','Рисунок 8 — Диаграмма режимов фирмы','Color','w');
plot(Gmax,Zmax,'.','MarkerSize',5); grid on;
xlabel('\gamma'); ylabel('Локальные максимумы z(t)');
title('Локальные максимумы z(t) после переходного процесса');

% Рисунок 9 — чувствительность к x0: 1 и 1.001 при gamma=1
firm.gamma=1;
figure('Name','Рисунок 9 — Чувствительность к начальному условию','Color','w'); hold on;
for xx0=[1 1.001]
    [t,U]=ode45(@(t,u) firm_rhs(t,u,firm),[0 100],[xx0;1;1],opts);
    plot(t,U(:,1),'DisplayName',sprintf('x_0 = %.3f',xx0));
end
grid on; xlabel('t, усл. ед.'); ylabel('x(t)');
title('Чувствительность к начальному условию при \gamma=1'); legend('Location','best');

%% ЗАДАНИЕ 3. БИБЕР-ЛИХОРАДКА — РИСУНКИ 11, 12, 13, 14
% InitFcn task3_Bieber.slx:
% Pi=10; beta=8.3e-4; mu=1/144; b=1/24;
% S0=1500; B0=3; R0=0. В Fcn f_B стоит -mu*B.
bib.Pi=10; bib.beta=8.3e-4; bib.mu=1/144;
icSBR=[1500;3;0];

% Рисунок 11 — b=1/24 и b=2
figure('Name','Рисунок 11 — Бибер-лихорадка','Color','w');
tiledlayout(1,2,'TileSpacing','compact');
for j=1:2
    if j==1, bib.b=1/24; else, bib.b=2; end
    [t,U]=ode45(@(t,u) bieber_rhs(t,u,bib),[0 1200],icSBR,opts);
    nexttile; plot(t,U,'LineWidth',1); grid on;
    xlabel('t, мес.'); ylabel('Численность'); title(sprintf('b = %g',bib.b));
    legend('S','B','R','Location','best');
end

% Рисунок 12 — пять наборов начальных условий при b=1/24
bib.b=1/24;
initialSBR=[1500 3 0; 10 1 0; 1e5 10 0; 500 500 500; 0 1000 0];
figure('Name','Рисунок 12 — Влияние начальных условий','Color','w');
tiledlayout(1,3,'TileSpacing','compact'); stateNames={'S','B','R'};
for q=1:3
    nexttile; hold on;
    for j=1:size(initialSBR,1)
        [t,U]=ode45(@(t,u) bieber_rhs(t,u,bib),[0 3000],initialSBR(j,:)',opts);
        plot(t,U(:,q),'DisplayName',sprintf('Набор %d',j));
    end
    grid on; xlabel('t, мес.'); ylabel(stateNames{q}); title(stateNames{q});
    if q==1, legend('Location','best'); end
end

% Рисунок 13 — фазовая траектория в плоскости (S,B)
[t,U]=ode45(@(t,u) bieber_rhs(t,u,bib),[0 1200],icSBR,opts);
figure('Name','Рисунок 13 — Фазовая траектория S-B','Color','w');
plot(U(:,1),U(:,2),'LineWidth',1.1); grid on;
xlabel('S'); ylabel('B'); title('Фазовая траектория в плоскости (S,B)');

% Рисунок 14 — влияние скорости разочарования b на B(t)
bValues=[1/48 1/24 1/6 1 2];
figure('Name','Рисунок 14 — Влияние параметра b','Color','w'); hold on;
for bb=bValues
    bib.b=bb;
    [t,U]=ode45(@(t,u) bieber_rhs(t,u,bib),[0 1200],icSBR,opts);
    plot(t,U(:,2),'DisplayName',sprintf('b = %.4g',bb));
end
grid on; xlabel('t, мес.'); ylabel('B(t)');
title('Влияние скорости разочарования на число фанатов'); legend('Location','best');

%% ЗАДАНИЕ 4. K-POP-ЛИХОРАДКА — РИСУНКИ 16, 17, 18
% InitFcn task4_Kpop.slx:
% Pi=10; beta=8.3e-4; mu=1/144; b=1/24; eps=0.75;
% P=2; N=1; S0=1500; B0=3; R0=0.
% f_S, f_B, f_R ниже совпадают с Expr трёх Fcn в исходном SLX.
kp.Pi=10; kp.beta=8.3e-4; kp.mu=1/144; kp.eps=0.75;

% Рисунок 16 — пять вариантов СМИ для b=1/24 и b=2
media=[2 1; 0 0; 0 2; 2 0; 5 1];
mediaNames={'P=2, N=1';'P=0, N=0';'P=0, N=2';'P=2, N=0';'P=5, N=1'};
figure('Name','Рисунок 16 — K-pop при разных СМИ','Color','w');
tiledlayout(2,5,'TileSpacing','compact');
for row=1:2
    if row==1, kp.b=1/24; else, kp.b=2; end
    for j=1:size(media,1)
        kp.P=media(j,1); kp.N=media(j,2);
        [t,U]=ode45(@(t,u) kpop_rhs(t,u,kp),[0 1200],icSBR,opts);
        nexttile((row-1)*5+j); plot(t,U,'LineWidth',0.9); grid on;
        xlabel('t, мес.'); ylabel('Численность');
        title(sprintf('%s, b=%g',mediaNames{j},kp.b));
        if j==1, legend('S','B','R','Location','best'); end
    end
end
sgtitle('Решения K-pop-модели при разных параметрах СМИ');

% Рисунок 17 — начальные условия при b=1/24, P=2, N=1
kp.b=1/24; kp.P=2; kp.N=1;
figure('Name','Рисунок 17 — Начальные условия K-pop','Color','w');
tiledlayout(1,3,'TileSpacing','compact');
for q=1:3
    nexttile; hold on;
    for j=1:size(initialSBR,1)
        [t,U]=ode45(@(t,u) kpop_rhs(t,u,kp),[0 3000],initialSBR(j,:)',opts);
        plot(t,U(:,q),'DisplayName',sprintf('Набор %d',j));
    end
    grid on; xlabel('t, мес.'); ylabel(stateNames{q}); title(stateNames{q});
    if q==1, legend('Location','best'); end
end

% Рисунок 18 — предельные значения S,B,R в зависимости от P при N=1
kp.b=1/24; kp.N=1; Pscan=0:0.1:6;
steady=zeros(numel(Pscan),3);
for j=1:numel(Pscan)
    kp.P=Pscan(j);
    [~,U]=ode45(@(t,u) kpop_rhs(t,u,kp),[0 3000],icSBR,opts);
    steady(j,:)=U(end,:);
end
figure('Name','Рисунок 18 — Предельные значения при разных P','Color','w');
plot(Pscan,steady,'LineWidth',1.3); grid on;
xlabel('P (при N=1)'); ylabel('Предельное значение');
title('Предельные значения S, B, R в зависимости от P');
legend('S','B','R','Location','best');

disp('Готово: построены графики по уравнениям и InitFcn исходных четырёх SLX-моделей.');

%% ПРАВЫЕ ЧАСТИ СИСТЕМ — ДОСЛОВНО ПО ВЫРАЖЕНИЯМ БЛОКОВ Fcn
function du=oscillator_rhs(~,u,k,l,m)
% f_x: u[2]; f_v: -(k*u[2]+l*u[1])/m
du=[u(2); -(k*u(2)+l*u(1))/m];
end

function du=firm_rhs(~,u,p)
% f_x=-sigma*u[1]+delta*u[2]
% f_y=mu*(u[1]+u[2])-beta*u[1]*u[3]
% f_z=alpha*u[1]*u[2]-gamma*u[3]
x=u(1); y=u(2); z=u(3);
du=[-p.sigma*x+p.delta*y; p.mu*(x+y)-p.beta*x*z; p.alpha*x*y-p.gamma*z];
end

function du=bieber_rhs(~,u,p)
% f_S=Pi-beta*u[1]*u[2]-mu*u[1]
% f_B=beta*u[1]*u[2]-mu*u[2]-b*u[2]
% f_R=b*u[2]-mu*u[3]
S=u(1); B=u(2); R=u(3); %#ok<NASGU>
du=[p.Pi-p.beta*S*B-p.mu*S; p.beta*S*B-p.mu*B-p.b*B; p.b*B-p.mu*R];
end

function du=kpop_rhs(~,u,p)
% Выражения f_S, f_B, f_R из task4_Kpop.slx без упрощения.
S=u(1); B=u(2); R=u(3);
dS=p.Pi-p.beta*S*B-p.eps*p.P*S+(1-p.eps)*p.N*B-p.mu*S+p.eps*p.P*R-(1-p.eps)*p.N*S;
dB=p.beta*S*B+p.eps*p.P*S-(1-p.eps)*p.N*B-p.mu*B-p.b*B;
dR=p.b*B+(1-p.eps)*p.N*S-p.mu*R-p.eps*p.P*R;
du=[dS;dB;dR];
end
