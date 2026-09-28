% 1. Données à représenter
categories = {'Vegetation', 'Bare soil', 'Buildings', 'Water bodies'};
pourcentages = [61.89, 34.28, 2.73, 1.08];

% 2. Définition des couleurs exactes de la carte précédente (Normalisées RGB)
couleurs = [
    0.27, 0.55, 0.31;  % Vegetation (Vert de la carte)
    0.81, 0.74, 0.53;  % Bare soil (Beige de la carte)
    1.00, 0.13, 0.08;  % Buildings (Rouge de la carte)
    0.12, 0.53, 0.90   % Water bodies (Bleu de la carte)
];

% 3. Création de la figure
figure('Color', [1 1 1]); % Fond de la fenêtre en blanc

% 4. Dessin du diagramme en barres
hBar = bar(pourcentages, 'EdgeColor', 'k', 'LineWidth', 1);
set(gca, 'XTickLabel', categories, 'XColor', 'k', 'YColor', 'k');

% Application de la palette personnalisée à chaque barre
hBar.FaceColor = 'flat';
hBar.CData = couleurs;

% 5. Personnalisation des axes et labels (style épuré comme votre image)
ylabel('Landuse (%)', 'FontSize', 11, 'Color', 'k');
xlabel('Main types of occupation in Kavimvira Watershed', 'FontSize', 11, 'Color', 'k');
ylim([0 100]); % Limite l'axe Y de 0 à 100%
set(gca, 'YTick', 0:10:100); % Graduations de 10 en 10
grid off; % Pas de quadrillage arrière

% 6. Ajout automatique des étiquettes de texte (%) au-dessus des barres
xtips = 1:numel(pourcentages);
ytips = pourcentages + 2; % Positionne le texte légèrement au-dessus de la barre
labels = cellstr(num2str(pourcentages', '%.2f%%'));
text(xtips, ytips, labels, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'FontSize', 9, 'FontWeight', 'bold');
