%ESTIMATION DE LA FIABILITE AVEC WEIBULL

% --- Parametres---
alphas = [4545.85608, 1622.12987,891.80796, 643.84811, 531.55829, 420.73470]; 
gammas = [1.0, 2.5, 3.5, 4.5]; 
seuils = [2354.71366, 2630.26631, 2850.13061, 3016.60800,3147.44063, 3587.22263]; 
temps = 0:1:2400;

couleurs = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#A2142F'};
% -----------------------

% Calcul
fprintf('--- F = wblcdf(seuil, alpha, gamma) | R=1-F ---\n');

for i = 1:length(gammas)
    fprintf('\n gamma=%.2f\n', gammas(i));
    for j = 1:length(alphas)
        F = wblcdf(seuils(j), alphas(j), gammas(i));
        fprintf(' alpha=%.1f seuil=%.1f => F=%.4f R=%.4f\n', alphas(j), seuils(j), F, 1-F);
    end
end

% FIGURE 1 : FIABILITE R(t) 
figure('Color','w','Position',[50 50 1300 900]);
t = tiledlayout(2,2,'TileSpacing','compact','Padding','compact');



for i = 1:length(gammas)
    ax = nexttile; hold(ax,'on'); grid(ax,'off'); box(ax,'on');
    gamma = gammas(i);
    for j = 1:length(alphas)
        Rt = 1 - wblcdf(temps, alphas(j), gamma);
        plot(ax, temps, Rt, 'LineWidth', 2.5, 'Color', couleurs{j},...
            'DisplayName', sprintf('\\alpha=%.0f (seuil %.0f)', alphas(j), seuils(j)));
        Rt_s = 1 - wblcdf(seuils(j), alphas(j), gamma);
        plot(ax, seuils(j), Rt_s, 'o','MarkerFaceColor',couleurs{j},'MarkerEdgeColor','k','HandleVisibility','off');
    end
    title(ax, sprintf('\\lambda = %.1f', gamma),'FontWeight','bold','BackgroundColor','#F2F2F2','FontSize',12);

    xlabel(ax,'Load [kN]'); ylabel(ax,'R(t)');
    ylim(ax,[0 1.05]); xlim(ax,[0 2400]);
    legend(ax,'Location','southwest','FontSize',8,'NumColumns',2);
end

% FIGURE 2 : DEFAILLANCE F(t)
figure('Color','w','Position',[50 50 1300 900]);
tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

for i = 1:length(gammas)
    ax = nexttile; hold(ax,'on'); grid(ax,'off'); box(ax,'on');
    gamma = gammas(i);
    for j = 1:length(alphas)
        Ft = wblcdf(temps, alphas(j), gamma);

        plot(ax, temps, Ft, 'LineWidth', 2.5, 'Color', couleurs{j},...
            'DisplayName', sprintf('\\alpha=%.0f', alphas(j)));
    end
    title(ax, sprintf('\\lambda = %.1f', gamma),'FontWeight','bold','BackgroundColor','#F2F2F2','FontSize',12);
    xlabel(ax,'Load [kN]'); ylabel(ax,'F(t)');
    ylim(ax,[0 1.05]); legend(ax,'Location','best','FontSize',8,'NumColumns',2);
end
