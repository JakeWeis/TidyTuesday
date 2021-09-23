% Tidy Tuesday - DataTas

%% Visualisation options
yearrange = 2007:2020;

%% Import Emmys data and name-gender data
emmys = readtable('nominees.csv');
commonnames = readtable('names_genders.csv');

% Remove Emmy data outside range
emmys(emmys.year < yearrange(1) | emmys.year > yearrange(end),:) = [];

%% Get First names (2007 - 2020)
names = emmys.production;
firstnames = cell(numel(names),1);
NAname = false(numel(names),0);
for iN = 1 : numel(names)
    names_split = split(names{iN});
    firstnames{iN} = names_split{1};
    % index NA names
    if strcmp(names_split{1},'NA')
        NAname(iN) = true;
    else
        NAname(iN) = false;
    end
end

firstnames(NAname) = [];
firstnames_unique = unique(firstnames);
emmys(NAname,:) = [];

nameoccur = zeros(numel(firstnames_unique),1);
for iN = 1 : numel(firstnames_unique)
    nameoccur(iN) = numel(find(strcmp(firstnames_unique{iN},firstnames)));
end
[nameoccur,isort] = sort(nameoccur);
firstnames_unique_sort = firstnames_unique(isort);

%% Get top 100 names and match gender (2007 - 2020)
top100names = flipud(firstnames_unique_sort(end-99:end));
top100occur = flipud(nameoccur(end-99:end));

top100occurNom = NaN(100,1);
top100occurWin = NaN(100,1);
isfemale = false(100,1);
for iN = 1 : 100
    top100occurNom(iN) = numel(find(strcmp(emmys.type(find(strcmp(top100names(iN),firstnames)),:),'Nominee')));
    top100occurWin(iN) = numel(find(strcmp(emmys.type(find(strcmp(top100names(iN),firstnames)),:),'Winner')));
    
    checksex = strcmp(commonnames.sex(find(strcmp(top100names{iN},commonnames.name))),'girl');
    if numel(find(checksex==0))<numel(find(checksex==1))
        isfemale(iN) = true;
    else
        isfemale(iN) = false;
    end
end

%% Process annual data
allFemale_annual = NaN(numel(yearrange),1);
allMale_annual = NaN(numel(yearrange),1);

ct = 0;
for iY = yearrange(1) : yearrange(end)
    ct = ct + 1;
    iYear = emmys.year == iY;
    
    if ~isempty(find(iYear == 1,1))
        names_annual = emmys.production(iYear);
        firstnames_annual = cell(numel(names_annual),1);
        for iN = 1 : numel(names_annual)
            names_split = split(names_annual{iN});
            firstnames_annual{iN} = names_split{1};
        end
        firstnames_unique_annual = unique(firstnames_annual);
        
        nameoccur_annual = zeros(numel(firstnames_unique_annual),1);
        for iN = 1 : numel(firstnames_unique_annual)
            nameoccur_annual(iN) = numel(find(strcmp(firstnames_unique_annual{iN},firstnames_annual)));
        end
        [nameoccur_annual,isort] = sort(nameoccur_annual);
        firstnames_unique_annual_sort = firstnames_unique_annual(isort);
        
        top100names_annual = flipud(firstnames_unique_annual_sort(end-99:end));
        top100occur_annual = flipud(nameoccur_annual(end-99:end));
        
        
        isfemale_annual = false(100,1);
        for iN = 1 : 100
            checksex = strcmp(commonnames.sex(find(strcmp(top100names_annual{iN},commonnames.name))),'girl');
            if numel(find(checksex==0))<numel(find(checksex==1))
                isfemale_annual(iN) = true;
            else
                isfemale_annual(iN) = false;
            end
        end
    
        allFemale_annual(ct) = sum(top100occur_annual(isfemale_annual));
        allMale_annual(ct) = sum(top100occur_annual(~isfemale_annual));
    end
end

%% Plot
figure(1);clf
set(gcf,'Color',[.2 .2 .2])

linescol = lines(3);

% Bar plot: Nominations/wins by name
tiledlayout(1,1)
ax = nexttile(1);
col1 = repmat(lines(1),100,1);
col1(isfemale,:) = repmat([0.8500    0.3250    0.0980],numel(find(isfemale==1)),1);
col2 = col1*0.7;

col1_inv = repmat(lines(1),100,1);
col1_inv(~isfemale,:) = repmat([0.8500    0.3250    0.0980],numel(find(~isfemale==1)),1);
col2_inv = col1_inv*0.7;

b_inv = bar([top100occurNom,top100occurWin],1,'stacked','facecolor','flat','LineStyle','none');
b_inv(1).CData = col1_inv;
b_inv(2).CData = col2_inv;
hold on
b = bar([top100occurNom,top100occurWin],1,'stacked','facecolor','flat','LineStyle','none');
b(1).CData = col1;
b(2).CData = col2;
hold off

text(1:100,10*ones(100,1),top100names,'rotation',90,'Color',[.95 .95 .95],'FontWeight','bold','FontName','Palatino')
xticks([])
xlim([0.5 100.5])
yticks(100:100:500)
ylabel('total number of nominations and wins','FontWeight','bold')
ax.YGrid = 'on';
ax.YAxis.TickLength = [0 0];
ax.Color = [.1 .1 .1];
ax.XColor = 'w';
ax.YColor = 'w';
leg = legend('Nominees','Winners','Nominees','Winners','Color','none','EdgeColor','none','NumColumns',2,'TextColor','w');
leg.Position = [0.03 0.81 0.3 0.07];

text(9.9,575,'Female','FontSize',22*0.7,'FontName','Palatino','FontWeight','bold','Color','w');
text(16.8,575,'Male','FontSize',22*0.7,'FontName','Palatino','FontWeight','bold','Color','w');
annotation('textarrow',[0.11,0.07],[0.585,0.585],'string',[{' 100 most common names among all'};...
    {' Emmy Award nominees and winners'};{' between 2007 and 2020'}],'FontName','Palatino','HorizontalAlignment','left','Fontsize',14,'TextMargin',5,'FontAngle','italic','Color','w')

% Secondary axis: Female percentage
inset = axes('Position',ax.Position,'Color','none');
plot(yearrange,allFemale_annual./(allMale_annual+allFemale_annual)*100,'w-','LineWidth',2)
inset.YAxisLocation = 'right';
inset.Color = 'none';
inset.YAxis.TickLength = [0 0];
inset.XAxis.TickLength = [0 0];
xlim([2007,2020])
ylim([3 15])
yticks(5:2:13)
inset.YColor = 'w';
inset.XColor = 'w';
inset.XTick = yearrange;
ylabel('female representation (%)','FontWeight','bold')
% inset.YColor = 'none';
box off
text(2013.5,10.2,'[2014 data missing]','FontSize',14,'FontAngle','italic','FontName','Palatino','Color','w')
annotation('textarrow',[0.83,0.87],[0.72,0.72],'string',[{'Annual proportion of female Emmy Award  '};...
    {'nominees and winners from 2007 to 2020  '}],'FontName','Palatino','HorizontalAlignment','right','Fontsize',14,'TextMargin',5,'FontAngle','italic','Color','w')

t = title('Gender bias at the Emmy Awards (2007 - 2020)','Color','w');
t.Position(2) = t.Position(2)-1.4;

modifig(gcf,22,'FigSize',[10,10,9000,4000],'FontName','Palatino','Legend',0.7,'Title',1.5)
t.FontName = 'Palatino';
t.FontWeight = 'normal';
set(gcf,'InvertHardCopy','Off');

saveas(gcf,'EmmyGenderBias.png')