% Лабораторная работа №2. Вариант 3
% Параметры: Mean = 0, Variance = 5, Sample time = 0.01

% Загрузка данных из Simulink
x = out.noise_data;

% Просмотр первых 10 значений
disp('Первые 10 значений:');
disp(x(1:10));

% Расчёт статистических характеристик
mu = mean(x);          % Математическое ожидание
D = var(x);            % Дисперсия
sigma = std(x);        % СКО

% Вывод результатов
fprintf('MO = %.4f\n', mu);
fprintf('Дисперсия = %.4f\n', D);
fprintf('CKO = %.4f\n', sigma);

% Построение гистограммы
figure;
histogram(x, 50, 'Normalization', 'pdf');
hold on;

% Линейное пространство для теоретической функции
xmin = min(x);
xmax = max(x);
xx = linspace(xmin, xmax, 200);

% Теоретическая плотность нормального распределения
pdf_gauss = (1/(sigma*sqrt(2*pi))) * exp(-((xx - mu).^2)/(2*sigma^2));

% График теоретической функци
% и
plot(xx, pdf_gauss, 'r', 'LineWidth', 2);

% Оформление
legend('Экспериментальная гистограмма', 'Теоретическая плотность');
title('Сравнение эксперимента и теории (вариант 3)');
xlabel('x');
ylabel('Плотность');
grid on;