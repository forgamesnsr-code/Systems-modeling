%% LAB 4 — ЕДИНЫЙ ЗАПУСК ВСЕХ ГРАФИКОВ ОТЧЁТА
clear; clc; close all;
opts = odeset('RelTol',1e-6,'AbsTol',1e-9);

%% ЗАДАНИЕ 1. ЛИНЕЙНЫЙ ОСЦИЛЛЯТОР — РИСУНКИ 2, 3, 4
m=1; l=4; x0=1; v0=0;
kvals=[0 0.5 2 4 6]; tspan=[0 15];

figure('Name','Рисунок 2 — Осциллятор: влияние трения','Color','w');
tiledlayout(1,2,'TileSpacing','compact');
nexttile; hold on;
for k=kvals
    [t,U]=ode45(@(t,u) osc_rhs(t,u,k,l,m),tspan,[x0;v0],opts);
    plot(t,U(:,1),'DisplayName',sprintf('k = %g',k));
end
grid on; xlabel('t, c'); ylabel('x(t)'); title('Интегральные кривые');
legend('Location','best');
nexttile; hold on;
for k=kvals
    [~,U]=ode45(@(t,u) osc_rhs(t,u,k,l,m),tspan,[x0;v0],opts);
    plot(U(:,1),U(:,2),'DisplayName',sprintf('k = %g',k));
end
grid on; xlabel('x'); ylabel('v'); title('Фазовые траектории');
legend('Location','best');

% Рисунок 3 — влияние начальных условий при k=0.5
k=0.5; initials=[1 0; 0 1; 1 1; 2 0]; tspan=[0 20];
figure('Name','Рисунок 3 — Начальные условия','Color','w');
tiledlayout(1,2,'TileSpacing','compact');
nexttile; hold on;
for i=1:size(initials,1)
    u0=initials(i,:)';
    [t,U]=ode45(@(t,u) osc_rhs(t,u,k,l,m),tspan,u0,opts);
    plot(t,U(:,1),'DisplayName',sprintf('x_0=%g, v_0=%g',u0(1),u0(2)));
end
grid on; xlabel('t, c'); ylabel('x(t)'); title('Интегральные кривые');
legend('Location','best');
nexttile; hold on;
for i=1:size(initials,1)
    u0=initials(i,:)';
    [~,U]=ode45(@(t,u) osc_rhs(t,u,k,l,m),tspan,u0,opts);
    plot(U(:,1),U(:,2),'DisplayName',sprintf('(%g; %g)',u0(1),u0(2)));
end
grid on; xlabel('x'); ylabel('v'); title('Фазовые траектории');
legend('Location','best');

% Рисунок 4 — влияние жёсткости l при k=0.5
k=0.5; lvals=[1 4 9 16]; tspan=[0 15];
figure('Name','Рисунок 4 — Влияние жёсткости','Color','w'); hold on;
for ll=lvals
    [t,U]=ode45(@(t,u) osc_rhs(t,u,k,ll,m),tspan,[1;0],opts);
    plot(t,U(:,1),'DisplayName',sprintf('l = %g',ll));
end
grid on; xlabel('t, c'); ylabel('x(t)'); title('Влияние жёсткости пружины');
legend('Location','best');

%% ЗАДАНИЕ 2. МОДЕЛЬ ШАПОВАЛОВА — РИСУНКИ 6, 7, 8, 9
firm.alpha=5; firm.beta=8; firm.delta=1; firm.mu=2.1; firm.sigma=4.1;
gammas=[0.5 1 2 5]; u0=[1;1;1]; tspan=[0 60];

% Рисунок 6 — временные зависимости x(t), y(t), z(t)
figure('Name','Рисунок 6 — Модель фирмы','Color','w');
tiledlayout(4,1,'TileSpacing','compact');
for j=1:numel(gammas)
    firm.gamma=gammas(j);
    [t,U]=ode45(@(t,u) firm_rhs(t,u,firm),tspan,u0,opts);
    nexttile; plot(t,U,'LineWidth',1); grid on;
    ylabel('Значение'); title(sprintf('\\gamma = %g',firm.gamma));
    if j==1, legend('x','y','z','Location','best'); end
end
xlabel('t');

