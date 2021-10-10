function mse = MSError(raw,data,filt_order)
    kernal = ones(1,filt_order)/filt_order;
    grp_delay = floor((filt_order)/2);
    ma_filtered = filter(kernal,1,data); 
    
    aligned_array = zeros(size(raw));
    aligned_array(1:length(raw)-grp_delay+1)= ma_filtered(grp_delay:end);

%     mse = (sum((raw - aligned_array).^2))/length(aligned_array);
    mse = immse(raw, aligned_array);
end