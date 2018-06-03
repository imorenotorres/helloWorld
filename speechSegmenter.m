%%

% v 0.1

%% selección del directorio y elección de ficheros a procesar

nfolder='todasJasa_Q';
dirWavs=[nfolder,'/ta*.'];


%% no cambiar nada

% addpath('C:\Users\USUARIO\Desktop\Librería_SpeechProcessing_Matlab\Estadística\Regresión\funciones');
% addpath('C:\Users\USUARIO\Desktop\Librería_SpeechProcessing_Matlab\Procesado_Señal_Habla\Segmentacion\funciones');

cargarFilt=input('Cargar filtros: ');
hacerDibujo=input('Hacer dibijo: ');
segmentacion_tipo=input('Tipo de segmentacion: ','s');  %fija o fases
%Si= 1, No= 0
sF='fija';
sV='fases';


if strcmp(segmentacion_tipo,sF)
    L=(input('Longitud ventana (ms): '))*(Fs/1000); %Pasamos a segundos y lo pasamos a muestras
    R=(input('Desplazamiento ventana (ms): '))*(Fs/1000); %Pasamos a segundos y lo pasamos a muestras
end


lista = dir([dirWavs 'wav']);
resultados = zeros([length(lista) 3]); % Columnas: NTrans; MediaDEucl; SumDEuc

if cargarFilt==1
    
    [filtros,N]=filterMatrix_Loader(nfolder,lista(1).name);
     
    
    for ifile = 1:length(lista)
        
        filei=fullfile(lista(ifile).folder,lista(ifile).name);
        targetSil = lista(ifile).name;
        
        [x,Fs]=audioread(filei);
        
        if strcmp(segmentacion_tipo,sF)
            [x_framedF, splitter,iniFin]=segmentacion_Fija_funcion(x,Fs,targetSil,L,R, hacerDibujo);
            [m,n]=size(iniFin);
            x_framed={};
            for i=1:m
                x_framed{i} = x_framedF(i,:);
            end
            del=iniFin(:,2); %array con todos los finales de segmento.
        end
        if strcmp(segmentacion_tipo,sV)
            [iniFin,newFs,NF]=segmentacion_Fases_Funcion(x,Fs,targetSil,hacerDibujo);
            
            %Metemos en una matriz los segmentos de la señal original.
            iniFinFs=iniFin.*Fs/newFs;  %La newFs=1000 Hz
            [m,n]=size(iniFinFs);
            iniFinFs(m,n)=length(x);
            xframed={};
            for i=1:m
                x_framed{i} = x(iniFinFs(i,1):iniFinFs(i,2));
            end
            del=iniFin(:,2); %array con todos los finales de segmento.
            del=del*(Fs/newFs); %Esas muestras les cambio su Fs por la original
        end
        
        
        %Filtramos cada segmento y en cada resultado calculamos la distancia
        %euclidea respecto el anterior.
        
        disEcMed=zeros(m-1,1);
        energias=zeros(2,15);
        t=1;
        for i=1:m-1 %bucle de segmento por segmento
            for j=1:15 %bucle de banda por banda
                
                bandaSeg1=(filter(filtros{j},1,x_framed{i}))';
                energias(1,j)=sum(bandaSeg1.^2)./length(bandaSeg1);
                bandaSeg2=(filter(filtros{j},1,x_framed{i+1}))';
                energias(2,j)=sum(bandaSeg2.^2)./length(bandaSeg1);
            end
            D_ec=euclidean_Distance(energias(1,:),energias(2,:));
            disEcMed(t,1)=D_ec;
            t=t+1;
        end
        
         sumEc=sum(disEcMed);
         medEc=sumEc/length(disEcMed);
        % zzz Aquí añado estos datos a la matriz Resultados: Num-trans;
        % DeucM y 
        resultados(ifile,1) = m; %zzz Número de transiciones
        resultados(ifile, 2) = sumEc; %zzz 
        resultados(ifile, 3) = medEc; %zzz 
        
        %-------------------VISUALIZACION DE LA DISTANCIA EUCLIDEA------------------------------------------------------------%
        if hacerDibujo == 1
            minValueX=min(x);
            me=mean(disEcMed);
            stde=std(disEcMed);
            for g=1:length(del)-1
                x_ax=(del(g)/Fs);
                y_ax=minValueX+minValueX*0.1;
                z_score=(disEcMed(g)-me)/stde;
                z_score=round(z_score,2);
                v=text(x_ax,y_ax,num2str(z_score)); v.HorizontalAlignment='center';v.FontWeight='bold'; hold on;
            end
        end 
    end
