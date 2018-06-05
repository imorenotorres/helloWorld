%% ---------------------------------------------*SCRIPT DESCRIPTION*---------------------------------------------------------------------------------------------------------%
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------%
%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------%


%Euclidean distance evaluator algorithm. V.0.1

    %1º) The algorithm create or load the filter coefficients, for the
    %assesment.
    %2º) The algorithm call segmentator function (SF). Currently, this
    %SF, can be 2 different functions. One is a fixed segmentation, and
    %another one is based on the korean article (instantenous phase).
    %3º) Once we have all the segments from the original signal into a cell array, 
    %the algorithm calculates euclidean (assesment) distance of 2 consecutive segments.

    %The PROCEDURE for this euclidean distance ASSESMENT is:
    
    %   1) Take one segment and its consecutive. Seg1 and Seg2.
    %   2) Filter those segments along 15 frequency bands.
    %   3) Calculates the energy of each segment band. It give us a
    %   15-Energy vector.
    %   4) Compare the 15-Energy vector of segment 1, with the  15-Energy
    %   vector of segment 2, by means of the euclidean distance.
    
    %----------------Graphic illustration----------------------------------%
    
    %                 15-band-filtered
    %   1|Segment1 ------------------------->  15-Energy vector of Seg1 (Ev1)     
    %   2|Segment2 ------------------------->  15-Energy vector of Seg2 (Ev2)
    %      .                                                ||
    %      .                                Euclidean distance of Ev1 with Ev2
    %      .                                                ||
    %   N|SegmentN                        Value represents espectral differences 
    %                                         between 2 consecutive segments
    
    
%-------------------------Variable description------------------------------%

%Configurable variables: 
% 
%   -segmentacion_tipo: string variable that indicates which kind of segmentation function you
%                       want to use. In case it contains 'fija', a fixed
%                       segmentation will be executed. In case it contains
%                       'fases', the korean-type segmentation will be
%                       executed.
% 
%   
% Constant-value variables:
%  
% 
% Variables within script: 
%
%   -nSeg: scalar value that indicates the number of segments.
%   -iniFin: integer-value array of 2 columns and nSeg rows. 
%            Those values represent the begining and ending of each segments
%            in samples. There 2 cases where those samples are from
%            different Fs from the original one.
%                  -When is a fixed segmentation, those ini-fin samples
%                  come from the original sample rate.
%                  -When is a phase instantenous segmentation, those
%                  ini-fin samples come from the sample rate used for the
%                  segmentation function. Therefore, it is important to
%                  convert them to the original ones.
%
%    *Storing segments:
%
%   -x_framedF: a matrix of nSeg rows and many columns as the length of the
%               longest-element segment. Only for fixed segmentation.
%   -x_framed: a cell array of nSeg cells, where in each cell there is a segment from the 
%              original signal x, with a certain length.  
% 
% External Functions: 
% 
% 
%   -results: is a matrix that contains 3 columns and nfiles rows. It contains
%             information about the number of segments, its
%             euclidean distance mean, and euclidean distance sum in each wav-file.
% 
% 
% SEGUIR COMPLETANDO DESCRIPCION.....
% 
% 
% 
% 
% 
% 
% 
% Version: 0.1   Date:04/06/2018
% Copyrigth: Salvador Florido Llorens

%% Configurable: Variables globales del script

hacerDibujo=input('Hacer dibujo: ');
segmentacion_tipo=input('Tipo de segmentacion: ','s');  %fija o fases

sF='fija';
sV='fases';


if strcmp(segmentacion_tipo,sF)
    L=(input('Longitud ventana (ms): '))*(Fs/1000); %Pasamos a segundos y lo pasamos a muestras
    R=(input('Solapamiento ventana (ms): '))*(Fs/1000); %Pasamos a segundos y lo pasamos a muestras
end


%nfolder='Jasa_Prueba';
dirWavs=['../data/todasJasa_Q/ta*.*'];
lista = dir([dirWavs 'wav']);
results = zeros([length(lista) 3]); % Columnas: NTrans; MediaDEucl; SumDEuc


    
%% Bucle for principal. Itera por cada archivo de sonido en una carpeta (No tocar)
for ifile = 1:length(lista)
    
    %   For each .wav-file:
    
%------ STEP 1: Check if filters coefficients are created. If so, they have to be loaded. ------------------------------------------------------------------------------------------------------%
    
    existe=exist('filtros.mat');
    if existe==2
        %CASO EXISTEN LOS FILTROS, LOS CARGAMOS:
        load('filtros.mat');
    else
        [filtros,N]=filterMatrix_Loader(16000);
        save('filtros.mat','filtros');
    end
    
    
