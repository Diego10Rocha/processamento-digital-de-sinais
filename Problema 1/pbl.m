clear; clc; close all;

%% 1. Carregar os dados do arquivo 'sinais.mat'
data = load('sinais.mat'); % Carregar o arquivo
vars = fieldnames(data);   % Obter os nomes das variáveis

%% Assumindo que as variáveis do arquivo são x1 e x2
x1 = data.(vars{1}); % Primeiro sinal
x2 = data.(vars{2}); % Segundo sinal

%% Definir manualmente as taxas de amostragem
fs1 = 8000;  % 8 kHz para x1
fs2 = 96000; % 96 kHz para x2
fs_final = 24000; % 16 kHz frequencia comum ao final das operações multitaxa
fc_passa_baixa_x1 = 4000; % frequência de corte do filtro passa-baixa
fc_passa_baixa_x2 = 12000; % frequência de corte do filtro passa-baixa

%% 2. Processamento de x2 (Subamostragem)
%% 2.1 Calcular a Transformada Discreta de Fourier (DFT) de x2[n]
fft_x2 = fft(x2);  
f_x2 = (0:length(x2)-1)*(fs2/length(x2));  % Frequências para x2[n] em Hz

%% 2.2 Criar o filtro passa-baixa com frequência de corte de fc_passa_baixa_x2 Hz
filtro_passa_baixa_x2 = (f_x2 <= fc_passa_baixa_x2);  % Filtro que permite apenas frequências abaixo de fc_passa_baixa_x2 Hz

%% 2.3 Aplicar o filtro no domínio da frequência e no dominio do tempo
X2_filtrado_frequencia = fft_x2 .* filtro_passa_baixa_x2';   % Sinal filtrado no domínio da frequência
X2_filtrado_dominio_tempo = ifft(X2_filtrado_frequencia);  % Sinal filtrado no domínio do tempo

% Fator de decimação para reduzir de fs2 Hz para fs_final Hz
D = fs2 / fs_final;  % Fator de decimação (fs2 Hz / fs_final Hz = D)

%% 2.4 Fazendo subamostragem de x2[n]
sinal_x2 = real(X2_filtrado_dominio_tempo);
x2_subamostrado = sinal_x2(1: D: end);  % Subamostrando o sinal
x2_subamostrado = double(x2_subamostrado);  % Garantir tipo double

%% 2.5 Calcular o espectro do sinal subamostrado através da FFT
fft_X2_subamostrado = fft(x2_subamostrado);  
f2_subamostrado = (0:length(x2_subamostrado)-1)*(fs_final/length(x2_subamostrado));

%% 3. Fazendo superamostragem de x1[n]
%% 3.1 Calcular a Transformada Rapida de Fourier (FFT) de x1[n]
fft_x1 = fft(x1);  
f1 = (0:length(x1)-1)*(fs1/length(x1));  % Frequências para x1[n] em Hz

% Fator de upsampling para x1
L1 = fs_final / fs1; 

% upsample do sinal
x1_superamostrado = funcao_superamostragem(x1, L1);  % Inserir zeros (upsampling)

%% Criar o filtro passa-baixa com frequência de corte de fc_passa_baixa Hz
f1_superamostrado = (0:length(x1_superamostrado)-1)*(fs_final/length(x1_superamostrado));
filtro_x1 = (f1_superamostrado <= fc_passa_baixa_x1);  % Filtro para até fc_passa_baixa_x1 Hz

%% Aplicar o filtro no domínio da frequência
fft_x1_superamostrado = fft(x1_superamostrado);  
x1_filtrado_frequencia = fft_x1_superamostrado .* filtro_x1';  
x1_filtrado_dominio_tempo = ifft(x1_filtrado_frequencia);  % Sinal interpolado no domínio do tempo
x1_filtrado_dominio_tempo = real(x1_filtrado_dominio_tempo);  % Garantir que seja real
x1_filtrado_dominio_tempo = double(x1_filtrado_dominio_tempo);  % Garantir tipo double

%% Soma dos sinais após processamento multitaxa
% Ajustar o comprimento dos sinais (se necessário)
min_length = min(length(x1_filtrado_dominio_tempo), length(x2_subamostrado));
x1_ajustado = x1_filtrado_dominio_tempo(1:min_length);
x2_ajustado = x2_subamostrado(1:min_length);

