function y = mAvgfilter(data, filt_order)
    [~, len] = size(data);
    y = zeros(1, len);
    for i = 1:len
%         if i<=filt_order
%             y(i) = sum(data(1:i))/i;
%         else
%             y(i) = sum(data((i-filt_order):i))/filt_order;
%         end
        y(i) = (sum(data(max([1,i-filt_order+1]):i)))/min([i,filt_order]); 
        
    end
end