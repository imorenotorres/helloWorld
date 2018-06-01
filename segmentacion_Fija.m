
clear all
targetsil= 'ta_03_S2';
[x,Fs]=audioread(['silabas/todasJasa/',targetsil,'.wav']);
L=(input('Longitud ventana (ms): '))*(Fs/1000); %Pasamos a segundos y lo pasamos a muestras
R=(input('Desplazamiento ventana (ms): '))*(Fs/1000); %Pasamos a segundos y lo pasamos a muestras
wt='rectwin';
[x_framed,splitter,iniFinS]=framer(x,Fs,L,R,wt);
%splitter es un vector que va de 1 hasta M (teoricamente) y cuyo aumento en
%cada valor es el de R.


%---------------------------Visualizacion---------------------------------------------------------------%

t=(1:length(x))/Fs;
figure; plot(t,x,'k'); hold on;

%lineas verticales delimitadoras
minValueX=min(x);

del=iniFinS(:,2); %array con todos los finales de segmento.
del=del./Fs; %De muestras a ssegundos
ax=gca;
ylims=ax.YLim;  %Te da un array de los limites en valor del plot
ax.YLim=[(minValueX+minValueX*0.8) ylims(2)];
for g=1:length(del)
    x= repelem(del(g),length(minValueX:0.01:ylims(2)));
    plot(x,minValueX:0.01:ylims(2),'b','LineStyle','--','LineWidth',2); hold on;
end

title(['Señal original silaba: ',targetsil,' | Segmentacion Fija']);









































