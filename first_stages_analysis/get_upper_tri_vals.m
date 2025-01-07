function f = get_upper_tri_vals(mat)

    upper_mat = triu(mat,1);
    flat_mat = reshape(upper_mat,1,[]);
    wo_zeros_mat = flat_mat(flat_mat~=0);

    f = wo_zeros_mat;
end