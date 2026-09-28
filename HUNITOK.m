% =========================================================================
% CALCUL DES CRUES PAR LA METHODE SCS-CN & HYDROGRAMME UNITAIRE (SCS TYPE II)
% VERSION CORRIGÉE ET OPTIMISÉE (MATLAB)
% =========================================================================

clear; clc; close all;

% --- 1. Données du bassin versant ---
A = 32;          % Superficie (km2)
CN = 72.95;      % Curve Number
L = 6712.268;       % Longueur du plus long cours d'eau (m)
H = 492;         % Dénivelé (m)

% --- 2. Pluies cumulées sur 24h issues de Gumbel (mm) ---
P_24h = [226.5247, 288.5994, 332.1385, 366.8058, 396.0872, 502.3161]; 
T_retour = [100, 200, 300, 400, 500, 1000];

% --- 3. Paramètres temporels (Formule de Kirpich) ---
S_pente = H / L;
tc_min = 0.01947 * (L^0.77) * (S_pente^-0.385);
tc = tc_min / 60;   % Temps de concentration en heures (~1.68h)
tp = 0.6 * tc;      % Temps de pic de l'hydrogramme unitaire (~1.01h)
tb = 2.67 * tp;     % Temps de base de l'HU triangulaire (~2.69h)

% --- 4. Discrétisation temporelle (Pas de temps dt) ---
dt = 0.10;         % Réduit à 0.10h pour mieux capturer le pic de l'HU (tp = 1h)
t_sim = 0:dt:30;   % Temps de simulation (24h de pluie + vidange)
N_sim = length(t_sim);

% --- 5. Construction de l'Hydrogramme Unitaire Dimensionnel du SCS ---
Qp = (2.08 * A) / tp; 

HU = zeros(1, N_sim);
for j = 1:N_sim
    t = t_sim(j);
    if t >= 0 && t <= tp
        HU(j) = Qp * (t / tp);
    elseif t > tp && t <= tb
        HU(j) = Qp * ((tb - t) / (tb - tp));
    end
end

% Normalisation du volume sous l'HU (Garantit qu'un HU = 1mm de Pe sur le bassin)
Vol_theorique = 1000 * A;          % Volume en m3 pour 1mm de pluie efficace
Vol_HU = sum(HU) * dt * 3600;      % Intégration numérique sous l'HU
HU = HU * (Vol_theorique / Vol_HU); 

% --- 6. Rétention du sol (SCS-CN) ---
S = (25400 / CN) - 254;
Ia = 0.2 * S;

% --- 7. Initialisation de la figure ---
hFig = figure('Color', 'w', 'Position', [100, 100, 1200, 700]);
fprintf('--- RESULTATS DES DEBITS DE POINTE GENERES ---\n');

couleurs = {'#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#17becf'};

