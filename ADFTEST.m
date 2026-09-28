% 1. Importation des données depuis le fichier Excel
nomFichier = 'C:\Users\HP\Documents\MX.xlsx'; % Vérifiez bien l'extension (.xlsx ou .xls)
donnees = readtable(nomFichier);

% 2. Extraction automatique de la TOUTE PREMIÈRE colonne
% Le format donnees{:, 1} extrait les valeurs numériques directement
y = donnees{:, 1}; 

% 3. Application du test de Dickey-Fuller Augmenté (ADF)
[h, pValue, stat, cValue] = adftest(y);

% 4. Affichage des résultats dans la fenêtre de commande
fprintf('--- Résultats du test ADF ---\n');
if h == 0
    fprintf('Statut : Les données NE SONT PAS stationnaires (H0 non rejetée).\n');
else
    fprintf('Statut : Les données SONT stationnaires (H0 rejetée au seuil de 5%%).\n');
end

fprintf('p-value : %.4f\n', pValue);
fprintf('Statistique de test : %.4f\n', stat);
fprintf('Valeur critique (seuil de 5%%) : %.4f\n', cValue);

% 5. Visualisation graphique
figure;
plot(y, '-o', 'LineWidth', 1.5);

xlabel('Index');
ylabel('Valeurs');
grid on;
