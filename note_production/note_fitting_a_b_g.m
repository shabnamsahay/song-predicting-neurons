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

for m = 1:1 %1:n_mice
    m_dat = mouse_dat(m,:);
    m_dat = m_dat(m_dat~="NA"); % removing dummy NA entries

    % looping over all sessions for this mouse

    for sess = 1:1 %1 : length(m_dat)

        % loading the behavioural timings file
        % and note start and stop times

        load(data_f + m_dat(sess) + "/" + behav_file)

        n_songs = length(T_Motor);
        syll_start_stop = SyllStartStopTimes;
        song_durs = T_Motor(:,2) - T_Motor(:,1);

        for song_n = 1:n_songs

            all_note_ons = syll_start_stop(song_n).Ons;
            note_offs = syll_start_stop(song_n).Offs;

            n_note_starts = length(all_note_ons) - 1;

            note_ons = all_note_ons(1:n_note_starts);
            note_ons = note_ons - note_ons(1);
            delta_ts = diff(all_note_ons);

            % Initial guess and bounds
            initGuess = [rand+1, rand, rand];
            lb = [0.01, -100, -100];
            ub = [100, 100, 100];

            % Set up the optimization problem
            problem = createOptimProblem('fmincon', 'x0', initGuess, ...
                'objective', @(coeffs) polyFunc(coeffs, note_ons, delta_ts), ...
                'lb', lb, 'ub', ub);
        
            % Use GlobalSearch
            gs = GlobalSearch;
            [coeffs, fval] = run(gs, problem);
        
            % Display the results
            fprintf('Optimized constants: alpha = %.4f, beta = %.4f\n, gamma = %.4f\n', coeffs(1), coeffs(2), coeffs(3));
            fprintf('Objective function value: %.4f\n', fval);
            fprintf('Song length: %.4f\n', song_durs(song_n));

            alpha_opt = coeffs(1);
            beta_opt = coeffs(2);
            gamma_opt = coeffs(3);
            fn_fit = (-(gamma_opt - alpha_opt*note_ons) + sqrt((gamma_opt - alpha_opt*note_ons).^2 - (2*alpha_opt*beta_opt))) ./ (-alpha_opt);
    

            fig_path_plt = data_f + m_dat(sess) + "/song_" + string(song_n) + "_note_fit_a_b_g.png";
            visualize_note_fitting(note_ons, delta_ts, fn_fit, fig_path_plt);
        end
    end
end

function error = polyFunc(coeffs, xdata, ydata)
    alpha = coeffs(1);
    beta = coeffs(2);
    gamma = coeffs(3);
    ypred = (-(gamma - alpha*xdata) + sqrt((gamma - alpha*xdata).^2 - (2*alpha*beta))) ./ (-alpha);
    %ypred = (alpha-xdata) - sqrt( (alpha - xdata).^2 + D);
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