function [ HSI, Y ] = getSubPartOfHSI( HSI, Y, Li, Lf, Ci, Cf)

    %temporario
    if (~exist('Y','var') && ~isempty(Y))
        Y = ones(Lf - Li,Cf-Ci);
    else
        if (isvector(Y) == 0)
            if (size(Y,1) == size(HSI,1) && size(Y,2) == size(HSI,2))
                Y = Y(Li:Lf, Ci:Cf);
            else
                error('As dimens�es da vari�vel de refer�ncia Y s�o diferentes das dimens�es espaciais da HSI.');
            end
        else
            if (size(Y,2) == (size(HSI,1) * size(HSI,2)))
                Y = vec2mat(Y,size(HSI,2));
                Y = Y(Li:Lf, Ci:Cf);
                Y = Y';
                Y = Y(:);
                Y = Y';
            else
               error('A vari�vel de refer�ncia Y n�o possui a mesma quantidade de valores correspondente ao n�mero de pixel da HSI.');
            end            
        end            
    end
    
    HSI = HSI(Li:Lf, Ci:Cf, :);
    
    % definitivo
    % Y = Y(Li:Lf, Ci,Cf);
end

