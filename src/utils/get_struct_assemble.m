function struct_out = get_struct_assemble(struct_in)
%GET_STRUCT_ASSEMBLE Assemble array of struct of arrays into a struct of arrays.
%   struct_out = GET_STRUCT_ASSEMBLE(struct_in)
%   struct_in - input array of struct to be concatenated (array of struct of arrays)
%   struct_out - output struct of arrays (struct of arrays)
%
%   The input array of struct should have some properties:
%      - Struct can be nested (the function is recursive)
%      - The values of the struct should be 'numeric' or 'logical' arrays
%      - The values are concatenated respecting the input order
%
%   See also GET_STRUCT_IDX, GET_STRUCT_SIZE.

%   Thomas Guillod.
%   2020 - BSD License.

% init the data
struct_out = struct();
field = fieldnames(struct_in);

% for each field
for i=1:length(field)
    % concatenate the structs
    struct_in_tmp = [struct_in.(field{i})];
    
    if isstruct(struct_in_tmp)
        % for struct, recursion
        struct_out.(field{i}) = get_struct_assemble(struct_in_tmp);
    else
        % for values, assign
        assert(isnumeric(struct_in_tmp)||islogical(struct_in_tmp), 'invalid data')
        struct_out.(field{i}) = struct_in_tmp;
    end
end

end