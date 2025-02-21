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

% polynomial function to optimise 

polynomial = @(pars, x, y) (-(pars(1) - (pars(1) * x ./ y)) + sqrt((pars(1) - (pars(1) * x ./ y)) - (2 * pars(2) * pars(1) ./ y))) ./ (-pars(1) ./ y);

for m = 1:1 %1:n_mice
    m_dat = mouse_dat(m,:);
    m_dat = m_dat(m_dat~="NA"); % removing dummy NA entries

    % looping over all sessions for this mouse

    for sess = 1:1 %1 : length(m_dat)

        % loading the behavioural timings file
        % and note start and stop times

        load(data_f + m_dat(sess) + "/" + behav_file)

        n_songs = length(T_Motor);
        song_durs = T_Motor(:,2) - T_Motor(:,1);

        syll_start_stop = SyllStartStopTimes;

        note_start_times = [];
        note_delta_times = [];
        song_len_values = [];

        for song_n = 1:n_songs

            % get all note start and end times
            all_note_ons = syll_start_stop(song_n).Ons;
            note_offs = syll_start_stop(song_n).Offs;

            % number of note starts to consider (1 less than total)
            n_note_starts = length(all_note_ons) - 1;

            % generate vectors of reqd note starts and corresp note deltas
            note_ons = all_note_ons(1:n_note_starts);
            note_ons = note_ons - note_ons(1); % normalise start to 0
            delta_ts = diff(all_note_ons);

            % create vector of same length with each element as song len
            song_len = song_durs(song_n);
            song_len_vec = song_len * ones(1, n_note_starts);

            % append to existing vectors
            note_start_times = cat(1, note_start_times, note_ons);
            note_delta_times = cat(1, note_delta_times, delta_ts);
            song_len_values = cat(2, song_len_values, song_len_vec);

        end

        % Define objective function
        objective = @(pars) sum((polynomial(pars, note_start_times, song_len_values') - note_delta_times).^2);
        
        % Define lower and upper bounds for parameters
        lb = [-10, 3000]; 
        ub = [10, 6000]; 
        
        % Minimize the objective function w/genetic algo
        options = optimoptions('ga', 'Display', 'iter', 'MaxGenerations', 500);
        [optimal_params, fval] = ga(objective, 2, [], [], [], [], lb, ub, [], options);
        
        % Display the results
        fprintf('Optimal parameters: gamma = %f, B = %f\n', optimal_params(1), optimal_params(2));
        fprintf('Sum of squared errors: %f\n', fval);

        disp('Length of all data being plotted =' + string(length(note_start_times)));

        fn_fit = polynomial(optimal_params, note_start_times, song_len_values');
        fig_path_plt = data_f + m_dat(sess) + "/allsong_" + string(song_n) + "_genetic_note_fitting.png";
        visualize_note_fitting(note_start_times, note_delta_times, fn_fit, fig_path_plt);

        for song_n = 1:n_songs

            % get all note start and end times
            all_note_ons = syll_start_stop(song_n).Ons;
            note_offs = syll_start_stop(song_n).Offs;

            % number of note starts to consider (1 less than total)
            n_note_starts = length(all_note_ons) - 1;

            % generate vectors of reqd note starts and corresp note deltas
            note_ons = all_note_ons(1:n_note_starts);
            delta_ts = diff(all_note_ons);

            % create vector of same length with each element as song len
            song_len = song_durs(song_n);
            song_len_vec = song_len * ones(1, n_note_starts);

            fn_fit = polynomial(optimal_params, note_ons, song_len_vec');

            fig_path_plt = data_f + m_dat(sess) + "/song_" + string(song_n) + "_genetic_note_fitting.png";

            visualize_note_fitting(note_ons, delta_ts, fn_fit, fig_path_plt);
        end
    end

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