else
    for ifile = 1:length(lista)
        
        filei=fullfile(lista(ifile).folder,lista(ifile).name);
        targetSil = lista(ifile).name;
        
        [x,Fs]=audioread(filei);
        
        if strcmp(segmentacion_tipo,sF)
            [x_framedF, splitter,iniFin]=segmentacion_Fija_funcion(x,Fs,targetSil,L,R,hacerDibujo);
            [m,n]=size(iniFin);
            x_framed={};
            for i=1:m
                x_framed{i} = x_framedF(i,:);
            end
            del=iniFin(:,2); %array con todos los finales de segmento.
        end
        
        if strcmp(segmentacion_tipo,sV)
            [iniFin,newFs,NF]=segmentacion_Fases_Funcion(x,Fs,targetSil,hacerDibujo);
            
            %Metemos en una matriz los segmentos de la señal original.
            iniFinFs=iniFin.*Fs/newFs;  %La newFs=1000 Hz
            [m,n]=size(iniFinFs);
            iniFinFs(m,n)=length(x);
            xframed={};
            for i=1:m
                x_framed{i} = x(iniFinFs(i,1):iniFinFs(i,2));
            end
            del=iniFin(:,2); %array con todos los finales de segmento.
            del=del*(Fs/newFs); %Esas muestras les cambio su Fs por la original
        end
        
        
        
        %Filtramos cada segmento y en cada resultado calculamos la distancia
        %euclidea respecto el anterior.
        
        disEcMed=zeros(m-1,1);
        energias=zeros(2,15);
        t=1;
        for i=1:m-1 %bucle de segmento por segmento
            for j=1:15 %bucle de banda por banda
                
                bandaSeg1=(filter(filtros{j},1,x_framed{i}))';
                energias(1,j)=sum(bandaSeg1.^2)./length(bandaSeg1);
                bandaSeg2=(filter(filtros{j},1,x_framed{i+1}))';
                energias(2,j)=sum(bandaSeg2.^2)./length(bandaSeg1);
            end
            D_ec=euclidean_Distance(energias(1,:),energias(2,:));
            disEcMed(t,1)=D_ec;
            t=t+1;
        end
        
         sumEc=sum(disEcMed);
         medEc=sumEc/length(disEcMed);
        % zzz Aquí añado estos datos a la matriz Resultados: Num-trans;
        % DeucM y 
        resultados(ifile,1) = m; %zzz Número de transiciones
        resultados(ifile, 2) = sumEc; %zzz 
        resultados(ifile, 3) = medEc; %zzz 
        
        %-------------------VISUALIZACION DE LA DISTANCIA EUCLIDEA------------------------------------------------------------%
        if hacerDibujo == 1
            minValueX=min(x);
            me=mean(disEcMed);
            stde=std(disEcMed);
            for g=1:length(del)-1
                x_ax=(del(g)/Fs);
                y_ax=minValueX+minValueX*0.1;
                z_score=(disEcMed(g)-me)/stde;
                z_score=round(z_score,2);
                v=text(x_ax,y_ax,num2str(z_score)); v.HorizontalAlignment='center';v.FontWeight='bold'; hold on;
                
            end
            minValueX=min(x);
            d=text(del(1)/Fs,minValueX+minValueX*0.3,['Media distancias Euclideas: ',num2str(me)]);d.FontWeight='bold';
            d=text(del(1)/Fs,minValueX+minValueX*0.5,['Media notacion cientifica: ',num2str(me*10000),' ·10^{-4}']);d.FontWeight='bold';   
        end
    end
end