% Normalizar os sinais para evitar clipping
x1_normalizado = x1_ajustado / max(abs(x1_ajustado));
x2_normalizado = x2_ajustado / max(abs(x2_ajustado));

% Soma dos sinais normalizados
x_soma = x1_normalizado + x2_normalizado;

% Normalizar novamente a soma para evitar clipping
x_soma_normalizado = x_soma / max(abs(x_soma));

%% Plotar os sinais no domínio do tempo
figure('Name', 'Sinais no Domínio do Tempo');
% x1 interpolado
subplot(3,1,1);
t1 = (0:length(x1_normalizado)-1)/fs_final;
plot(t1, x1_normalizado);
title('x1[n] Superamostrado (16 kHz)');
xlabel('Tempo (s)');
ylabel('Amplitude');

% x2 decimado
subplot(3,1,2);
t2 = (0:length(x2_normalizado)-1)/fs_final;
plot(t2, x2_normalizado);
title('x2[n] Subamostrado (16 kHz)');
xlabel('Tempo (s)');
ylabel('Amplitude');

% Soma dos sinais
subplot(3,1,3);
t_soma = (0:length(x_soma_normalizado)-1)/fs_final;
plot(t_soma, x_soma_normalizado);
title('Soma dos Sinais (16 kHz)');
xlabel('Tempo (s)');
ylabel('Amplitude');

sgtitle('Sinais Processados e Somados');

%% Plotar domínios de frequência do sinal somado
figure('Name', 'Espectro de Frequência da Soma');
X_soma = fft(x_soma_normalizado);
f_soma = (0:length(x_soma_normalizado)-1)*(fs_final/length(x_soma_normalizado));

plot(f_soma(1:floor(length(x_soma_normalizado)/2)), abs(X_soma(1:floor(length(x_soma_normalizado)/2))));
title('Domínio da Frequência da Soma dos Sinais');
xlabel('Frequência (Hz)');
ylabel('|X(f)|');


%% Plotar domínios de frequência de x2
figure('Name', 'Espectro de Frequência de x2[n]');
% Original
subplot(2,1,1);
plot(f_x2(1:floor(length(x2)/2)), abs(fft_x2(1:floor(length(x2)/2))));
title('Domínio da Frequência de x2[n] Original');
xlabel('Frequência (Hz)');
ylabel('|X2(f)|');

% Subamostrado
subplot(2,1,2);
plot(f2_subamostrado(1:floor(length(x2_subamostrado)/2)), abs(fft_X2_subamostrado(1:floor(length(x2_subamostrado)/2))));
title('Domínio da Frequência de x2[n] Subamostrado (16 kHz)');
xlabel('Frequência (Hz)');
ylabel('|X2(f) Subamostrado|');

sgtitle('Espectro de Frequência de x2[n]');

%% Plotar domínios de frequência de x1
figure('Name', 'Espectro de Frequência de x1[n]');
% Original
subplot(2,1,1);
plot(f1(1:floor(length(x1)/2)), abs(fft_x1(1:floor(length(x1)/2))));
title('Domínio da Frequência de x1[n] Original');
xlabel('Frequência (Hz)');
ylabel('|X1(f)|');

% Superamostrado
subplot(2,1,2);
X1_k_interpolated = fft(x1_filtrado_dominio_tempo);  % Espectro do sinal interpolado
f1_interpolated = (0:length(x1_filtrado_dominio_tempo)-1)*(fs_final/length(x1_filtrado_dominio_tempo));
plot(f1_interpolated(1:floor(length(x1_filtrado_dominio_tempo)/2)), abs(X1_k_interpolated(1:floor(length(x1_filtrado_dominio_tempo)/2))));
title('Domínio da Frequência de x1[n] Superamostrado (16 kHz)');
xlabel('Frequência (Hz)');
ylabel('|X1(f) Interpolado|');

sgtitle('Espectro de Frequência de x1[n]');

%%  Salvar o sinal somado como arquivo WAV
audiowrite('sinal_somado3.wav', x_soma_normalizado, fs_final);

disp('Processamento concluído! O arquivo "sinal_somado.wav" foi salvo.');

%% Função manual de upsample
function output = funcao_superamostragem(signal, factor)
    % Implementação manual da função upsample
    % Insere (factor-1) zeros entre cada amostra do sinal original
    signalLength = length(signal);
    output = zeros(signalLength * factor, 1);
    output(1:factor:end) = signal;
end