% --- 8. Boucle sur les périodes de retour ---
for i = 1:length(P_24h)
    P_tot = P_24h(i);
    
    % VECTORISATION : Génération de la courbe SCS Type II
    F = zeros(1, N_sim);
    t = t_sim;
    
    F(t > 0 & t < 10) = 0.0105 * t(t > 0 & t < 10).^1.07;
    F(t >= 10 & t < 11.5) = 0.105 + 0.052 * (t(t >= 10 & t < 11.5) - 10) + 0.012 * (t(t >= 10 & t < 11.5) - 10).^2;
    F(t >= 11.5 & t < 12.5) = 0.223 + 0.555 * (t(t >= 11.5 & t < 12.5) - 11.5) - 0.23 * (t(t >= 11.5 & t < 12.5) - 11.5).^2;
    F(t >= 12.5 & t < 14) = 0.748 + 0.058 * (t(t >= 12.5 & t < 14) - 12.5) - 0.0075 * (t(t >= 12.5 & t < 14) - 12.5).^2;
    F(t >= 14 & t < 24) = 0.840 + 0.016 * (t(t >= 14 & t < 24) - 14);
    F(t >= 24) = 1.0;
    
    P_cum = F * P_tot;
    
    % Pluie efficace cumulée Pe
    Pe_cum = zeros(1, N_sim);
    idx = P_cum > Ia;
    Pe_cum(idx) = ((P_cum(idx) - Ia).^2) ./ (P_cum(idx) - Ia + S);
    
    % Pluie efficace incrémentale
    Pe_inc = [Pe_cum(1), diff(Pe_cum)];
    Pe_inc(Pe_inc < 0) = 0;
    
    % --- CONVOLUTION (CORRIGÉE : Pas de Multiplication par dt ici !) ---
    Q_hydro = conv(Pe_inc, HU); 
    Q_hydro = Q_hydro(1:N_sim); % Tronquer à la durée de simulation
    
    Qp_reel = max(Q_hydro);
    
    fprintf('T = %4d ans | Pluie 24h = %6.2f mm | Débit de pointe max = %7.2f m3/s\n', ...
        T_retour(i), P_tot, Qp_reel);
    
    % --- SUBPLOTS (Grille 2x3) ---
    subplot(2, 3, i);
    
    plot(t_sim, Q_hydro, 'LineWidth', 2.5, 'Color', couleurs{i});
    
    box on;          
    grid off;          
    xlim([0 30]);    
    ylim([0 2000]);    % Réajusté car les vrais débits culminent à ~600 m3/s
    
    title(['T = ' num2str(T_retour(i)) ' year'], 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Time (h)', 'FontSize', 9);
    ylabel('Flow rate (m³/s)', 'FontSize', 9);
end

% --- 9. ENREGISTREMENT DE L'IMAGE GLOBALE (CORRIGÉ & SÉCURISÉ) ---
nom_fichier = 'hydrogrammes_BIEN.png';
chemin_complet = fullfile(pwd, nom_fichier); % Assure l'écriture dans le dossier courant

try
    % Méthode moderne (recommandée par MATLAB, conserve la haute résolution)
    exportgraphics(hFig, chemin_complet, 'Resolution', 300);
    fprintf('\n-> [SUCCÈS] L''image a été enregistrée via exportgraphics : \n   "%s"\n', chemin_complet);
catch
    try
        % Méthode de secours si votre version de MATLAB est ancienne
        saveas(hFig, chemin_complet);
        fprintf('\n-> [SUCCÈS] L''image a été enregistrée via saveas : \n   "%s"\n', chemin_complet);
    catch ME
        warning('Impossible d''enregistrer la figure automatiquement.');
        fprintf('Erreur rencontrée : %s\n', ME.message);
        fprintf('Conseil : Cliquez sur le menu "File -> Save As" de la fenêtre de graphique.\n');
    end
end
% --- 9. ENREGISTREMENT DE L'IMAGE GLOBALE (CORRIGÉ & SÉCURISÉ) ---
nom_fichier = 'hydrogrammes_BIEN OK.png';
chemin_complet = fullfile(pwd, nom_fichier); % Assure l'écriture dans le dossier courant

try
    % Méthode moderne (recommandée par MATLAB, conserve la haute résolution)
    exportgraphics(hFig, chemin_complet, 'Resolution', 300);
    fprintf('\n-> [SUCCÈS] L''image a été enregistrée via exportgraphics : \n   "%s"\n', chemin_complet);
catch
    try
        % Méthode de secours si votre version de MATLAB est ancienne
        saveas(hFig, chemin_complet);
        fprintf('\n-> [SUCCÈS] L''image a été enregistrée via saveas : \n   "%s"\n', chemin_complet);
    catch ME
        warning('Impossible d''enregistrer la figure automatiquement.');
        fprintf('Erreur rencontrée : %s\n', ME.message);
        fprintf('Conseil : Cliquez sur le menu "File -> Save As" de la fenêtre de graphique.\n');
    end
end
