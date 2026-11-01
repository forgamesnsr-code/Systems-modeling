bdclose all; clear; close all
g=9.81; l=1; m=1; mdl='lab3_pendulum'; load_system(mdl);
S=@(K1,K2,Fm,Om,phi0,T) sim(Simulink.SimulationInput(mdl).setModelParameter('StopTime',num2str(T)) ...
   .setVariable('K1',K1).setVariable('K2',K2).setVariable('Fm',Fm).setVariable('Om',Om).setVariable('phi0',phi0));

%% Часть 1
o=S(0,0,0,2,0.5,10); t=o.tout; p=o.phi_out;
figure; subplot(2,1,1); plot(t,p); grid on; ylabel('\phi'); subplot(2,1,2); plot(t,o.w_out); grid on; ylabel('\omega')
figure; plot(p,o.w_out); grid on; xlabel('\phi'); ylabel('\omega')
i=find(p(1:end-1)<0&p(2:end)>=0); tz=t(i)-p(i).*(t(i+1)-t(i))./(p(i+1)-p(i));
fprintf('T = %.3f с, теория %.3f с\n',mean(diff(tz)),2*pi*sqrt(l/g))

%% Часть 2
f2=figure; hold on; grid on; f3=figure; hold on; grid on;
for K1=[0.1 0.5 1]
    o=S(K1,0,0,2,0.5,20); nm=['K_1=' num2str(K1)];
    figure(f2); plot(o.tout,o.phi_out,'DisplayName',nm);
    figure(f3); plot(o.phi_out,o.w_out,'DisplayName',nm);
end
figure(f2); legend; figure(f3); legend

%% Часть 3
figure; hold on; grid on
for K2=[0 0.05 0.2]
    o=S(0.1,K2,0,2,0.5,20); plot(o.tout,o.phi_out,'DisplayName',['K_2=' num2str(K2)]);
end
legend

%% Часть 4
figure; n=0;
for Om=[1 2 3 5]
    n=n+1; o=S(0.4,0,1,Om,0,50); subplot(2,2,n); plot(o.tout,o.phi_out); grid on; title(['\omega=' num2str(Om)])
end
Oms=0.5:0.05:6; A=zeros(size(Oms));
for j=1:numel(Oms)
    [t,x]=ode45(@(t,x)[x(2); -0.4*x(2)-g/l*sin(x(1))+sin(Oms(j)*t)],[0 100],[0;0]);
    q=t>60; A(j)=(max(x(q,1))-min(x(q,1)))/2;
end
figure; plot(Oms,A); grid on; xlabel('\omega'); ylabel('Амплитуда'); [~,j]=max(A);
fprintf('Резонанс: %.2f рад/с\n',Oms(j))

%% Сохранить все окна в PNG
for f=findall(0,'Type','figure')', exportgraphics(f,sprintf('fig_%d.png',f.Number)); end