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
    
    % Eixo de frequência original (faixa de 0 a fs)
    f = (0:N-1) * (fs / N);
    
    % Normaliza a FFT para facilitar a visualização
    X_mag = abs(X) / max(abs(X));
    
    % Criar réplicas espectrais
    f_replicas = [];
    X_replicas = [];

    for k = -num_replicas:num_replicas
        f_shifted = f + k * fs;  % Desloca o eixo de frequência
        
        % Armazena os valores mantendo a mesma estrutura
        f_replicas = [f_replicas, f_shifted(:)']; % Garante que f seja uma linha
        X_replicas = [X_replicas, X_mag(:)']; % Garante que X_mag seja uma linha
    end

    % Reordena os valores para evitar descontinuidade na plotagem
    [f_replicas, idx] = sort(f_replicas);
    X_replicas = X_replicas(idx);
    
    % Plotar as réplicas da FFT
    figure;
    plot(f_replicas, X_replicas, 'b');
    xlabel('Frequência (Hz)');
    ylabel('Magnitude Normalizada');
    title('FFT com Réplicas Espectrais');
    grid on;
    xlim([-num_replicas * fs, (num_replicas + 1) * fs]); % Ajusta os limites do gráfico
end

