% Carregar o sinal
data = load('sinais.mat'); 
x1 = data.(vars{1});
x2 = data.x2;  
fs2 = 96000; 
fs1 = 8000;

% Chamar a função para plotar as réplicas
plot_fft_replicas(x2, 2*pi*fs2, 2,fs2);  % 2 réplicas de cada lado (totalizando 4)


function plot_fft_replicas(x, f_period, num_replicas, fs)
    % Computa a FFT do sinal e aplica fftshift para centralizar em 0
    X = fftshift(fft(x));
    N = length(x);
    
    % Eixo de frequência original (centrado em zero)
    f = (-N/2:N/2-1) * (fs / N);
    
    % Sem normalização: mantém a magnitude original
    X_mag = abs(X);

    % Número total de pontos após as réplicas
    num_shifts = 2 * num_replicas + 1;
    N_total = N * num_shifts;
    
    % Pré-alocar memória para desempenho
    f_replicas = zeros(1, N_total);
    X_replicas = zeros(1, N_total);
    
    % Criar réplicas espectrais com período correto e centradas
    for k = -num_replicas:num_replicas
        idx = (k + num_replicas) * N + (1:N); % Índices corretos
        f_replicas(idx) = f + k * f_period; % Usa f_period para deslocar corretamente
        X_replicas(idx) = X_mag; % Mantém a magnitude original
    end

    % Plotar as réplicas da FFT
    figure;
    plot(f_replicas, X_replicas, 'b');
    xlabel('Frequência (Hz)');
    ylabel('|X(f)|');
    title('FFT com Réplicas Espectrais Centradas');
    grid on;
    xlim([-num_replicas * f_period, (num_replicas + 1) * f_period]); % Ajusta os limites do gráfico
end