% Рисунок 7 — трёхмерные фазовые траектории
figure('Name','Рисунок 7 — Фазовые траектории фирмы','Color','w');
tiledlayout(2,2,'TileSpacing','compact');
for j=1:numel(gammas)
    firm.gamma=gammas(j);
    [~,U]=ode45(@(t,u) firm_rhs(t,u,firm),tspan,u0,opts);
    nexttile; plot3(U(:,1),U(:,2),U(:,3),'LineWidth',0.9);
    grid on; xlabel('x'); ylabel('y'); zlabel('z');
    title(sprintf('\\gamma = %g',firm.gamma)); view(35,25);
end
sgtitle('Фазовые траектории в пространстве (x,y,z)');

% Рисунок 8 — локальные максимумы z после переходного процесса
gscan=0.1:0.025:10; G=[]; Zmax=[];
for g=gscan
    firm.gamma=g;
    [t,U]=ode45(@(t,u) firm_rhs(t,u,firm),[0 60],u0,opts);
    z=U(:,3); keep=t>=20; zk=z(keep);
    idx=find(zk(2:end-1)>zk(1:end-2) & zk(2:end-1)>=zk(3:end))+1;
    if isempty(idx)
        G(end+1,1)=g; Zmax(end+1,1)=zk(end); %#ok<SAGROW>
    else
        G=[G; repmat(g,numel(idx),1)]; %#ok<AGROW>
        Zmax=[Zmax; zk(idx)]; %#ok<AGROW>
    end
end
figure('Name','Рисунок 8 — Диаграмма режимов','Color','w');
plot(G,Zmax,'.','MarkerSize',5); grid on;
xlabel('\gamma'); ylabel('Локальные максимумы z(t)');
title('Локальные максимумы z(t) в зависимости от \gamma');

% Рисунок 9 — чувствительность к начальному x0 при gamma=1
firm.gamma=1; tspan=[0 60];
figure('Name','Рисунок 9 — Чувствительность к начальному условию','Color','w'); hold on;
for xx0=[1 1.001]
    [t,U]=ode45(@(t,u) firm_rhs(t,u,firm),tspan,[xx0;1;1],opts);
    plot(t,U(:,1),'DisplayName',sprintf('x_0 = %.3f',xx0));
end
grid on; xlabel('t'); ylabel('x(t)'); title('Чувствительность к начальному условию при \gamma=1');
legend('Location','best');

%% ЗАДАНИЕ 3. БИБЕР-ЛИХОРАДКА — РИСУНКИ 11, 12, 13, 14
bib.Pi=10; bib.beta=8.3e-4; bib.mu=1/144;
tspan=[0 1200]; u0=[1500;3;0];

% Рисунок 11 — b=1/24 и b=2
figure('Name','Рисунок 11 — Бибер-лихорадка','Color','w');
tiledlayout(1,2,'TileSpacing','compact');
for j=1:2
    if j==1, bib.b=1/24; else, bib.b=2; end
    [t,U]=ode45(@(t,u) bib_rhs(t,u,bib),tspan,u0,opts);
    nexttile; plot(t,U,'LineWidth',1); grid on;
    xlabel('t, мес.'); ylabel('Численность');
    title(sprintf('b = %g',bib.b)); legend('S','B','R','Location','best');
end

