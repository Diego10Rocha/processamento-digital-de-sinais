% Carregar o sinal
data = load('sinais.mat'); 
x2 = data.x2;  
fs2 = 96000; 

% Chamar a função para plotar as réplicas
plot_fft_replicas(x2, fs2, 2);  % 2 réplicas de cada lado (totalizando 4)


function plot_fft_replicas(x, fs, num_replicas)
    % Computa a FFT do sinal
    X = fft(x);
    N = length(x);
    
    % Eixo de frequência original
    f = (0:N-1) * (fs / N);
    
    % Normaliza a FFT
    X_mag = abs(X) / max(abs(X));

    % Número total de pontos após as réplicas
    num_shifts = 2 * num_replicas + 1;
    N_total = N * num_shifts;
    
    % Pré-alocar memória para desempenho
    f_replicas = zeros(1, N_total);
    X_replicas = zeros(1, N_total);
    
    % Criar réplicas espectrais
    for k = -num_replicas:num_replicas
        idx = (k + num_replicas) * N + (1:N); % Índices corretos
        f_replicas(idx) = f + k * fs; % Desloca o eixo de frequência
        X_replicas(idx) = X_mag; % Mantém a magnitude
    end

    % Plotar as réplicas da FFT
    figure;
    plot(f_replicas, X_replicas, 'b');
    xlabel('Frequência (Hz)');
    ylabel('Magnitude Normalizada');
    title('FFT com Réplicas Espectrais');
    grid on;
    xlim([-num_replicas * fs, (num_replicas + 1) * fs]); % Ajusta os limites do gráfico
end

