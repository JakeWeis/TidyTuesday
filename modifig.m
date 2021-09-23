function modifig(H,fontsize,varargin)
% MODIFIG modifies font sizes and the font of a figure:
% MODIFIG(H,FS) changes the font size (FS) of all text elements in the specified
% figure (H). Supported text elements include axis labels, axis tick labels, titles
% and legends.
%
% Optional arguments:
% MODIFIG(...,'TickLabelMultiplier',M) changes the fontsize of axis tick labels 
% MODIFIG(...,'AxLabelMultiplier',M)   changes the fontsize of axis labels
% MODIFIG(...,'TitleMultiplier',M)     changes the fontsize of the title
% MODIFIG(...,'LegendMultiplier',M)    changes the fontsize of legend entries
% relative to FS by the factor M.
%
% MODIFIG(...,'FontName',fontname)     changes the font of all text elements. 
% MODIFIG(...,'FigSize',[X Y W H])     changes the size of the figure (position vector).
%
% J. Weis, April 2020

%% Check input
assert(nargin >= 2, 'Not enough input arguments. Specify the figure handle and global figure font size.')

%% Input parsing
% Tick label multiplier
iA = find(strncmpi(varargin,'TickLabelMultiplier',3),1);
if ~isempty(iA)
    TickLabelMultiplier = varargin{iA+1};
    varargin(iA:iA+1) = [];
else
    TickLabelMultiplier = 1;
end
% Axis label multiplier
iA = find(strncmpi(varargin,'AxLabelMultiplier',3),1);
if ~isempty(iA)
    AxLabelMultiplier = varargin{iA+1};
    varargin(iA:iA+1) = [];
else
    AxLabelMultiplier = 1;
end
% Title multiplier
iA = find(strncmpi(varargin,'TitleMultiplier',3),1);
if ~isempty(iA)
    TitleMultiplier = varargin{iA+1};
    varargin(iA:iA+1) = [];
else
    TitleMultiplier = 1;
end
% Legend multiplier
iA = find(strncmpi(varargin,'LegendMultiplier',3),1);
if ~isempty(iA)
    LegendMultiplier = varargin{iA+1};
    varargin(iA:iA+1) = [];
else
    LegendMultiplier = 1;
end
% Font
iA = find(strncmpi(varargin,'FontName',3),1);
if ~isempty(iA)
    FontName = varargin{iA+1};
    varargin(iA:iA+1) = [];
else
    FontName = 'DejaVuSans';
end
% Figure Size
iA = find(strncmpi(varargin,'FigSize',3),1);
if ~isempty(iA)
    FigSize = varargin{iA+1};
    varargin(iA:iA+1) = [];
else
    FigSize = NaN;
end

%% Adjust figure
allax = findobj(H,'Type','axes','-or','Type','ColorBar','-or','Type','Legend','-or','Type','tiledlayout');

for i = 1 : length(allax)
    if ~contains(class(allax(i)),'TiledChartLayout')
        if contains(class(allax(i)),'Axes')
            set(allax(i),'FontSize',fontsize*TickLabelMultiplier)       % Axis tick label font size
            set(allax(i),'LabelFontSizeMultiplier',AxLabelMultiplier)   % Axis label font size
            set(allax(i),'TitleFontSizeMultiplier',TitleMultiplier)     % Title font size
        elseif contains(class(allax(i)),'ColorBar')
            set(allax(i),'FontSize',fontsize * TickLabelMultiplier)     % Colorbar tick label font size (same as axis)
            set(allax(i).Label,'FontSize',fontsize * AxLabelMultiplier) % Colorbar label font size (same as axis)
        elseif contains(class(allax(i)),'Legend')
            set(allax(i),'FontSize',fontsize * LegendMultiplier)        % Legend font size
        end
        set(allax(i),'FontName',FontName)                               % Font name
    else
        set(allax(i).YLabel,'FontSize',fontsize * AxLabelMultiplier);
        set(allax(i).XLabel,'FontSize',fontsize * AxLabelMultiplier);
        set(allax(i).Title,'FontSize',fontsize * TitleMultiplier);
        set(allax(i).YLabel,'FontName',FontName);
        set(allax(i).XLabel,'FontName',FontName);
        set(allax(i).Title,'FontName',FontName);
    end
end

orient landscape
set(H, 'PaperPositionMode', 'auto')

if ~isnan(FigSize)
    set(gcf, 'Position', FigSize/5)
end
