%% 1. Carregar os dados do arquivo 'sinais.mat'
data = load('sinais.mat'); % Carregar o arquivo
vars = fieldnames(data);   % Obter os nomes das variáveis

%% Assumindo que as variáveis do arquivo são x1 e x2
x1 = data.(vars{1}); % Primeiro sinal
x2 = data.(vars{2}); % Segundo sinal

% Definir as frequências de amostragem
fs_x1 = 8000;  % Frequência de amostragem de x1 (8 kHz)
fs_x2 = 96000;  % Frequência de amostragem de x2 (96 kHz)

% Gerar os vetores de tempo para cada sinal
t_x1 = (0:length(x1)-1) / fs_x1;  % Vetor de tempo para x1
t_x2 = (0:length(x2)-1) / fs_x2;  % Vetor de tempo para x2

% Criar uma nova figura para os gráficos
figure;

% Plotar x1 no domínio do tempo
subplot(2, 1, 1);  % Dividir a área de plotagem em 2, e plotar x1 na parte superior
plot(t_x1, x1);
title('Sinal x1 no Domínio do Tempo (8 kHz)');
xlabel('Tempo (s)');
ylabel('Amplitude');
grid on;

% Plotar x2 no domínio do tempo
subplot(2, 1, 2);  % Plotar x2 na parte inferior
plot(t_x2, x2);
title('Sinal x2 no Domínio do Tempo (96 kHz)');
xlabel('Tempo (s)');
ylabel('Amplitude');
grid on;

% Adicionar título geral para os gráficos
sgtitle('Sinais x1 e x2 no Domínio do Tempo');

