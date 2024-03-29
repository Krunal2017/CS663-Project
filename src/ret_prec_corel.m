%% PRECISION COMPUTATION FOR RETRIEVAL - COREL DATABASE

function [prec] = ret_prec_corel(score_struct_sorted, D, top_im_num, keyword, database_dir, k)
    N = length(D);
    Nr = top_im_num;
    
    true_total = 0;
    ret_total = 0;
    
    D_struct = struct();
    Dr_struct = struct();
    
    %Database Directory
    %dir_name = strcat(strcat(database_dir,keyword),'/Src/');
    
    %Find Ground Truth
    for i=1:N
        c = strsplit(D(i).name, '_');
        temp = cell2mat(c(1));
        D_struct(i).name = temp;
        
        %filename = strcat(strcat(dir_name, D_struct(i).name), '.png'); 
        if(k == temp)
            true_total = true_total + 1;
        end
    end   
    
    %Find correct retrieved images
    for i=1:Nr
        c = strsplit(score_struct_sorted(i).name, '_');
        temp = cell2mat(c(1));
        Dr_struct(i).name = temp;
        
        %filename = strcat(strcat(dir_name, Dr_struct(i).name), '.png'); 
        if(k == temp)
            ret_total = ret_total + 1;
        end
    end   
    %(ret_total);
    %disp(true_total);
    prec = (ret_total / top_im_num)*100;

end