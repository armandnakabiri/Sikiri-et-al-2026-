% 1. Données 
categories = {'Vegetation', 'Bare soil', 'Buildings', 'Water bodies'};
pourcentages = [61.89, 34.28, 2.73, 1.08];

% 2. Définition des couleurs exactes de la carte précédente (Normalisées RGB)
couleurs = [
    0.27, 0.55, 0.31;  % Vegetation (Vert de la carte)
    0.81, 0.74, 0.53;  % Bare soil (Beige de la carte)
    1.00, 0.13, 0.08;  % Buildings (Rouge de la carte)
    0.12, 0.53, 0.90   % Water bodies (Bleu de la carte)
];

% 3. figure
figure('Color', [1 1 1]); 

% 4. Dessin du diagramme en barres
hBar = bar(pourcentages, 'EdgeColor', 'k', 'LineWidth', 1);
set(gca, 'XTickLabel', categories, 'XColor', 'k', 'YColor', 'k');

% palette personnalisée à chaque barre
hBar.FaceColor = 'flat';
hBar.CData = couleurs;

% 5. Personnalisation des axes et labels 
ylabel('Landuse (%)', 'FontSize', 11, 'Color', 'k');
xlabel('Main types of occupation in Kavimvira Watershed', 'FontSize', 11, 'Color', 'k');
ylim([0 100]); 
set(gca, 'YTick', 0:10:100); 
grid off; 

% 6. étiquettes de texte 
xtips = 1:numel(pourcentages);
ytips = pourcentages + 2;
labels = cellstr(num2str(pourcentages', '%.2f%%'));
text(xtips, ytips, labels, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'FontSize', 9, 'FontWeight', 'bold');
