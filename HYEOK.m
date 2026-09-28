% =========================================================================
% HYETOGRAMMES DE PLUIE SCS TYPE II EN SUBPLOTS (CORRIGÉ & OPTIMISÉ)
% =========================================================================


% --- 1. Données des pluies cumulées sur 24h (Gumbel) ---
P_24h = [226.5247, 288.5994, 332.1385, 366.8058, 396.0872, 502.3161];
T_retour = [100, 200, 300, 400, 500, 1000];

% --- 2. Discrétisation temporelle ---
dt = 0.25; % 15 minutes
t_pluie = 0:dt:24;

% --- 3. Initialisation de la figure ---
hFig = figure('Color', 'w', 'Position', [100, 100, 1200, 700]);
couleurs = {'b', 'r', 'g', 'm', 'c', [0.92, 0.69, 0.12]};

% --- 4. Génération de la courbe adimensionnelle SCS Type II (Vectorisée) ---
% Approximation standardisée et continue de la courbe SCS Type II
F = zeros(size(t_pluie));
F(t_pluie <= 0) = 0;
F(t_pluie > 0 & t_pluie <= 9.5)   = 0.0116 * t_pluie(t_pluie > 0 & t_pluie <= 9.5).^1.07;
F(t_pluie > 9.5 & t_pluie <= 11.8) = 0.12 + 0.11 * (t_pluie(t_pluie > 9.5 & t_pluie <= 11.8) - 9.5).^1.8;
F(t_pluie > 11.8 & t_pluie <= 12.2)= 0.44 + 1.45 * (t_pluie(t_pluie > 11.8 & t_pluie <= 12.2) - 11.8).^0.75;
F(t_pluie > 12.2 & t_pluie <= 14.5)= 0.81 + 0.07 * (t_pluie(t_pluie > 12.2 & t_pluie <= 14.5) - 12.2).^0.6;
F(t_pluie > 14.5 & t_pluie < 24)   = 0.91 + 0.0095 * (t_pluie(t_pluie > 14.5 & t_pluie < 24) - 14.5);
F(t_pluie >= 24) = 1.0;

% --- 5. Boucle sur les périodes de retour ---
for i = 1:length(P_24h)
    % Pluie cumulative pour la période de retour i
    P_cum = F * P_24h(i);
    
    % Calcul de la pluie incrémentale (différence finie)
    dP = [0, diff(P_cum)]; 
    dP(dP < 0) = 0;
    
    % Conversion en Intensité (mm/h)
    Intensite = dP / dt;
    
    % --- Affichage Graphique ---
    subplot(2, 3, i);
    area(t_pluie, Intensite, 'FaceColor', couleurs{i}, 'FaceAlpha', 0.3, 'EdgeColor', couleurs{i}, 'LineWidth', 1.5);
    
    % Configuration des axes
    box on; 
    grid off; % Activé pour une meilleure lecture des pics
    xlim([0 24]); 
    ylim([0 500]); % Augmenté légèrement pour ne pas étouffer le graphe T=1000
    
    % Titres et labels
    title(['T = ' num2str(T_retour(i)) ' year'], 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Time (h)', 'FontSize', 10);
    ylabel('Intensity (mm/h)', 'FontSize', 10);
end

% --- 6. Enregistrement Haute Résolution ---
% exportgraphics est plus performant que saveas pour conserver la mise en page
exportgraphics(hFig, 'hyetogrammesBIEN OK.png', 'Resolution', 300);
fprintf('\n-> L''image haute résolution a été enregistrée : "hyetogrammesBIEN OK.png"\n');
