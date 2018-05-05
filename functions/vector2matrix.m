function X = vector2matrix(Y, cols )
    if (isvector(Y))
        if (mod(size(Y,2), cols) == 0)
            X = vec2mat(Y, cols);
        else
            error('N�mero de colunas incompat�vel para a convers�o do vetor em matrix.');
        end
    else
        error('A vari�vel Y n�o � um vetor.');
    end
end

