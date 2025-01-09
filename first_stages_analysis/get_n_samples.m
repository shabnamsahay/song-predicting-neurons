function f = get_n_samples(start_t, stop_t, intv)
    duration_of_interest = stop_t - start_t;
    f = round(duration_of_interest/intv);
end