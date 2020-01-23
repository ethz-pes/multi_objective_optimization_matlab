function struct_out = get_struct_size(struct_in, n_size)
%GET_STRUCT_SIZE Expand a struct of scalars to a struct of arrays.
%   struct_out = GET_STRUCT_SIZE(struct_in, n_size)
%   struct_in - input struct to be expanded (struct of scalars)
%   n_size - desired size for the arrays (integer)
%   struct_out - output struct of arrays (struct of arrays)
%
%   The input struct should have some properties:
%      - Struct can be nested (the function is recursive)
%      - The values of the struct should be 'numeric' or 'logical' scalars
%      - The values are transformed into arrays with repmat
%      - The arrays are row arrays.
%
%   See also GET_STRUCT_IDX, GET_STRUCT_ASSEMBLE.

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
        struct_out.(field{i}) = get_struct_size(struct_in_tmp, n_size);
    else
        % for values, expansion
        assert(isnumeric(struct_in_tmp)||islogical(struct_in_tmp), 'invalid data')
        assert(length(struct_in_tmp)==1, 'invalid data')
        struct_out.(field{i}) = repmat(struct_in_tmp, [1, n_size]);
    end
end

end