song_intervals = [4, 6; 9, 12; 16.5, 21; 24.2, 29.5];
spike_times = [5.4; 7.8; 7.9; 10.2; 11.3; 12.2; 12.5; 12.9; 13.4; 13.6; 13.9; 14.8; 15.2; 15.7; 16.6; 16.9; 18; 20; 21.2; 21.6; 21.8; 22.3; 23.1; 23.9; 24.4; 25.6; 27.1; 28.2];
abs_st_time = 10.8;
duration_req = 4;

a = count_control_spikes(song_intervals, spike_times, abs_st_time, duration_req);
disp("Counted spikes " + string(a))

function f = count_control_spikes(song_intvs, spike_ts, abs_start_time, durn_rem)

    disp("New fn call with abs_start_time " + string(abs_start_time))
    disp("And duration_rem " + string(durn_rem))
    disp("And song intvs being considered as")
    disp(song_intvs)
    
    f = 0;
    n_songs = nrows(song_intvs);
    disp("Number of song_intvs being considered: " + string(n_songs))
    
    if n_songs == 0
        return
    end

    flag = false; % is recursion required?
    abs_end_time = abs_start_time + durn_rem;

    for i = 1:n_songs

        if durn_rem == 0
            break;
        end
    
        disp(i)
        disp(song_intvs(i,:))  
        crt_song_start = song_intvs(i, 1);
        crt_song_stop = song_intvs(i, 2);

        if (abs_start_time>crt_song_start && abs_start_time<crt_song_stop)

            flag = true;

            new_start_time = crt_song_stop;
            f = f + count_control_spikes(song_intvs(i+1:n_songs,:), spike_ts, ...
                                         new_start_time, durn_rem);

        elseif ((abs_end_time>crt_song_start && abs_end_time < crt_song_stop) || ...
                (abs_start_time<crt_song_start && abs_end_time>crt_song_stop))

            flag = true;

            durn_can_be_used = crt_song_start - abs_start_time;
            spikes_within = spike_ts(spike_ts >= abs_start_time);
            spikes_within = spikes_within(spikes_within <= crt_song_start);
            f = f + nrows(spikes_within);

            durn_rem = durn_rem - durn_can_be_used;
            new_start_time = crt_song_stop;
            f = f + count_control_spikes(song_intvs(i+1:n_songs,:), spike_ts, ...
                                         new_start_time, durn_rem);

        end
    end

    if ~flag
        spikes_within = spike_ts(spike_ts >= abs_start_time);
        spikes_within = spikes_within(spikes_within <= abs_end_time);
        f = f + nrows(spikes_within);
    else
        disp("Recursion was required!")
    end

    
end