classdef spikeBrowser < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        LeftPanel                     matlab.ui.container.Panel
        TabGroup2                     matlab.ui.container.TabGroup
        TraceTab                      matlab.ui.container.Tab
        ChannelIDEditFieldLabel       matlab.ui.control.Label
        ChannelIDEditField            matlab.ui.control.NumericEditField
        BinmsEditFieldLabel           matlab.ui.control.Label
        BinmsEditField                matlab.ui.control.NumericEditField
        LoadfileButton                matlab.ui.control.Button
        Lamp                          matlab.ui.control.Lamp
        PlotButton                    matlab.ui.control.Button
        SpikeSliderLabel              matlab.ui.control.Label
        SpikeSlider                   matlab.ui.control.Slider
        PreviousButton                matlab.ui.control.Button
        NextButton                    matlab.ui.control.Button
        UIAxes                        matlab.ui.control.UIAxes
        WaveletDropDownLabel          matlab.ui.control.Label
        WaveletDropDown               matlab.ui.control.DropDown
        MovingaverageTab              matlab.ui.container.Tab
        UIAxes4                       matlab.ui.control.UIAxes
        AvePlotButton                 matlab.ui.control.Button
        UIAxes5                       matlab.ui.control.UIAxes
        ChannelIDEditField_2Label     matlab.ui.control.Label
        ChannelIDEditField_2          matlab.ui.control.NumericEditField
        RightPanel                    matlab.ui.container.Panel
        TabGroup                      matlab.ui.container.TabGroup
        SpikeTab                      matlab.ui.container.Tab
        UIAxes2                       matlab.ui.control.UIAxes
        TPButton                      matlab.ui.control.Button
        FNButton                      matlab.ui.control.Button
        FPButton                      matlab.ui.control.Button
        SpikenoEditFieldLabel         matlab.ui.control.Label
        SpikenoEditField              matlab.ui.control.EditField
        TemplateButton                matlab.ui.control.Button
        OverlayButton                 matlab.ui.control.Button
        HistogramTab                  matlab.ui.container.Tab
        UIAxes3                       matlab.ui.control.UIAxes
        ThresholdmethodDropDownLabel  matlab.ui.control.Label
        ThresholdmethodDropDown       matlab.ui.control.DropDown
        ThresholdvalueEditFieldLabel  matlab.ui.control.Label
        ThresholdvalueEditField       matlab.ui.control.NumericEditField
        equalField                    matlab.ui.control.EditField
        Label                         matlab.ui.control.Label
        lbbLabel                      matlab.ui.control.Label
        StatsTab                      matlab.ui.container.Tab
        FiringrateEditFieldLabel      matlab.ui.control.Label
        FiringrateEditField           matlab.ui.control.EditField
        SensitivityEditFieldLabel     matlab.ui.control.Label
        SensitivityEditField          matlab.ui.control.EditField
        samplesEditFieldLabel         matlab.ui.control.Label
        samplesEditField              matlab.ui.control.EditField
        PrecisionEditFieldLabel       matlab.ui.control.Label
        PrecisionEditField            matlab.ui.control.EditField
        CostparameterEditFieldLabel   matlab.ui.control.Label
        CostparameterEditField        matlab.ui.control.EditField
        spikesEditFieldLabel          matlab.ui.control.Label
        spikesEditField               matlab.ui.control.EditField
        SaveButton                    matlab.ui.control.Button
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = public)
        electrodes;
        trace;
        traces;
        spikeMatrix;
        spikeVector;
        spike = 1;
        waveforms;
        channel;
        TP = 0;
        FN = 0;
        FP = 0;
        sensitivity;
        precision;
        samples = 0;
        L;
        spikeCount;
        binLength;
        fname;
        thrMode;
        amp;
        spikeTimes;
        yOffset;
        y;
        thr;
        spikeMethod = 'Overlay';
        templates;
        template;
        wavelet = 'bior1p5';
        spikeCell;
        channels;
        wavelets;
        spike_struct;
    end
    
    methods (Access = private)
        
        function plotTrace(app, trace, spikeTimes)
            
            app.UIAxes.cla;
            
            plot(app.UIAxes, trace, 'k');
            hold(app.UIAxes, 'on');
            
            scatter(app.UIAxes, (spikeTimes), app.y, 'v','filled');
            
            xlim(app.UIAxes, [1 length(trace)]);
            ylim(app.UIAxes, 'auto');
        end
        
        function plotBin(app)
            
            app.UIAxes.cla;
            
            plot(app.UIAxes, app.trace, 'k');
            hold(app.UIAxes, 'on');
            scatter(app.UIAxes, (app.spikeTimes), app.y, 'v','filled');
            
            xlim(app.UIAxes, [(app.spikeTimes(app.spike)- app.binLength), (app.spikeTimes(app.spike)+ app.binLength)]);
            ylim(app.UIAxes, [-app.thr*7 app.thr*7]);
        end
        
        function plotOverlay(app)
            
            fs = 25000;
            durationInSec = 0.001;
            durationInFrame = fs * durationInSec;
            alpha = 0.2;
            peakAlignedSpikeMatrix  = [];
            
            app.UIAxes2.cla;
            
            [spikeWaves, ~] = spikeAlignment(...
                app.trace, app.spikeVector, 25000, 0.002);
            
            for spikeTimeSeries = 1:100
                [pks,locs] = findpeaks(-spikeWaves(spikeTimeSeries, :));
                spikePeakLoc = locs(abs(pks) == max(abs(pks)));
                spStart = spikePeakLoc - round(durationInFrame / 2);
                spEnd = spikePeakLoc + round(durationInFrame / 2);
                if spStart > 0 && spEnd < size(spikeWaves, 2)
                    
                    plot(app.UIAxes2, spikeWaves(spikeTimeSeries, spStart:spEnd), 'Color', [0 0 0] + 1 - alpha);
                    peakAlignedSpikeMatrix = [peakAlignedSpikeMatrix; ...
                        spikeWaves(spikeTimeSeries, spStart:spEnd)];
                end
                hold(app.UIAxes2, 'on');
            end
            
            aveSpikeWaveForm = median(peakAlignedSpikeMatrix);
            
            [pks,locs] = findpeaks(-aveSpikeWaveForm);
            spikePeakLoc = locs(abs(pks) == max(abs(pks)));
            spStart = spikePeakLoc - round(durationInFrame / 2);
            spEnd = spikePeakLoc + round(durationInFrame / 2);
            if spStart > 0 && spEnd < size(spikeWaves, 2)
                plot(app.UIAxes2, aveSpikeWaveForm(spStart:spEnd), 'Color', [1 1 1], 'LineWidth',1.7);
                hold(app.UIAxes2, 'on');
                plot(app.UIAxes2, aveSpikeWaveForm(spStart:spEnd), 'Color', [0 0 0], 'LineWidth',1);
            end
            xlim(app.UIAxes2, [1 length(aveSpikeWaveForm(spStart:spEnd))]);
            ylim(app.UIAxes2, 'auto');
            
        end
        
        function updateStats(app)
            app.sensitivity = app.TP/(app.TP+app.FN);
            app.precision = app.TP/(app.TP+app.FP);
            app.samples = app.samples+1;
            
            app.SensitivityEditField.Value = [num2str(round(app.sensitivity*100)) ' %'];
            app.PrecisionEditField.Value =  [num2str(round(app.precision*100)) ' %'];
            app.samplesEditField.Value = num2str(app.samples);
        end
        
        function plotHistogram(app)
            
            app.UIAxes3.cla;
            histogram(app.UIAxes3, app.amp, 'FaceColor', [0.4940, 0.1840, 0.5560]);
            hold(app.UIAxes3);
            if strcmp(app.thrMode, 'MAD')
                app.thr = mad(app.trace, 1)/0.6745;
            else
                app.thr = std(app.trace);
            end
            xline(app.UIAxes3, -app.ThresholdvalueEditField.Value*app.thr,...
                'r--','Linewidth',1.5);
            app.equalField.Value = [num2str(-app.ThresholdvalueEditField.Value*app.thr)];
            
        end
        
        function plotSpike(app)
            app.UIAxes2.cla;
            spikeWaveform = app.waveforms(app.spike,:);
            
            plot(app.UIAxes2, spikeWaveform, 'k','LineWidth',1.5);
            ylim(app.UIAxes2, [min(spikeWaveform)-3 max(spikeWaveform)+3]);
            xlim(app.UIAxes2, [1 51]);
            
        end
        
        function plotTemplate(app)
            app.UIAxes2.cla;
            plot(app.UIAxes2, app.template, 'k','LineWidth',1.5);
            ylim(app.UIAxes2, 'auto');
            xlim(app.UIAxes2, [1 100]);
        end
        
        function getIntersectMatrix(app)
            
            spike_struct = app.spikeCell{app.channel};
            wavelets = fieldnames(spike_struct);
            all_spikes = [];
            for wav = 1:numel(wavelets)
                all_spikes = union(all_spikes, spike_struct.(wavelets{wav}));
            end
            clear F;
            intersectMatrix = zeros(length(all_spikes),length(wavelets));
            
            for wav = 1:length(wavelets)
                app.spikeTimes = spike_struct.(wavelets{wav});
                for spikeIndex = 1:length(all_spikes)
                    if ismember(all_spikes(spikeIndex), app.spikeTimes)
                        intersectMatrix(spikeIndex, wav) = 1;
                    end
                end
            end
            
            for spike = 1:length(intersectMatrix)
                clear ff
                ff = find(intersectMatrix(spike, :) == 1);
                if length(ff) == 1 && ff ~=0
                    F(spike) = ff;
                end
            end
            
        end
        function updateVars(app)
            app.spikeTimes = app.spike_struct.(app.wavelet);
            spVector = zeros(size(app.trace));
            spVector(app.spikeTimes) = 1;
            app.spikeVector = spVector;
            app.spikeCount = numel(app.spikeTimes);
            
            for sp = 1:app.spikeCount
                if app.spikeTimes(sp)+25 < length(app.trace) && app.spikeTimes(sp)-25 > 0
                    app.waveforms(sp, :) = app.trace(app.spikeTimes(sp)-25:app.spikeTimes(sp)+25);
                end
            end
            
            app.thr = mad(app.trace, 1)/0.6745;
            app.yOffset = 4*app.thr;
            app.y = repmat(app.yOffset - 0, length(app.spikeTimes), 1);
            app.SpikeSlider.Limits = [1 app.spikeCount];
            app.spike = 0;
            app.template = app.templates(app.channel, :);
            s = app.spikeCount;
            app.SpikeSlider.MajorTickLabels = {'1', num2str(round(s/4)),...
                num2str(round(s/2)), num2str(round(0.75*s)), num2str(s)};
            app.SpikeSlider.MajorTicks = [1 s/4 s/2 0.75*s s];
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadfileButton
        function LoadfileButtonPushed(app, event)
            
            app.Lamp.Color = [1 0 0];
            file = uigetfile('*spike_struct.mat');
            load(file, 'spikeCell', 'templates','channels','traces','L');
            app.Lamp.Color = [0 1 0];
            
            app.fname = file;
            
            
            % Load variables
            app.spikeCell = spikeCell;
            app.templates = templates;
            app.channels = channels;
            app.traces = traces;
            app.L = L;
            app.wavelets = fieldnames(spikeCell{1});
            
            % UI labels
            app.WaveletDropDown.Items = strrep(app.wavelets, 'p','.');
            app.lbbLabel.Text = [char(956), 'V'];
            
        end

        % Value changed function: ChannelIDEditField
        function ChannelIDEditFieldValueChanged(app, event)
            value = app.ChannelIDEditField.Value;
            
            app.channel = (app.channels == value);
            app.trace = app.traces(app.channel, :);
            
            app.spike_struct = app.spikeCell{app.channel};
            app.spikeTimes = app.spike_struct.(app.wavelet);
            updateVars(app);
            app.ChannelIDEditField_2.Value = app.ChannelIDEditField.Value;
        end

        % Value changed function: SpikeSlider
        function SpikeSliderValueChanged(app, event)
            value = app.SpikeSlider.Value;
            app.spike = round(value);
            app.SpikenoEditField.Value = num2str(app.spike);
            plotBin(app);
            plotSpike(app);
        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)
            firingRate = round(app.spikeCount/(length(app.trace)/25000),2);
            app.FiringrateEditField.Value = [num2str(firingRate) ' Hz'];
            app.CostparameterEditField.Value = num2str(app.L);
            app.spikesEditField.Value = num2str(app.spikeCount);
            
            plotTrace(app, app.trace, app.spikeTimes);
            if strcmp(app.spikeMethod, 'Overlay')
                plotOverlay(app);
            else
                plotTemplate(app);
            end
            
            %% Plot histogram
            spikeWaveforms = app.waveforms;
            for i = 1:length(spikeWaveforms)
                app.amp(i) = min(spikeWaveforms(i,:));
            end
            app.UIAxes3.cla;
            histogram(app.UIAxes3, app.amp, 'FaceColor', [0.4940, 0.1840, 0.5560]);
            hold(app.UIAxes3);
            
        end

        % Button pushed function: NextButton
        function NextButtonPushed(app, event)
            app.spike = app.spike+1;
            app.SpikenoEditField.Value = num2str(app.spike);
            plotBin(app);
            plotSpike(app)
        end

        % Button pushed function: PreviousButton
        function PreviousButtonPushed(app, event)
            if app.spike > 1
                app.spike = app.spike-1;
                app.SpikenoEditField.Value = num2str(app.spike);
                plotBin(app);
                plotSpike(app)
            end
        end

        % Button pushed function: TPButton
        function TPButtonPushed(app, event)
            app.TP = app.TP+1;
            updateStats(app);
        end

        % Button pushed function: FNButton
        function FNButtonPushed(app, event)
            app.FN = app.FN+1;
            updateStats(app);
        end

        % Button pushed function: FPButton
        function FPButtonPushed(app, event)
            app.FP = app.FP+1;
            updateStats(app);
        end

        % Value changed function: SpikenoEditField
        function SpikenoEditFieldValueChanged(app, event)
            value = app.SpikenoEditField.Value;
            app.spike = value;
        end

        % Value changed function: BinmsEditField
        function BinmsEditFieldValueChanged(app, event)
            value = app.BinmsEditField.Value;
            app.binLength = 25*(round(value)/2);
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            firingRate = app.FiringrateEditField.Value;
            Precision = app.precision;
            Sensitivity = app.sensitivity;
            spikeCount = app.spikeCount;
            save([app.fname(1:end-4) '_stats.mat'], 'Precision',...
                'Sensitivity', 'firingRate','spikeCount')
        end

        % Callback function
        function SaveplotButtonPushed(app, event)
            
        end

        % Callback function
        function CheckBoxValueChanged(app, event)
            
        end

        % Value changed function: ThresholdmethodDropDown
        function ThresholdmethodDropDownValueChanged(app, event)
            value = app.ThresholdmethodDropDown.Value;
            app.thrMode = value;
            plotHistogram(app);
        end

        % Value changed function: ThresholdvalueEditField
        function ThresholdvalueEditFieldValueChanged(app, event)
            value = app.ThresholdvalueEditField.Value;
            plotHistogram(app);
        end

        % Button pushed function: OverlayButton
        function OverlayButtonPushed(app, event)
            app.spikeMethod = app.OverlayButton.Text;
            plotOverlay(app);
        end

        % Button pushed function: TemplateButton
        function TemplateButtonPushed(app, event)
            app.spikeMethod = app.TemplateButton.Text;
            plotTemplate(app);
        end

        % Button pushed function: AvePlotButton
        function AvePlotButtonPushed(app, event)
            all_spikes = [];
            sp_struct = app.spikeCell{app.channel};
            app.UIAxes4.cla;
            app.UIAxes5.cla;
            for wav = 1:numel(app.wavelets)
                all_spikes = union(all_spikes, sp_struct.(app.wavelets{wav}));
            end
            clear F;
            intersectMatrix = zeros(length(all_spikes),length(app.wavelets));
            
            for wav = 1:length(app.wavelets)
                app.spikeTimes = sp_struct.(app.wavelets{wav});
                for spikeIndex = 1:length(all_spikes)
                    if ismember(all_spikes(spikeIndex), app.spikeTimes)
                        intersectMatrix(spikeIndex, wav) = 1;
                    end
                end
            end
            
            for spike = 1:length(intersectMatrix)
                clear ff
                ff = find(intersectMatrix(spike, :) == 1);
                if length(ff) == 1 && ff ~=0
                    F(spike) = ff;
                end
            end
            
            moving_average_dur_in_sec = 10;
            moving_average_window_frame = moving_average_dur_in_sec * 25000;
            
            for wav = 1:numel(app.wavelets)
                spike_train = zeros(length(app.trace), 1);
                spike_train(sp_struct.(app.wavelets{wav})) = 1;
                spike_count_moving_mean = movmean(spike_train, moving_average_window_frame);
                plot(app.UIAxes4, spike_count_moving_mean, 'Linewidth', 2)
                hold(app.UIAxes4, 'on');
                box(app.UIAxes4, 'off');
            end
            
            xlim(app.UIAxes4,[1 length(app.trace)]);
            set(app.UIAxes4,'TickDir','out');
            legend(app.UIAxes4, app.wavelets, 'Location','northeastoutside','Box','off');
            ylabel(app.UIAxes4, 'Moving average spike count')
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            app.yOffset = app.thr*7;
            
            plot(app.UIAxes5, app.trace,'k');
            hold(app.UIAxes5, 'on');
            
            %   Plot all spikes
            
            app.y = repmat(app.yOffset - 0, ...
                length(all_spikes), 1);
            
            scatter(app.UIAxes5, (all_spikes)', ...
                app.y, 'v','filled');
            hold(app.UIAxes5, 'on');
            
            
            %   Plot unique spikes for each wavelet
            for wav = 1:length(app.wavelets)
                
                uqSpkIdx = F == wav;
                uniqueSpikes = all_spikes(uqSpkIdx);
                
                app.y = repmat(app.yOffset - wav*3, ...
                    length(uniqueSpikes), 1);
                spikeCounts{wav+1} = length(app.y);
                
                scatter(app.UIAxes5, (uniqueSpikes)', ...
                    app.y, 'v','filled');
                hold(app.UIAxes5, 'on');
            end
            
            %   Plot common spikes (detected by all the wavelets)
            uqSpkIdx = F == 0;
            uniqueSpikes = all_spikes(uqSpkIdx);
            
            app.y = repmat(app.yOffset - (length(app.wavelets)+7), ...
                length(uniqueSpikes), 1);
            
            scatter(app.UIAxes5, (uniqueSpikes)', ...
                app.y, 'v','filled');
            
            xlim(app.UIAxes5,[1 length(app.trace)]);
            legend_labels = [{'Filtered trace' ;['All spikes']}; strcat(app.wavelets, ' (unique)');'Common spikes'];
            l = legend(app.UIAxes5, legend_labels);
            l.Location = 'northeastoutside';
            l.Box = 'off';
        end

        % Value changed function: WaveletDropDown
        function WaveletDropDownValueChanged(app, event)
            value = app.WaveletDropDown.Value;
            app.wavelet = strrep(value, '.','p');
            updateVars(app);
        end

        % Value changed function: ChannelIDEditField_2
        function ChannelIDEditField_2ValueChanged(app, event)
            value = app.ChannelIDEditField_2.Value;
            app.channel = (app.channels == value);
            app.trace = app.traces(app.channel, :);
            app.spike_struct = app.spikeCell{app.channel};
            app.spikeTimes = app.spike_struct.(app.wavelet);
            updateVars(app);
            app.ChannelIDEditField.Value = app.ChannelIDEditField_2.Value;
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {532, 532};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {593, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [250 250 925 532];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {593, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.LeftPanel);
            app.TabGroup2.Position = [1 6 587 525];

            % Create TraceTab
            app.TraceTab = uitab(app.TabGroup2);
            app.TraceTab.Title = 'Trace';

            % Create ChannelIDEditFieldLabel
            app.ChannelIDEditFieldLabel = uilabel(app.TraceTab);
            app.ChannelIDEditFieldLabel.HorizontalAlignment = 'right';
            app.ChannelIDEditFieldLabel.Position = [60 472 100 22];
            app.ChannelIDEditFieldLabel.Text = 'Channel ID:';

            % Create ChannelIDEditField
            app.ChannelIDEditField = uieditfield(app.TraceTab, 'numeric');
            app.ChannelIDEditField.ValueChangedFcn = createCallbackFcn(app, @ChannelIDEditFieldValueChanged, true);
            app.ChannelIDEditField.Position = [169 472 35 22];

            % Create BinmsEditFieldLabel
            app.BinmsEditFieldLabel = uilabel(app.TraceTab);
            app.BinmsEditFieldLabel.HorizontalAlignment = 'right';
            app.BinmsEditFieldLabel.Position = [94 442 67 22];
            app.BinmsEditFieldLabel.Text = 'Bin [ms]';

            % Create BinmsEditField
            app.BinmsEditField = uieditfield(app.TraceTab, 'numeric');
            app.BinmsEditField.ValueChangedFcn = createCallbackFcn(app, @BinmsEditFieldValueChanged, true);
            app.BinmsEditField.Position = [170 442 34 22];

            % Create LoadfileButton
            app.LoadfileButton = uibutton(app.TraceTab, 'push');
            app.LoadfileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadfileButtonPushed, true);
            app.LoadfileButton.Position = [256 449 100 40];
            app.LoadfileButton.Text = 'Load file';

            % Create Lamp
            app.Lamp = uilamp(app.TraceTab);
            app.Lamp.Position = [363 463 15 15];
            app.Lamp.Color = [1 0 0];

            % Create PlotButton
            app.PlotButton = uibutton(app.TraceTab, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.Position = [420 464 100 20];
            app.PlotButton.Text = 'Plot';

            % Create SpikeSliderLabel
            app.SpikeSliderLabel = uilabel(app.TraceTab);
            app.SpikeSliderLabel.HorizontalAlignment = 'right';
            app.SpikeSliderLabel.Position = [34 126 46 22];
            app.SpikeSliderLabel.Text = {'Spike #'; ''};

            % Create SpikeSlider
            app.SpikeSlider = uislider(app.TraceTab);
            app.SpikeSlider.Limits = [1 1000];
            app.SpikeSlider.MajorTicks = [1 101 201 301 401 501 601 701 801 901 1000];
            app.SpikeSlider.MajorTickLabels = {'1', '101', '201', '301', '401', '501', '601', '701', '801', '901', '1000'};
            app.SpikeSlider.ValueChangedFcn = createCallbackFcn(app, @SpikeSliderValueChanged, true);
            app.SpikeSlider.Position = [101 135 412 3];
            app.SpikeSlider.Value = 1;

            % Create PreviousButton
            app.PreviousButton = uibutton(app.TraceTab, 'push');
            app.PreviousButton.ButtonPushedFcn = createCallbackFcn(app, @PreviousButtonPushed, true);
            app.PreviousButton.Position = [184 48 100 40];
            app.PreviousButton.Text = 'Previous';

            % Create NextButton
            app.NextButton = uibutton(app.TraceTab, 'push');
            app.NextButton.ButtonPushedFcn = createCallbackFcn(app, @NextButtonPushed, true);
            app.NextButton.Position = [334 48 100 40];
            app.NextButton.Text = 'Next';

            % Create UIAxes
            app.UIAxes = uiaxes(app.TraceTab);
            title(app.UIAxes, 'Filtered trace')
            xlabel(app.UIAxes, 'Bin')
            ylabel(app.UIAxes, 'Voltage [\muV]')
            app.UIAxes.PlotBoxAspectRatio = [2.32044198895028 1 1];
            app.UIAxes.Position = [7 168 577 237];

            % Create WaveletDropDownLabel
            app.WaveletDropDownLabel = uilabel(app.TraceTab);
            app.WaveletDropDownLabel.HorizontalAlignment = 'right';
            app.WaveletDropDownLabel.Position = [41 412 48 22];
            app.WaveletDropDownLabel.Text = 'Wavelet';

            % Create WaveletDropDown
            app.WaveletDropDown = uidropdown(app.TraceTab);
            app.WaveletDropDown.Items = {'bior1.5', 'bior1.3', 'db2', 'Option 4'};
            app.WaveletDropDown.ValueChangedFcn = createCallbackFcn(app, @WaveletDropDownValueChanged, true);
            app.WaveletDropDown.Position = [104 412 100 22];
            app.WaveletDropDown.Value = 'bior1.5';

            % Create MovingaverageTab
            app.MovingaverageTab = uitab(app.TabGroup2);
            app.MovingaverageTab.Title = 'Moving average';

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.MovingaverageTab);
            title(app.UIAxes4, 'Moving average')
            xlabel(app.UIAxes4, '')
            ylabel(app.UIAxes4, 'Moving average spike count')
            app.UIAxes4.PlotBoxAspectRatio = [2.91875 1 1];
            app.UIAxes4.Position = [38 242 516 216];

            % Create AvePlotButton
            app.AvePlotButton = uibutton(app.MovingaverageTab, 'push');
            app.AvePlotButton.ButtonPushedFcn = createCallbackFcn(app, @AvePlotButtonPushed, true);
            app.AvePlotButton.Position = [446 467 100 22];
            app.AvePlotButton.Text = 'Plot';

            % Create UIAxes5
            app.UIAxes5 = uiaxes(app.MovingaverageTab);
            title(app.UIAxes5, '')
            xlabel(app.UIAxes5, 'Time')
            ylabel(app.UIAxes5, 'Voltage (\muV)')
            app.UIAxes5.PlotBoxAspectRatio = [2.7093023255814 1 1];
            app.UIAxes5.Position = [38 27 516 216];

            % Create ChannelIDEditField_2Label
            app.ChannelIDEditField_2Label = uilabel(app.MovingaverageTab);
            app.ChannelIDEditField_2Label.HorizontalAlignment = 'right';
            app.ChannelIDEditField_2Label.Position = [41 467 100 22];
            app.ChannelIDEditField_2Label.Text = 'Channel ID:';

            % Create ChannelIDEditField_2
            app.ChannelIDEditField_2 = uieditfield(app.MovingaverageTab, 'numeric');
            app.ChannelIDEditField_2.ValueChangedFcn = createCallbackFcn(app, @ChannelIDEditField_2ValueChanged, true);
            app.ChannelIDEditField_2.Position = [150 467 35 22];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.RightPanel);
            app.TabGroup.Position = [1 6 326 526];

            % Create SpikeTab
            app.SpikeTab = uitab(app.TabGroup);
            app.SpikeTab.Title = 'Spike';

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.SpikeTab);
            title(app.UIAxes2, 'Waveform')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Voltage [\muV]')
            app.UIAxes2.PlotBoxAspectRatio = [1 1.76897689768977 1];
            app.UIAxes2.XColor = [0.9412 0.9412 0.9412];
            app.UIAxes2.Position = [48 83 230 372];

            % Create TPButton
            app.TPButton = uibutton(app.SpikeTab, 'push');
            app.TPButton.ButtonPushedFcn = createCallbackFcn(app, @TPButtonPushed, true);
            app.TPButton.BackgroundColor = [0.6706 1 0.7294];
            app.TPButton.Position = [48 48 70 22];
            app.TPButton.Text = 'TP';

            % Create FNButton
            app.FNButton = uibutton(app.SpikeTab, 'push');
            app.FNButton.ButtonPushedFcn = createCallbackFcn(app, @FNButtonPushed, true);
            app.FNButton.BackgroundColor = [1 0.6706 0.7294];
            app.FNButton.Position = [128 48 70 22];
            app.FNButton.Text = 'FN';

            % Create FPButton
            app.FPButton = uibutton(app.SpikeTab, 'push');
            app.FPButton.ButtonPushedFcn = createCallbackFcn(app, @FPButtonPushed, true);
            app.FPButton.BackgroundColor = [1 0.6706 0.7294];
            app.FPButton.Position = [208 48 70 22];
            app.FPButton.Text = 'FP';

            % Create SpikenoEditFieldLabel
            app.SpikenoEditFieldLabel = uilabel(app.SpikeTab);
            app.SpikenoEditFieldLabel.HorizontalAlignment = 'right';
            app.SpikenoEditFieldLabel.Position = [79 458 56 22];
            app.SpikenoEditFieldLabel.Text = 'Spike no.';

            % Create SpikenoEditField
            app.SpikenoEditField = uieditfield(app.SpikeTab, 'text');
            app.SpikenoEditField.ValueChangedFcn = createCallbackFcn(app, @SpikenoEditFieldValueChanged, true);
            app.SpikenoEditField.Position = [150 458 49 22];

            % Create TemplateButton
            app.TemplateButton = uibutton(app.SpikeTab, 'push');
            app.TemplateButton.ButtonPushedFcn = createCallbackFcn(app, @TemplateButtonPushed, true);
            app.TemplateButton.Position = [182 89 84 22];
            app.TemplateButton.Text = 'Template';

            % Create OverlayButton
            app.OverlayButton = uibutton(app.SpikeTab, 'push');
            app.OverlayButton.ButtonPushedFcn = createCallbackFcn(app, @OverlayButtonPushed, true);
            app.OverlayButton.Position = [97 89 84 22];
            app.OverlayButton.Text = 'Overlay';

            % Create HistogramTab
            app.HistogramTab = uitab(app.TabGroup);
            app.HistogramTab.Title = 'Histogram';

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.HistogramTab);
            title(app.UIAxes3, 'Amplitude histogram')
            xlabel(app.UIAxes3, 'Amplitude [\muV]')
            ylabel(app.UIAxes3, 'No. of entries')
            app.UIAxes3.PlotBoxAspectRatio = [1.20555555555556 1 1];
            app.UIAxes3.Position = [4 189 321 237];

            % Create ThresholdmethodDropDownLabel
            app.ThresholdmethodDropDownLabel = uilabel(app.HistogramTab);
            app.ThresholdmethodDropDownLabel.HorizontalAlignment = 'right';
            app.ThresholdmethodDropDownLabel.Position = [35 147 103 22];
            app.ThresholdmethodDropDownLabel.Text = 'Threshold method';

            % Create ThresholdmethodDropDown
            app.ThresholdmethodDropDown = uidropdown(app.HistogramTab);
            app.ThresholdmethodDropDown.Items = {'MAD', 'STD'};
            app.ThresholdmethodDropDown.ValueChangedFcn = createCallbackFcn(app, @ThresholdmethodDropDownValueChanged, true);
            app.ThresholdmethodDropDown.Position = [153 147 125 22];
            app.ThresholdmethodDropDown.Value = 'MAD';

            % Create ThresholdvalueEditFieldLabel
            app.ThresholdvalueEditFieldLabel = uilabel(app.HistogramTab);
            app.ThresholdvalueEditFieldLabel.HorizontalAlignment = 'right';
            app.ThresholdvalueEditFieldLabel.Position = [35 114 90 22];
            app.ThresholdvalueEditFieldLabel.Text = 'Threshold value';

            % Create ThresholdvalueEditField
            app.ThresholdvalueEditField = uieditfield(app.HistogramTab, 'numeric');
            app.ThresholdvalueEditField.ValueChangedFcn = createCallbackFcn(app, @ThresholdvalueEditFieldValueChanged, true);
            app.ThresholdvalueEditField.Position = [153 114 30 22];

            % Create equalField
            app.equalField = uieditfield(app.HistogramTab, 'text');
            app.equalField.Position = [208 114 58 22];

            % Create Label
            app.Label = uilabel(app.HistogramTab);
            app.Label.Position = [182 114 25 22];
            app.Label.Text = '   =';

            % Create lbbLabel
            app.lbbLabel = uilabel(app.HistogramTab);
            app.lbbLabel.Position = [277 114 25 22];
            app.lbbLabel.Text = 'lbb';

            % Create StatsTab
            app.StatsTab = uitab(app.TabGroup);
            app.StatsTab.Title = 'Stats';

            % Create FiringrateEditFieldLabel
            app.FiringrateEditFieldLabel = uilabel(app.StatsTab);
            app.FiringrateEditFieldLabel.HorizontalAlignment = 'right';
            app.FiringrateEditFieldLabel.Position = [57 371 60 22];
            app.FiringrateEditFieldLabel.Text = 'Firing rate';

            % Create FiringrateEditField
            app.FiringrateEditField = uieditfield(app.StatsTab, 'text');
            app.FiringrateEditField.Position = [128 371 100 22];

            % Create SensitivityEditFieldLabel
            app.SensitivityEditFieldLabel = uilabel(app.StatsTab);
            app.SensitivityEditFieldLabel.HorizontalAlignment = 'right';
            app.SensitivityEditFieldLabel.Position = [49 329 60 22];
            app.SensitivityEditFieldLabel.Text = 'Sensitivity';

            % Create SensitivityEditField
            app.SensitivityEditField = uieditfield(app.StatsTab, 'text');
            app.SensitivityEditField.Position = [128 327 100 22];

            % Create samplesEditFieldLabel
            app.samplesEditFieldLabel = uilabel(app.StatsTab);
            app.samplesEditFieldLabel.HorizontalAlignment = 'right';
            app.samplesEditFieldLabel.Position = [51 243 60 22];
            app.samplesEditFieldLabel.Text = '# samples';

            % Create samplesEditField
            app.samplesEditField = uieditfield(app.StatsTab, 'text');
            app.samplesEditField.Position = [128 243 100 22];

            % Create PrecisionEditFieldLabel
            app.PrecisionEditFieldLabel = uilabel(app.StatsTab);
            app.PrecisionEditFieldLabel.HorizontalAlignment = 'right';
            app.PrecisionEditFieldLabel.Position = [60 285 55 22];
            app.PrecisionEditFieldLabel.Text = 'Precision';

            % Create PrecisionEditField
            app.PrecisionEditField = uieditfield(app.StatsTab, 'text');
            app.PrecisionEditField.Position = [128 285 100 22];

            % Create CostparameterEditFieldLabel
            app.CostparameterEditFieldLabel = uilabel(app.StatsTab);
            app.CostparameterEditFieldLabel.HorizontalAlignment = 'right';
            app.CostparameterEditFieldLabel.Position = [26 455 89 22];
            app.CostparameterEditFieldLabel.Text = 'Cost parameter';

            % Create CostparameterEditField
            app.CostparameterEditField = uieditfield(app.StatsTab, 'text');
            app.CostparameterEditField.Position = [129 455 100 22];

            % Create spikesEditFieldLabel
            app.spikesEditFieldLabel = uilabel(app.StatsTab);
            app.spikesEditFieldLabel.HorizontalAlignment = 'right';
            app.spikesEditFieldLabel.Position = [63 413 50 22];
            app.spikesEditFieldLabel.Text = '# spikes';

            % Create spikesEditField
            app.spikesEditField = uieditfield(app.StatsTab, 'text');
            app.spikesEditField.Position = [128 413 100 22];

            % Create SaveButton
            app.SaveButton = uibutton(app.StatsTab, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [128 201 100 22];
            app.SaveButton.Text = 'Save';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = spikeBrowser

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end