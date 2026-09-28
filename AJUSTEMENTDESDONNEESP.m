% =========================================================================
% AJUSTEMENT DES DONNEES PLUVIOMETRIQUES D'UVIRA (1985-2022)
% =========================================================================

% 1. CHARGEMENT DES DONNÉES DEPUIS LE FICHIER EXCEL
nom_fichier = 'C:\Users\HP\Documents\MX.xlsx';
donnees_brutes = readmatrix(nom_fichier);

% Extraction sous forme de vecteur colonne 
donnees_chronologiques = donnees_brutes(~isnan(donnees_brutes));
n = length(donnees_chronologiques);

% Tri des données pour les fonctions de répartition
data = sort(donnees_chronologiques);

% 2. AJUSTEMENT DES DISTRIBUTIONS
% --- Loi des Valeurs Extrêmes Généralisée (GEV) ---
param_gev = gevfit(data); % [k, sigma, mu]
F_gev = gevcdf(data, param_gev(1), param_gev(2), param_gev(3));

% --- Distribution Lognormale ---
param_lognorm = lognfit(data); % [mu, sigma]
F_lognormale = logncdf(data, param_lognorm(1), param_lognorm(2));

% --- Distribution Pearson Type III ---
m = mean(data);
v = var(data);
s = skewness(data);
alpha_p = 4 / (s^2);
beta_p = sqrt(v / alpha_p) * sign(s);
gamma_p = m - alpha_p * beta_p;
F_pearson = gamcdf(data - gamma_p, alpha_p, beta_p);

% 3. CALCUL DES FRÉQUENCES EMPIRIQUES (Formule de Weibull)
rank = (1:n)';
F_empirique = rank / (n + 1);

% 4. GRAPHIQUE COMPARATIF DES COURBES F(x)
figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 850, 600]);
hold on; grid off; box on;

% Courbe empirique
plot(data, F_empirique, 'o', 'MarkerFaceColor', [0.6 0.6 0.6], ...
    'MarkerSize', 5, 'DisplayName', sprintf('Maxima of Daily Rainfall data from 1/1/1985 to 7/12/2022 (%d samples)', n));

% Courbes théoriques
plot(data, F_gev, 'r-', 'LineWidth', 2, 'DisplayName', 'GEV');
plot(data, F_lognormale, 'k:', 'LineWidth', 2, 'DisplayName', 'Lognormale');
plot(data, F_pearson, 'g-', 'LineWidth', 1.5, 'DisplayName', 'Pearson III');

% Réglages graphiques
xlabel('Daily precipitation (mm/day)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Cumulative Distribution Function F(x)', 'FontSize', 11, 'FontWeight', 'bold');
legend('Location', 'SouthEast', 'FontSize', 10);
set(gca, 'GridAlpha', 0.15, 'LineWidth', 1.1);

% 5. ÉVALUATION DU GOODNESS OF FIT (CRITÈRES D'AJUSTEMENT)
% --- Distance de Kolmogorov-Smirnov ---
D_gev = max(abs(F_empirique - F_gev));
D_lognorm = max(abs(F_empirique - F_lognormale));
D_pearson = max(abs(F_empirique - F_pearson));

% --- RMSE ---
rmse = @(f_theo) sqrt(mean((F_empirique - f_theo).^2));
RMSE_gev = rmse(F_gev);
RMSE_lognorm = rmse(F_lognormale);
RMSE_pearson = rmse(F_pearson);

% --- AIC ---
calc_aic = @(f_theo, k) n * log(mean((F_empirique - f_theo).^2)) + 2 * k;
AIC_gev = calc_aic(F_gev, 3);        % La loi GEV possède 3 paramètres
AIC_lognorm = calc_aic(F_lognormale, 2); % La loi Lognormale possède 2 paramètres
AIC_pearson = calc_aic(F_pearson, 3);   % La loi Pearson III possède 3 paramètres

% 6. TEST DE TENDANCE DE MANN-KENDALL (Sur l'ordre chronologique d'origine)
s_mk = 0;
for i = 1:(n-1)
    for j = (i+1):n
        s_mk = s_mk + sign(donnees_chronologiques(j) - donnees_chronologiques(i));
    end
end

% Prise en compte des ex-æquo (ties) éventuels pour un calcul robuste de Var(S)
[~, ~, idx] = unique(donnees_chronologiques);
counts = accumarray(idx, 1);
tie_adjustment = sum(counts .* (counts - 1) .* (2 * counts + 5));
var_s = ((n * (n - 1) * (2 * n + 5)) - tie_adjustment) / 18;

% Calcul du Z-score
if s_mk > 0
    z_mk = (s_mk - 1) / sqrt(var_s);
elseif s_mk < 0
    z_mk = (s_mk + 1) / sqrt(var_s);
else
    z_mk = 0;
end
p_val_mk = 2 * (1 - normcdf(abs(z_mk)));

% 7. GÉNÉRATION DU TABLEAU DE RÉSULTATS
Distribution = {'GEV'; 'Lognormale'; 'Pearson III'};

% Formatage des paramètres sous forme de chaînes de caractères
Parametres = {
    sprintf('k=%.4f, sigma=%.4f, mu=%.4f', param_gev(1), param_gev(2), param_gev(3));
    sprintf('mu=%.4f, sigma=%.4f', param_lognorm(1), param_lognorm(2));
    sprintf('alpha=%.4f, beta=%.4f, gamma=%.4f', alpha_p, beta_p, gamma_p)
};

Kolmogorov_D = [D_gev; D_lognorm; D_pearson];
RMSE = [RMSE_gev; RMSE_lognorm; RMSE_pearson];
AIC = [AIC_gev; AIC_lognorm; AIC_pearson];

% Inclusion de la colonne Parametres dans la table
Tableau_Ajustement = table(Distribution, Parametres, Kolmogorov_D, RMSE, AIC);

% Affichage final
fprintf('\n=========================================================================================\n');
fprintf('                        TABLEAU D''ÉVALUATION DE LA QUALITÉ D''AJUSTEMENT (GOF)           \n');
fprintf('=========================================================================================\n');
disp(Tableau_Ajustement);
fprintf('=========================================================================================\n');
fprintf('                               TEST DE TENDANCE DE MANN-KENDALL                          \n');
fprintf('=========================================================================================\n');
fprintf('Statistique Z de MK : %.4f\n', z_mk);
fprintf('p-value du test MK : %.4f \n', p_val_mk);

if p_val_mk < 0.05
    fprintf('=> Tendance SIGNIFICATIVE (L''hypothèse de stationnarité n''est pas vérifiée).\n');
else
    fprintf('=> Aucune tendance significative décelée (Série stationnaire).\n');
end
fprintf('=========================================================================================\n');
