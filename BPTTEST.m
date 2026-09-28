% 1. Chargement des données 

nomFichier = 'C:\Users\HP\Documents\DATACRH.xlsx'; 
X = readmatrix(nomFichier); 
X = X(:, 1); 
X = X(~isnan(X)); 
N = length(X);

fprintf('--- Analyse de la série (N = %d données) ---\n', N);

%% ========================================================================
%% 1. TEST DE MANN-KENDALL (Tendance)
%% ========================================================================
S = 0;
for i = 1:(N-1)
    for j = (i+1):N
        S = S + sign(X(j) - X(i));
    end
end

% Calcul de la variance de S 
VarS = (N * (N - 1) * (2 * N + 5)) / 18;

% Calcul de la statistique Z
if S > 0
    Zmk = (S - 1) / sqrt(VarS);
elseif S < 0
    Zmk = (S + 1) / sqrt(VarS);
else
    Zmk = 0;
end

% Calcul de la p-value (test bilatéral)
p_MK = 2 * (1 - normcdf(abs(Zmk)));

fprintf('\n[Test de Mann-Kendall]\n');
fprintf('  Statistique S : %d\n', S);
fprintf('  Statistique Z : %.4f\n', Zmk);
fprintf('  p-value       : %.4f\n', p_MK);
if p_MK < 0.05
    fprintf('  Résultat      : Tendance significative détectée au seuil de 5%%.\n');
else
    fprintf('  Résultat      : Pas de tendance significative au seuil de 5%%.\n');
end

%% ========================================================================
%% 2. TEST DE PETTITT (Rupture non paramétrique)
%% ========================================================================
U = zeros(N, 1);
for t = 1:N
    for i = 1:t
        for j = 1:N
            U(t) = U(t) + sign(X(i) - X(j));
        end
    end
end

[K_pet, t_rupt_pet] = max(abs(U));
% p-value approximative de Pettitt
p_Pettitt = 2 * exp((-6 * K_pet^2) / (N^3 + N^2));

fprintf('\n[Test de Pettitt]\n');
fprintf('  Statistique K : %d\n', K_pet);
fprintf('  p-value       : %.4f\n', p_Pettitt);
if p_Pettitt < 0.05
    fprintf('  Résultat      : Rupture significative détectée à l''indice %d (Année/Point %d).\n', t_rupt_pet, t_rupt_pet);
else
    fprintf('  Résultat      : Pas de rupture significative au seuil de 5%%.\n');
end

%% ========================================================================
%% 3. TEST DE BUISHAND (Rupture paramétrique - Range Test)
%% ========================================================================
X_moy = mean(X);
S_cum = zeros(N, 1);

% Sommes cumulées des écarts à la moyenne
for k = 1:N
    S_cum(k) = sum(X(1:k) - X_moy);
end

% Statistique de Buishand (R) normalisée par l'écart-type
Dx = std(X, 1); % Écart-type empirique
S_double_etoile = S_cum / Dx;
R_buishand = (max(S_double_etoile) - min(S_double_etoile)) / sqrt(N);

% Indice de rupture potentiel (maximum de la valeur absolue des sommes cumulées)
[~, t_rupt_bui] = max(abs(S_cum(1:N-1)));

fprintf('\n[Test de Buishand]\n');
fprintf('  Statistique R / sqrt(N) : %.4f\n', R_buishand);
fprintf('  Point de rupture potentiel : Indice %d\n', t_rupt_bui);
fprintf('  Note : Comparez R / sqrt(N) aux tables de Buishand (Seuil 5%% pour N=30: ~1.22, N=40: ~1.25).\n');

%% ========================================================================
%% VISUALISATION GRAPHIQUE
%% ========================================================================
figure('Name', 'Analyse de Ruptures');

% Sous-graphique 1 : Données et rupture Pettitt
subplot(2,1,1);
plot(X, '-o', 'LineWidth', 1.5); hold on;
if p_Pettitt < 0.05
    xline(t_rupt_pet, '--r', sprintf('Pettitt Break (t=%d)', t_rupt_pet), 'LineWidth', 2);
    plot(1:t_rupt_pet, mean(X(1:t_rupt_pet)), 'g--', 'LineWidth', 2);
    plot((t_rupt_pet+1):N, mean(X((t_rupt_pet+1):N)), 'm--', 'LineWidth', 2);
end
title('Pettitt Break Test');
xlabel('Indices'); ylabel('Values');
grid off;

% Sous-graphique 2 : Sommes cumulées de Buishand
subplot(2,1,2);
plot(S_cum, '-s', 'Color', [0.85 0.33 0.1], 'LineWidth', 1.5); hold on;
xline(t_rupt_bui, '--b', sprintf('Pivot Buishand (t=%d)', t_rupt_bui), 'LineWidth', 1.5);
title('Cumulated sum (Buishand Test)');
xlabel('Indices'); ylabel('S_k');
grid off;
