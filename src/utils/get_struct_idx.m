function struct_out = get_struct_idx(struct_in, idx)

struct_out = struct();
field = fieldnames(struct_in);
for i=1:length(field)
    struct_in_tmp = struct_in.(field{i});
    if isstruct(struct_in_tmp)
        struct_out.(field{i}) = get_struct_idx(struct_in_tmp, idx);
    else
        assert(isnumeric(struct_in_tmp)||islogical(struct_in_tmp), 'invalid data')
        struct_out.(field{i}) = struct_in_tmp(idx);
    end
end

end