%------ STEP 2: Create double array "x", containing all amplitude values of ------------------------------------------------------------------------------------------------------%
    %           the speech sound file.
    
    filei=fullfile(lista(ifile).folder,lista(ifile).name);
    targetSil = lista(ifile).name;
    
    [x,Fs]=audioread(filei);
    
%-------STEP 3: String comparison for choosing the segmentation function.---------------------------------------------------------------------------------------------------------%
    
    % Case Fixed segmentation function.
    if strcmp(segmentacion_tipo,sF)
        %Calling "segmentacion_Fija_funcion", for a fixed segmentation.
        [x_framedF, splitter,iniFin]=segmentacion_Fija_funcion(x,Fs,targetSil,L,R, hacerDibujo); %Output arguments (see "segmentacion_Fija_funcion" description)
        [m,n]=size(iniFin);   %m,n are the indexes of last value of the iniFin matrix.
        %Storing in x_framed, original segments in each cell.
        x_framed={};
        for i=1:m
            x_framed{i} = x_framedF(i,:);
        end
    end
    
    %Case phase instantenous segmentation function.
    if strcmp(segmentacion_tipo,sV)
        %Calling "segmentacion_Fija_funcion", for a fixed segmentation.
        [iniFin,newFs,NF]=segmentacion_Fases_Funcion(x,Fs,targetSil);%Output arguments (see "segmentacion_Fija_funcion" description)
        
        %For explanation go to internal variable explanation, iniFin section.
        iniFinFs=iniFin.*(Fs/newFs);
        [m,n]=size(iniFinFs);
        iniFinFs(m,n)=length(x);
        iniFin=iniFinFs;
        %Storing in x_framed, original segments in each cell.
        x_framed={};
        for i=1:m
            x_framed{i} = x(iniFinFs(i,1):iniFinFs(i,2));
        end
    end
    
    
%-------STEP 4: Checking if Fs is greater than 16000Hz before bank filtering process. If so, array signal "x"---------------------------------------------------------------------------------------------------%
%               is decimated to 16000Hz, by means of calling function "LP_decimation_function". 

%   Becareful if Fs<16000 Hz!!!!!!!!!!
    if Fs>16000
        newFs=16000;
        [xD]=LP_decimation_function(x,Fs,newFs);
        Fs=newFs;
    end
%-------STEP 5: each segment is being 15-band filtered, and its 15-band energy is calculated and stored.----------------------------------------------------------------------------------------

    D_ec=zeros(m-1,1);
    energiasSeg=zeros(m,15);
    
 %  For a certain segment: Filtering and calculating its energy.
    for i=1:m %Segment by segment loop.
        for j=1:15 %Band by band loop.
            
            bandaSeg=(filter(filtros{j},1,x_framed{i}))';
            energiasSeg(i,j)=sum(bandaSeg.^2)./length(bandaSeg);
            
        end
    end
    
 %  For a certain segment i, the euclidean distance between its 15-energy vector
 %  and the one for i+1 segment is calculated.
    for i=1:m-1 %Segment by segment loop.
        
        D_ec(i,1)=euclidean_Distance(energiasSeg(i,:),energiasSeg(i+1,:));
        
    end
    
 %-------STEP 6: 2 calculation for the euclidean distance vector: sum and mean.----------------------------------------------------------------------------------------

 %  Sum:
    sumEc=sum(D_ec);
 %  Mean:
    medEc=sumEc/length(D_ec);
    
    
%-------STEP 7: Storing in a predefined matrix:  number of segments, sum of E.D, and mean of E.D.----------------------------------------------------------------------------------------

    %Number of segments:
    results(ifile,1) = m; 
    %Sum E.D:
    results(ifile, 2) = sumEc; 
    %Mean E.D:
    results(ifile, 3) = medEc; 
    
%-------STEP 8: Display of Euclidean distance down each transition.----------------------------------------------------------------------------------------
    if hacerDibujo == 1
        %Endings of each segment.
        endings=iniFin(:,2);
        %Minimum value of the original speech sound.
        minValueX=min(x);
        %Mean of euclidean distance vector.
        me=mean(D_ec);
        %Standard deviation of euclidean distance vector.
        stde=std(D_ec);
        
        %Loop that plot each z-score euclidean distance value in each
        %ending segment point, except last one.
        for iend=1:length(endings)-1
            x_ax=(endings(iend)/Fs);
            y_ax=minValueX+minValueX*0.1;
            z_score=(D_ec(iend)-me)/stde;
            z_score=round(z_score,2);
            v=text(x_ax,y_ax,num2str(z_score)); v.HorizontalAlignment='center';v.FontWeight='bold'; hold on;
        end
    end
end










