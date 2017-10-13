function cell = txt2cell(textfile, columns)
% Function that reads a textfile and returns a cell array with the
% indicated columns. If there is no indicated columns the function returns
% the whole textfile into a cell array. 
% Example: txt2cell(textfile) returns all columns.
%          txt2cell(textfile, [1 3 5]) returns the first, third and fifth
%          columns (in the specified order).
    if nargin < 2
       columns = 0; 
    end
    file = fopen(textfile);
    cell = [];
    while(1)
        row = fgetl(file);
        if(row == -1)
            break
        else
            split_row = strsplit(row);
            if columns
                cell = [cell; split_row(columns)]; %Return selected columns
            else
                cell = [cell; split_row]; %Return the whole txt
            end
        end
        
    end
    fclose(file);
end