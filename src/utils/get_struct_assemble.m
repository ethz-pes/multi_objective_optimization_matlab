function struct_out = get_struct_assemble(struct_in, n_size)
%GET_STRUCT_ASSEMBLE Assemble array of struct of arrays into a struct of arrays.
%   struct_out = GET_STRUCT_ASSEMBLE(struct_in)
%   struct_in - input array of struct to be concatenated (array of struct of arrays)
%   n_size - desired size for the arrays (integer)
%   struct_out - output struct of arrays (struct of arrays)
%
%   The input array of struct should have some properties:
%      - Struct can be nested (the function is recursive)
%      - The values of the struct should be 'numeric' or 'logical' arrays
%      - The values are concatenated respecting the input order
%      - The arrays are row arrays.
%
%   See also GET_STRUCT_IDX, GET_STRUCT_SIZE.
%
%   (c) 2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init the data
struct_out = struct();
field = fieldnames(struct_in);

% for each field
for i=1:length(field)
    % concatenate the structs
    struct_in_tmp = [struct_in.(field{i})];
    
    if isstruct(struct_in_tmp)
        % for struct, recursion
        struct_out.(field{i}) = merge_struct(struct_in_tmp, n_size);
    else
        % for values, assign
        assert(isnumeric(struct_in_tmp)||islogical(struct_in_tmp), 'invalid type')
        assert(size(struct_in_tmp, 2)==n_size, 'invalid type')
        struct_out.(field{i}) = struct_in_tmp;
    end
end

end