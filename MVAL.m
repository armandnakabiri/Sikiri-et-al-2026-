
%% VALIDATION PREDICTION vs OBSERVATION
% Ton Excel: Col1 = Réel, Col2 = Prédit

clear; clc; close all;

% 1. LIRE EXCEL
[file, path] = uigetfile('MV.xlsx','C:\Users\HP\Documents\MV.xlsx');
data = readmatrix(fullfile(path,file));
Obs = data(:,1); % Réel
Sim = data(:,2); % Prédit

% Nettoyage NaN
mask = ~isnan(Obs) & ~isnan(Sim);
Obs = Obs(mask); Sim = Sim(mask);

% 2. PARAMETRES STATISTIQUES
n = length(Obs);
mean_obs = mean(Obs);

RMSE = sqrt(mean((Obs - Sim).^2));
MAE = mean(abs(Obs - Sim));
BIAS = mean(Sim - Obs);
R = corrcoef(Obs, Sim); R = R(1,2);
R2 = R^2;
% Nash-Sutcliffe
NSE = 1 - sum((Obs - Sim).^2)/sum((Obs - mean_obs).^2);
% Kling-Gupta
r = R; alpha = std(Sim)/std(Obs); beta = mean(Sim)/mean_obs;
KGE = 1 - sqrt((r-1)^2 + (alpha-1)^2 + (beta-1)^2);

fprintf('\n--- VALIDATION ---\n');
fprintf('RMSE = %.4f\nMAE = %.4f\nBIAS = %.4f\nR = %.4f\nR2 = %.4f\nNSE = %.4f\nKGE = %.4f\n',...
    RMSE,MAE,BIAS,R,R2,NSE,KGE);

% 3. FIGURE COMPLETE D'EVALUATION (4 graphiques)
figure('Color','w','Position',[100 100 1100 800]);

% A) Scatter plot Réel vs Prédit + droite 1:1
subplot(2,2,1);
scatter(Obs, Sim, 30, 'filled','MarkerFaceAlpha',0.6); hold on;
lims = [min([Obs;Sim]) max([Obs;Sim])];
plot(lims, lims, 'r--','LineWidth',2);
% Régression
p = polyfit(Obs, Sim, 1);
plot(lims, polyval(p,lims), 'k-','LineWidth',1.5);
xlabel('Valeurs Réelles'); ylabel('Valeurs Prédites');
title(sprintf('Scatter - R²=%.3f',R2));
legend('Données','y=x (parfait)','Régression','Location','best');
grid off; box on; axis equal; xlim(lims); ylim(lims);

% B) Série temporelle
subplot(2,2,2);
plot(Obs,'b-','LineWidth',1.2); hold on;
plot(Sim,'r--','LineWidth',1.2);
xlabel('Pas de temps'); ylabel('Valeurs');
title('Comparaison temporelle');
legend('Réel','Prédit'); grid off;

% C) Résidus
subplot(2,2,3);
residus = Sim - Obs;
plot(residus,'k.','MarkerSize',10); hold on;
yline(0,'r--','LineWidth',2);
yline(mean(residus),'g-','LineWidth',1.5);
xlabel('Pas de temps'); ylabel('Résidu (Prédit - Réel)');
title(sprintf('Résidus - BIAS=%.3f',BIAS));
grid off;

% D) Histogramme des erreurs + stats box
subplot(2,2,4);

histogram(residus,20,'FaceColor',[0.3 0.6 0.9],'EdgeColor','w');
xlabel('Erreur'); ylabel('Fréquence');
title('Distribution des erreurs');
grid off;
% Texte stats
annotation('textbox',[0.55 0.15 0.35 0.25],'String',...
    {sprintf('RMSE = %.3f',RMSE),sprintf('MAE = %.3f',MAE),...
     sprintf('NSE = %.3f',NSE),sprintf('KGE = %.3f',KGE),...
     sprintf('R² = %.3f',R2),sprintf('BIAS = %.3f',BIAS)},...
    'FitBoxToText','in','BackgroundColor','w','FontWeight','bold');

sgtitle('Évaluation Prédiction vs Réel','FontSize',14,'FontWeight','bold');

% Interprétation auto
if NSE > 0.75 && R2 > 0.8
    disp('--> Modèle TRÈS BON (NSE>0.75)');
elseif NSE > 0.65
    disp('--> Modèle BON (NSE>0.65)');
else
    disp('--> Modèle à améliorer (NSE<0.65)');
end