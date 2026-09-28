% =========================================================================
% ESTIMATION DE LA PROBABILITÉ DE DÉFAILLANCE - MONTE CARLO
% =========================================================================


%% 1. PARAMÈTRES ET ENTRÉES
W = 412020;       % Poids du pont 
mu = 1.0;         % Coefficient de frottement supposée à 1
N = 100000;       % Nombre de simulations de Monte Carlo

% Paramètres de la loi GEV pour FD et FL

k_D = -0.2424; sigma_D = 372373.6993; mu_D = 2786459.5688;     % Traînée FD
k_L = -1.4310; sigma_L = 5458484.1443; mu_L = -3823149.0403;      % Amplitude de la portance |FL|

%% 2. SIMULATION DE MONTE CARLO
rng('default'); % pour la reproductibilité

% Génération des forces de traînée 
FD = gevrnd(k_D, sigma_D, mu_D, [N, 1]);

% Génération des forces de portance 

FL = -gevrnd(k_L, sigma_L, mu_L, [N, 1]);

%% 3. ANALYSE DE LA SÉCURITÉ (FONCTION D'ÉTAT LIMITE Z ou G)
% Formule : Z = mu * (W + |FL|) - FD
% Défaillance si Z <= 0 (les forces l'emportent sur la résistance)
Z = mu * (W + abs(FL)) - FD;

% Calcul de la probabilité de défaillance
nb_defaillances = sum(Z <= 0);
p_defaillance = nb_defaillances / N;

% Affichage du résultat dans la console
fprintf('--- RÉSULTATS DE LA SIMULATION ---\n');
fprintf('Nombre de cas de rupture : %d sur %d\n', nb_defaillances, N);
fprintf('Probabilité que le pont coule/glisse : %.4f %%\n\n', p_defaillance * 100);

%% 4. GRAPHICS / PLOTS

% Figure 1 : Distribution des forces et Frontière de défaillance
figure('Color', 'w');
scatter(FD(Z>0), FL(Z>0), 8, [0.4 0.7 1], 'filled', 'MarkerFaceAlpha', 0.4); hold on;
scatter(FD(Z<=0), FL(Z<=0), 12, 'r', 'filled');

% Tracer la ligne d'état limite théorique (Z = 0)
fd_axe = linspace(min(FD), max(FD), 100);
fl_axe = -(fd_axe / mu - W); % Issu de mu*(W + |fl|) - fd = 0 -> |fl| = fd/mu - W -> fl = -(fd/mu - W)
plot(fd_axe, fl_axe, 'k--', 'LineWidth', 2);

grid off; box on;
xlabel('Destabilizing forces F_D (Horizontal)');
ylabel('Stabilizing forces F_L+P (Verticale, Negative)');

legend('Stable threshold (G > 0)', 'Failure threshold (G \leq 0)', 'Limit state border (G=0)', 'Location', 'best');

% Figure 2 : Histogramme de la fonction d'état limite Z
figure('Color', 'w');
histogram(Z(Z>0), 'FaceColor', [0.2 0.6 0.2], 'EdgeColor', 'none', 'Normalization', 'pdf'); hold on;
histogram(Z(Z<=0), 'FaceColor', 'r', 'EdgeColor', 'none', 'Normalization', 'pdf');
xline(0, 'r--', 'LineWidth', 2, 'Label', 'Break (G = 0)', 'LabelVerticalAlignment', 'top');
grid off;
xlabel('Limit state function G = (W + |F_L|) - F_D');
ylabel('CDF');

legend('Security zone', 'Failure zone', 'Location', 'best');
