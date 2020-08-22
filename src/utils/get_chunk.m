function [n_chunk, idx_chunk] = get_chunk(n_size, n_split)
%GET_CHUNK Split data into chunks with maximum size.
%   [n_chunk, idx_chunk] = GET_CHUNK(n_size, n_split)
%   n_size - number of data to be splitted in chunks  (integer)
%   n_split - number of data per chunk  (integer)
%   n_chunk - number of created chunks  (integer)
%   idx_chunk - cell with the indices of the chunks  (cell of array of indices)
%
%   The division of computational data is useful:
%      - Dividing the data for parallel loop (loop)
%      - Reducing the data in the memory while computing
%
%   (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init the data
idx = 1;
idx_chunk = {};

% create the chunks indices
while idx<=n_size
    idx_new = min(idx+n_split,n_size+1);
    vec = idx:(idx_new-1);
    idx_chunk{end+1} = vec;
    idx = idx_new;
end

% count the chunks
n_chunk = length(idx_chunk);

end