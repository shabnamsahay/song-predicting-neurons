function f = convolved_firing_rates(song_intvs, spike_ts, ...
                                      start_delta, stop_delta, ...
                                      sampling_intv, ...
                                      delta_is_from_onset)
    
    n_songs = length(song_intvs);
    num_samples = get_n_samples(start_delta, stop_delta, sampling_intv);

    convolved_firing_vecs = zeros(num_samples,n_songs);

    for i = 1:n_songs

        delta_pt = song_intvs(i, 2); % assuming the delta is from song offset
        if delta_is_from_onset
            delta_pt = song_intvs(i, 1);
        end
        
        start_t = delta_pt + start_delta;
        end_t = delta_pt + stop_delta;
        
        spikes_within = spike_ts(spike_ts >= start_t);
        spikes_within = spikes_within(spikes_within <= end_t);

        single_trial_firing_rate = convolve_spikes(spikes_within, sampling_intv, ...
                                                   start_t, end_t);

        convolved_firing_vecs(:,i) = single_trial_firing_rate;
    end

    f = convolved_firing_vecs;
end

function f = convolve_spikes(spikes_within, sampling_intv, start_t, end_t)

    n_spikes = length(spikes_within);
    num_samples = get_n_samples(start_t, end_t, sampling_intv);

    f = zeros(num_samples, 1);

    for i = 1:num_samples
        crt_sample_time = start_t + (i-1)*sampling_intv;
        
        crt_convolved_val = 0;

        for j = 1:n_spikes % adding the gaussian kernel fn val from each spike
            crt_spike_time = spikes_within(j, 1);
            crt_spike_kernel_val = gaussian_kernel(crt_sample_time, crt_spike_time);
            crt_convolved_val = crt_convolved_val + crt_spike_kernel_val;
        end

        % for cases where n_spikes is 0
        % add a v small random number to prevent NaN correlation
        if crt_convolved_val == 0
            crt_convolved_val = rand(1)*1e-7;
        end
        f(i,1) = crt_convolved_val;
    end
end

function f = gaussian_kernel(sample_pt, mu)

    sigma = 0.2; % default value specified for now

    numrt = (sample_pt - mu)^2;
    denmt = 2 * sigma^2;
    f = exp(-1 * numrt / denmt);
end