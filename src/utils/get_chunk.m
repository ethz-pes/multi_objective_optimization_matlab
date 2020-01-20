function [n_chunk, idx_chunk] = get_chunk(n_sweep, n_split)
%GET_CHUNK Split data into chunks with maximum size.
%   [n_chunk, idx_chunk] = GET_CHUNK(n_sweep, n_split)
%   n_sweep - number of data to be splitted in chunks  (integer)
%   n_split - number of data per chunk  (integer)
%   n_chunk - number of created chunks  (integer)
%   idx_chunk - cell with the indices of the chunks  (cell of index array)
%
%   The division of computational data is useful:
%       - Dividing the data for parallel loop (loop)
%       - Reducing the data in the memory while computing

%   Thomas Guillod.
%   2020 - BSD License.

% init the data
idx = 1;
idx_chunk = {};

% create the chunks indices
while idx<=n_sweep
    idx_new = min(idx+n_split,n_sweep+1);
    vec = idx:(idx_new-1);
    idx_chunk{end+1} = vec;
    idx = idx_new;
end

% count the chunks
n_chunk = length(idx_chunk);

end