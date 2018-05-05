function [Ylabels, pcs, Xcoeff, Xscore, Xlatent, Xtsquared, Xexplained, mu] = unsupervisedAnalysis(HSI, Ylabels, path, bgRemove, clusters, sample_cluster, autosave)   

    %configura��o dos diret�rios do toolbox
    addpath('..\functions\');
    addpath('..\data\');
    
    %solicita��o do diret�rio de trabalho, onde ser�o armazenados os
    %arquivos resultantes da an�lise.
    if (~exist('path','var') || isempty(path))
        path = input('Digite o caminho da pasta de trabalho ou pressione ENTER continuar: ','s');
        
        % evitar erro por n�o inserir o caminho.
        if isempty(path)
            path = pwd;
        end
    end
    
    %convers�o da HSI em matriz bidimensional
    disp('Convertendo HSI em Matriz ...');
    MATRIZ_X = hsi2matrix(HSI);
    
    %verifica��o da exist�ncia da vari�vel de refer�ncia Ylabels
    if (exist('Ylabels','var') && ~isempty(Ylabels))    
        if (~isvector(Ylabels) && ismatrix(Ylabels))
            if (size(Ylabels,1) == size(HSI,1) && size(Ylabels,2) == size(HSI,2))
                LABELS = matrix2vector(Ylabels);
                LABELS = LABELS';
            else
                LABELS = ones(1,size(MATRIZ_X,1));
            end
        else
            error('A vari�vel "Ylabels" deve possuir 2 dimens�es.');
        end        
    else
        LABELS = ones(1,size(MATRIZ_X,1));
    end
    
%     %verifica��o do par�metro 'img'.
%     if (~exist('img','var') || isempty(img))
%         img = getImage(HSI, Ylabels, 50);
%     end
    img = getImage(HSI, Ylabels, 50);
    
    %armazendando imagem original
    if ~isempty(path)
        imwrite(img,strcat(path,'hsi_original.png'));
    end
    
    if ~exist('bgRemove','var')
        bgRemove = -1;
    end
    
    % rotina para remo��o de sinais espectrais indesejados. Essa rotina � 
    % em an�lise de agrupamento, portanto, n�o � um m�todo preciso e o 
    % resultado � sens�vel ao contexto. Podem ser necess�rias mais de uma 
    % execu��o dessa rotina para se atingir o objetivo desejado.
    opt = 1;
    amostra = 0;
    exec = 0;
    remove = bgRemove;
    while opt == 1
        disp('Apresentando layer 50 ...');    
        figure;
        imshow(img);       
        
        if remove == -1            
            opt = input('Deseja aplicar a remo��o de fundo? 1 - Sim, 2 - N�o -> ');
        else
            if remove > 0
                opt = 1;
                remove = remove -1;
            else
                opt = 2;
            end
        end
        if (opt == 1)
            exec = exec + 1;
            disp('Executando PCA e K-Means para separar fundo e amostra...');        
            LABELS(LABELS~=0) = hsiRemoveBackground(MATRIZ_X(LABELS~=0,:));

            %Centrar na m�dia
            MATRIZ_X = MATRIZ_X - repmat(mean(MATRIZ_X), size(MATRIZ_X,1), 1);

            img1 = showCluster(img, LABELS, 1, 0, 0, 255); 
            img2 = showCluster(img, LABELS, 2, 0, 255, 0);
            
            if (~exist('sample_cluster','var') || isempty(sample_cluster))
                amostra = input('Qual imagem representa o cluster com amostra? (1 ou 2) -> ');
            else
                if (size(sample_cluster,2) == bgRemove)
                    amostra = sample_cluster(1,exec);
                else
                    amostra = input('Qual imagem representa o cluster com amostra? (1 ou 2) -> ');
                end
            end

            if (amostra == 1)
                img = img2;                
            else
                img = img1;
            end            
            LABELS(LABELS~=amostra) = 0;        
        end
        close all;
    end
    
    if (isempty(path) == 0 && exist('img1','var') && exist('img2','var'))  
        if (amostra == 1)
            imwrite(img2,strcat(path,'hsi_amostra.png'));
            imwrite(img1,strcat(path,'hsi_fundo.png'));
        else
            imwrite(img1,strcat(path,'hsi_amostra.png'));
            imwrite(img2,strcat(path,'hsi_fundo.png'));
        end        
    end
    
    if ~exist('clusters','var')
        k = input('Deseja agrupar a amostra em quantos clusters? -> ');
    else
        k = clusters;
    end
    
    
    %PCA
    disp('Executando PCA ...');    
    [Xcoeff,Xscore, Xlatent, Xtsquared, Xexplained, mu] = pca(MATRIZ_X(LABELS~=0,:));
    
    pcs = 1;
    while (sum(Xexplained(1:pcs,1)) < 95)
        pcs = pcs +1;
    end
    
    disp(strcat('Executando K-Means usando 0',int2str(pcs),' pc(s)'));    
    LABELS(LABELS ~= 0) = getClusters( Xscore, pcs, k );
    
    for i=1:k
       [gray_image, rgb_image] = showCluster(img, LABELS, i, 255, 0, 0); 
       if isempty(path) == 0
            imwrite(rgb_image,strcat(path,'hsi_cluster_',num2str(i),'.png'));
        end
    end       
    
    disp('Armazenando Vari�veis... Aguarde!');        
    Ylabels = vector2matrix(LABELS, size(HSI,2));
    if (exist('autosave','var') && autosave == 1)
        save(strcat(path,'unsupervisedAnalysis.mat'), 'HSI', 'Ylabels', 'pcs', 'Xcoeff', 'Xscore', 'Xlatent', 'Xtsquared', 'Xexplained', 'mu');
    end
    
    close all;
    disp('Finalizado!');    
end