% Рисунок 12 — влияние начальных условий, b=1/24
bib.b=1/24;
initials_bib=[1500 3 0; 10 1 0; 1e5 10 0; 500 500 500; 0 1000 0];
figure('Name','Рисунок 12 — Начальные условия Бибер-модели','Color','w');
tiledlayout(1,3,'TileSpacing','compact');
names={'S','B','R'};
for q=1:3
    nexttile; hold on;
    for j=1:size(initials_bib,1)
        [t,U]=ode45(@(t,u) bib_rhs(t,u,bib),[0 1500],initials_bib(j,:)',opts);
        plot(t,U(:,q),'DisplayName',sprintf('Набор %d',j));
    end
    grid on; xlabel('t, мес.'); ylabel(names{q}); title(names{q});
    if q==1, legend('Location','best'); end
end

% Рисунок 13 — фазовая траектория (S,B) при стандартных начальных условиях
[t,U]=ode45(@(t,u) bib_rhs(t,u,bib),[0 1500],u0,opts);
figure('Name','Рисунок 13 — Фазовая траектория S-B','Color','w');
plot(U(:,1),U(:,2),'LineWidth',1); grid on;
xlabel('S'); ylabel('B'); title('Фазовая траектория в плоскости (S,B)');

% Рисунок 14 — влияние скорости разочарования b на B(t)
bvals=[1/48 1/24 1/6 1 2]; % значения, соответствующие таблице отчёта с округлением
figure('Name','Рисунок 14 — Влияние параметра b','Color','w'); hold on;
for bb=bvals
    bib.b=bb;
    [t,U]=ode45(@(t,u) bib_rhs(t,u,bib),[0 1200],u0,opts);
    plot(t,U(:,2),'DisplayName',sprintf('b = %.4g',bb));
end
grid on; xlabel('t, мес.'); ylabel('B(t)');
title('Влияние скорости разочарования на число фанатов');
legend('Location','best');

%% ЗАДАНИЕ 4. K-POP-ЛИХОРАДКА С УЧЁТОМ СМИ — РИСУНКИ 16, 17, 18
kp.Pi=10; kp.beta=8.3e-4; kp.mu=1/144; kp.eps=0.75;
u0=[1500;3;0];

% Рисунок 16 — пять вариантов СМИ для b=1/24 и b=2
media=[2 1; 0 0; 0 2; 2 0; 5 1];
mediaNames={'P=2, N=1'; 'P=0, N=0'; ...
            'P=0, N=2'; 'P=2, N=0'; 'P=5, N=1'};

figure('Name','Рисунок 16 — K-pop при разных СМИ','Color','w');
tiledlayout(2,5,'TileSpacing','compact');

for row=1:2
    if row==1
        kp.b=1/24;
    else
        kp.b=2;
    end

    for j=1:size(media,1)
        kp.P=media(j,1);
        kp.N=media(j,2);

        [t,U]=ode45(@(t,u) kpop_rhs(t,u,kp), ...
                    [0 1200],u0,opts);

        nexttile((row-1)*5+j);
        plot(t,U,'LineWidth',0.9);
        grid on;
        xlabel('t, мес.');
        ylabel('Численность');

        title(sprintf('%s, b=%g',mediaNames{j},kp.b));

        if j==1
            legend('S','B','R','Location','best');
        end
    end
end

sgtitle('Решения K-pop-модели при разных параметрах СМИ');

% Рисунок 18 — установившиеся S, B, R в зависимости от P при N=1, b=1/24
kp.b=1/24; kp.N=1; Pscan=linspace(0,6,61);
steady=zeros(numel(Pscan),3);
for j=1:numel(Pscan)
    kp.P=Pscan(j);
    [~,U]=ode45(@(t,u) kpop_rhs(t,u,kp),[0 3000],u0,opts);
    steady(j,:)=U(end,:);
end
figure('Name','Рисунок 18 — Предельные значения при разных P','Color','w');
plot(Pscan,steady,'LineWidth',1.4); grid on;
xlabel('P (N=1)'); ylabel('Предельное значение');
title('Предельные значения S, B, R в зависимости от P');
legend('S','B','R','Location','best');

disp('Готово: построены рисунки 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14, 16, 17, 18.');

%% ЛОКАЛЬНЫЕ ФУНКЦИИ ПРАВЫХ ЧАСТЕЙ СИСТЕМ
function du=osc_rhs(~,u,k,l,m)
du=[u(2);(-k*u(2)-l*u(1))/m];
end

function du=firm_rhs(~,u,p)
x=u(1); y=u(2); z=u(3);
du=[-p.sigma*x+p.delta*y; p.mu*(x+y)-p.beta*x*z; p.alpha*x*y-p.gamma*z];
end

function du=bib_rhs(~,u,p)
S=u(1); B=u(2); R=u(3);
du=[p.Pi-p.beta*S*B-p.mu*S; ...
    p.beta*S*B-p.mu*B-p.b*B; ...
    p.b*B-p.mu*R];
end

function du=kpop_rhs(~,u,p)
S=u(1); B=u(2); R=u(3);
dS=p.Pi-p.beta*S*B-p.eps*p.P*S+(1-p.eps)*p.N*B-p.mu*S ...
   +p.eps*p.P*R-(1-p.eps)*p.N*S;
dB=p.beta*S*B+p.eps*p.P*S-(1-p.eps)*p.N*B-p.mu*B-p.b*B;
dR=p.b*B+(1-p.eps)*p.N*S-p.mu*R-p.eps*p.P*R;
du=[dS;dB;dR];
end
