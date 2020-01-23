function struct_out = get_struct_idx(struct_in, idx)
%GET_STRUCT_IDX Get specified indices in a struct of arrays.
%   struct_out = GET_STRUCT_IDX(struct_in, idx)
%   struct_in - input struct to be sliced (struct of arrays)
%   idx - indices to be selected (array of indices)
%   struct_out - output struct with the selected indices (struct of arrays)
%
%   The input struct should have some properties:
%      - Struct can be nested (the function is recursive)
%      - The values of the struct should be 'numeric' or 'logical' arrays
%      - The values are selected with respect to the provided indices
%      - The arrays are row arrays.
%
%   See also GET_STRUCT_SIZE, GET_STRUCT_ASSEMBLE.

%   Thomas Guillod.
%   2020 - BSD License.

% init the data
struct_out = struct();
field = fieldnames(struct_in);

% for each field
for i=1:length(field)
    struct_in_tmp = struct_in.(field{i});
    if isstruct(struct_in_tmp)
        % for struct, recursion
        struct_out.(field{i}) = get_struct_idx(struct_in_tmp, idx);
    else
        % for values, slicing with indices
        assert(isnumeric(struct_in_tmp)||islogical(struct_in_tmp), 'invalid data')
        struct_out.(field{i}) = struct_in_tmp(idx);
    end
end

end