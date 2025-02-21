clear all
clc
close all

data_f = "./Data_Arka/";
mouse_dat = ["190516","190521","190523","NA","NA","NA";
             "190705","190708","190709","190711","190716","190724";
             "191217","191223","NA","NA","NA","NA";
             "200917","200919","NA","NA","NA","NA"];

% file names

behav_file = "BehavioralTimings.mat";
clust_file = "clusterOutput.mat";
song_pred_neu_file = "SongPredNeurons.mat";

% parameters to adjust

song_type = "motor"; % motor vs. auditory
n_mice = 4; % how many mice to process

for m = 2:4 %1:n_mice
    m_dat = mouse_dat(m,:);
    m_dat = m_dat(m_dat~="NA"); % removing dummy NA entries

    % looping over all sessions for this mouse

    for sess = 1 : length(m_dat)

        % loading the behavioural timings file
        % and note start and stop times

        load(data_f + m_dat(sess) + "/" + behav_file)

        n_songs = length(T_Motor);
        syll_start_stop = SyllStartStopTimes;

        for song_n = 1:n_songs

            all_note_ons = syll_start_stop(song_n).Ons;
            note_offs = syll_start_stop(song_n).Offs;

            n_note_starts = length(all_note_ons) - 1;

            note_ons = all_note_ons(1:n_note_starts);
            note_ons = note_ons - note_ons(1);
            delta_ts = diff(all_note_ons);

            % Initial guess and bounds
            initGuess = [rand, rand];
            lb = [-20, -10];
            ub = [20, 10];

            % Set up the optimization problem
            problem = createOptimProblem('fmincon', 'x0', initGuess, ...
                'objective', @(coeffs) polyFunc(coeffs, note_ons, delta_ts), ...
                'lb', lb, 'ub', ub);
        
            % Use GlobalSearch
            gs = GlobalSearch;
            [coeffs, fval] = run(gs, problem);
        
            % Display the results
            fprintf('Optimized constants: c = %.4f, D = %.4f\n', coeffs(1), coeffs(2));
            fprintf('Objective function value: %.4f\n', fval);

            c_opt = coeffs(1);
            D_opt = coeffs(2);
            fn_fit = (c_opt - note_ons) - sqrt((c_opt - note_ons).^2 + D_opt);

            fig_path_plt = data_f + m_dat(sess) + "/song_" + string(song_n) + "_glbsearch_note_fitting.png";
            visualize_note_fitting(note_ons, delta_ts, fn_fit, fig_path_plt);
        end
    end
end

function error = polyFunc(coeffs, xdata, ydata)
    c = coeffs(1);
    D = coeffs(2);
    ypred = (c-xdata) - sqrt( (c - xdata).^2 + D);
    error = sum((ypred - ydata).^2);
end

function visualize_note_fitting(orig_x, orig_y, pred_y, fpath)

    fig = figure;

    scatter(orig_x, orig_y, 'filled', 'DisplayName', 'Original Data');
    hold on;

    plot(orig_x, pred_y, '-r', 'LineWidth', 2, 'DisplayName', 'Fitted Polynomial');
    hold off;

    xlabel('t0');
    ylabel('Delta T');
    title('Note Start and Gap Data');
    legend('show');

    saveas(fig, fpath)
    close(fig);

end