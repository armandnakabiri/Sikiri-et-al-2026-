% 1. Chargement des données depuis le fichier Excel

nom_fichier = 'C:\Users\HP\Documents\MX.xlsx'; 

try
    % readmatrix importe automatiquement la première colonne numérique
    donnees_pluie = readmatrix(nom_fichier);
    
    % Nettoyage : supprime les valeurs manquantes (NaN) si le fichier en contient
    donnees_pluie = donnees_pluie(~isnan(donnees_pluie));
    
    % Forcer le format en vecteur colonne
    donnees_pluie = donnees_pluie(:);
    
    fprintf('Succès : %d données de pluie chargées depuis %s.\n\n', length(donnees_pluie), nom_fichier);
catch ME
    error('Erreur lors de la lecture du fichier Excel. Assurez-vous que le fichier "%s" est dans le dossier de travail MATLAB.\nDétail : %s', nom_fichier, ME.message);
end

% 2. Ajustement avec la loi GEV (Generalized Extreme Value)
% par_est(1) = k (forme), par_est(2) = sigma (échelle), par_est(3) = mu (position)
[par_est, par_intervalle] = gevfit(donnees_pluie);

k_est = par_est(1);
sigma_est = par_est(2);
mu_est = par_est(3);

% 3. Vérification du type de loi
fprintf('--- Résultats de l''ajustement ---\n');
fprintf('Paramètre de forme (k) : %.4f\n', k_est);
fprintf('Paramètre d''échelle (sigma) : %.4f\n', sigma_est);
fprintf('Paramètre de position (mu) : %.4f\n\n', mu_est);

if k_est > 0
    fprintf('Confirmation : Le paramètre k > 0. Vos données suivent bien une loi de Fréchet.\n');
else
    fprintf('Attention : Le paramètre k <= 0. L''ajustement correspond plutôt à une loi de Weibull (k<0) ou Gumbel (k=0).\n');
end

% 4. Visualisation de l'ajustement (Histogramme vs Densité de probabilité)
figure;
histogram(donnees_pluie, 'Normalization', 'pdf', 'FaceColor', [0.7 0.8 1], 'EdgeColor', 'w');
hold on;

% courbe théorique
x_axe = linspace(min(donnees_pluie)*0.8, max(donnees_pluie)*1.2, 200);
y_frechet = gevpdf(x_axe, k_est, sigma_est, mu_est);

plot(x_axe, y_frechet, 'r-', 'LineWidth', 2);
grid off;
xlabel('Annual maxima daily rainfall (mm/day)');
ylabel('CDF');

legend('Annual maxima daily rainfall', 'GEV (Fréchet distribution)');
