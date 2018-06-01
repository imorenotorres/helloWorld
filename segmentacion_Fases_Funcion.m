function [iniFin,newFs,NF]=segmentacion_Fases_Funcion(x,Fs,targetSil,hacerDibujo)

addpath('C:\Users\USUARIO\Desktop\Librería_SpeechProcessing_Matlab\Procesado_Señal_Habla\Segmentacion\funciones');

sil=targetSil;
%resample at 16KHz, as paper
tx=(1:length(x))./Fs;
%resample at 16KHz, as paper
newFs=1000;
[P,Q]=rat(newFs/Fs);
xr=resample(x,P,Q);
tr=(1:length(xr))/newFs;

%figure; freqz(b,a); title(['Filtro paso banda butter [',num2str(bandaTheta(1)*2),'-',num2str(bandaTheta(2)*2),'] Hz']);

%[z,p,k]=ellip(3,5,40,bandaTheta*2/Fs);
%[b,a]=zp2tf(z,p,k);

xH = hilbert(xr);
xIm=imag(xH);  %Resultado Transformada de hilbert. Calculo parte imaginaria.
envelope=sqrt(xr.^2+xIm.^2); %Envelope calculation

%Designing the butterworth filter and filtering the envelope.
%     bandaTheta=[f1,f2];
Fp1=4;  Fst1 = Fp1-3;
Fp2=10; Fst2 = Fp2+3;
Ap=6;
Ast1=40;
Ast2=40;
Hf = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,newFs);

H2= design(Hf,'equiripple');
NF=length(H2.numerator);
%fvtool(H2);

filteredEnvelope=filter(H2.numerator,1,envelope);

%We again take the hilbert transform
fE = hilbert(filteredEnvelope);
xImFb=imag(fE);  %Parte imaginaria del envelope filtrado. (fase)

%Four-Quadrant Inverse Tangent. To obtain phases from the 4 quadrants
fasesFirstBand=atan2(xImFb,filteredEnvelope);    %from [-pi,pi]

quad1=fasesFirstBand>=-pi & fasesFirstBand<=-(pi/2);
quad2=fasesFirstBand>=-(pi/2) & fasesFirstBand<=-0;
quad3=fasesFirstBand>=0 & fasesFirstBand<=(pi/2);
quad4=fasesFirstBand>=(pi/2) & fasesFirstBand<=pi;

segmentedsignal=quad1+2*quad2+3*quad3+4*quad4;
transiciones=find(diff(segmentedsignal)~=0);

% median filtering to avoid very small transitions
segmentedsignal=medfilt1(segmentedsignal,40);
segmentedsignal=medfilt1(segmentedsignal,40);
if segmentedsignal(1)==1.5
    segmentedsignal(1)=segmentedsignal(2);
end
transiciones=find(diff(segmentedsignal)~=0);
ntrans=length(transiciones)+1;

for i=1:ntrans
    
    if i==ntrans
        
        if segmentedsignal(transiciones(i-1)+1)>=1
            seg_Quad(i,1:2)=[i 1];
            %k=k+1;
        end
        
        if segmentedsignal(transiciones(i-1)+1)>=2 && segmentedsignal(transiciones(i-1)+1)<3
            seg_Quad(i,1:2)=[i 2];
            %k=k+1;
        end
        if segmentedsignal(transiciones(i-1)+1)==3
            seg_Quad(i,1:2)=[i 3];
            %k=k+1;
        end
        if segmentedsignal(transiciones(i-1)+1)==4
            seg_Quad(i,1:2)=[i 4];
            %k=k+1;
        end
        
    else
        
        if segmentedsignal(transiciones(i))==1
            seg_Quad(i,1:2)=[i 1];
            %k=k+1;
        end
        
        if segmentedsignal(transiciones(i))==2
            seg_Quad(i,1:2)=[i 2];
            %k=k+1;
        end
        if segmentedsignal(transiciones(i))==3
            seg_Quad(i,1:2)=[i 3];
            %k=k+1;
        end
        if segmentedsignal(transiciones(i))==4
            seg_Quad(i,1:2)=[i 4];
            %k=k+1;
        end
    end
end

Ei=zeros(ntrans,1);

inicio=zeros(ntrans,1);
final=zeros(ntrans,1);
midpoint=zeros(ntrans,1);

%To get the begining and end point of each segment. And then calculate its
%energy value.
for i=1:ntrans
    if i>1
        ini=transiciones(i-1)+1;
    else
        ini=1;
    end
    if i<ntrans
        fin=transiciones(i);
    else
        fin=length(xr);
    end
    inicio(i)=ini;
    final(i)=fin;
    midpoint(i)=(ini+fin)/2;
    ni=fin-ini+1;
    Ei(i)=sum(xr(ini:fin).^2)/ni;
end

d=sum(xr.^2)/length(xr);
i1=[];
i2=[];
i3=[];
i4=[];
for i=1:ntrans
    
    if seg_Quad(i,2)==1
        t=inicio(i):final(i);
        i1=[i1 t];
    end
    
    if seg_Quad(i,2)==2
        t=inicio(i):final(i);
        i2=[i2 t];
    end
    
    if seg_Quad(i,2)==3
        t=inicio(i):final(i);
        i3=[i3 t];
    end
    
    if seg_Quad(i,2)==4
        t=inicio(i):final(i);
        i4=[i4 t];
    end
end

%Get an array of segments by a begining -ending pairs.
l=1;
for i=1:ntrans
    if abs(inicio(i)-final(i))>1
        iniFin(l,1:2)=[inicio(i) final(i)];
        l=l+1;
    end
end

%IMPORTANTE: Contenido de estos arrays:
%            Columna 1: Valores de los indices que corresponde a un mismo quad.
%            Columna 2: Valores de la función firstBand que corresponden a un mismo quad.
%Maybe useful information.
ValoresFase1=[i1' filteredEnvelope(i1)]; %Rojo
ValoresFase2=[i2' filteredEnvelope(i2)]; %Azul
ValoresFase3=[i3' filteredEnvelope(i3)]; %Amarillo
ValoresFase4=[i4' filteredEnvelope(i4)]; %Verde

%With the real Fs signal:
i1r=i1*(Fs/newFs);
if i1r(end)>length(x)
    i1r(end)=length(x);
end

i2r=i2*(Fs/newFs);
if i2r(end)>length(x)
    i2r(end)=length(x);
end

i3r=i3*(Fs/newFs);
if i3r(end)>length(x)
    i3r(end)=length(x);
end

i4r=i4*(Fs/newFs);
if i4r(end)>length(x)
    i4r(end)=length(x);
end
ValoresFase1r=[i1r' x(i1r)]; %Rojo
ValoresFase2r=[i2r' x(i2r)]; %Azul
ValoresFase3r=[i3r' x(i3r)]; %Amarillo
ValoresFase4r=[i4r' x(i4r)]; %Verde




%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%
%----------------------------------------------------------VISUALIZACION--------------------------------------------------------------------------------------------------------------------%
%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------%
% dfases=diff(fasesFirstBand);
% dt=tr(2:end);

%VISUALIZACION LINGUISTICA:

if hacerDibujo == 1
    figure;
    
    %Visualizacion: Señal original, barra de segmentos, lineas verticales
    %delimitadoras.
    %barra de segmentos
    minValueX=min(x);
    minValueX1=repelem(minValueX,length(i1r));
    minValueX2=repelem(minValueX,length(i2r));
    minValueX3=repelem(minValueX,length(i3r));
    minValueX4=repelem(minValueX,length(i4r));
    plot(tx,x,'k');hold on;
    plot(i1r/Fs,minValueX1,'s','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',10);hold on;
    plot(i2r/Fs,minValueX2,'s','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',10);hold on;
    plot(i3r/Fs,minValueX3,'s','MarkerEdgeColor','y','MarkerFaceColor','y','MarkerSize',10);hold on;
    plot(i4r/Fs,minValueX4,'s','MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',10);hold on;
    xlabel('Tiempo(s)'); ylabel('Amplitud(Pa)'); title(['Silaba "',sil,'" señal original sin decimar']);
    
    %lineas verticales delimitadoras
    del=iniFin(:,2); %array con todos los finales de segmento.
    del=del*(Fs/newFs); %Esas muestras les cambio su Fs por la original
    ax=gca;
    ylims=ax.YLim;  %Te da un array de los limites en valor del plot
    ax.YLim=[(minValueX+minValueX*0.8) ylims(2)];
    for g=1:length(del)
        x= repelem(del(g)/Fs,length(minValueX:0.01:ylims(2)));
        plot(x,minValueX:0.01:ylims(2),'b','LineStyle','--','LineWidth',2); hold on;
    end
end

   
    %VISUALIZACION TECNICA:
    
%     figure;subplot(2,1,1);plot(tx,x);xlabel('Tiempo(s)'); ylabel('Amplitud(Pa)'); title(['Silaba "',sil,'" señal original sin decimar']); hold on;
%     
%     if isempty(i1r)
%     else
%         plot(i1r/Fs,ValoresFase1r(:,2),'.','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',15); hold on;
%     end
%     if isempty(i2r)
%     else
%         plot(i2r/Fs,ValoresFase2r(:,2),'.','MarkerEdgeColor','b','MarkerFaceColor','r','MarkerSize',15); hold on;
%     end
%     if isempty(i3r)
%     else
%         plot(i3r/Fs,ValoresFase3r(:,2),'.','MarkerEdgeColor','y','MarkerFaceColor','r','MarkerSize',15); hold on;
%     end
%     if isempty(i4r)
%     else
%         plot(i4r/Fs,ValoresFase4r(:,2),'.','MarkerEdgeColor','g','MarkerFaceColor','r','MarkerSize',15); hold off;
%     end
%     
%     subplot(2,1,2); 
%     plot(tr,xr);xlabel('Tiempo(s)'); ylabel('Amplitud(Pa)'); title(['Silaba "',sil,'" señal original diezmada']); hold on;
%     
%     if isempty(i1)
%     else
%         plot(i1/newFs,ValoresFase1rD(:,2),'.','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',15); hold on;
%     end
%     if isempty(i2)
%     else
%         plot(i2/newFs,ValoresFase2rD(:,2),'.','MarkerEdgeColor','b','MarkerFaceColor','r','MarkerSize',15); hold on;
%     end
%     if isempty(i3)
%     else
%         plot(i3/newFs,ValoresFase3rD(:,2),'.','MarkerEdgeColor','y','MarkerFaceColor','r','MarkerSize',15); hold on;
%     end
%     if isempty(i4)
%     else
%         plot(i4/newFs,ValoresFase4rD(:,2),'.','MarkerEdgeColor','g','MarkerFaceColor','r','MarkerSize',15); hold off;
%     end
%     
    
%     subplot(3,1,2); plot(tr,envelope); title(['Envelope silaba:"',sil,'" Decimado']);xlabel('Tiempo(s)'); ylabel('Amplitud(Pa)');
%     subplot(3,1,3);
%     
%     
%     if isempty(i1)
%     else
%         plot(i1/newFs,ValoresFase1(:,2),'.','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',5); hold on;
%     end
%     if isempty(i2)
%     else
%         plot(i2/newFs,ValoresFase2(:,2),'.','MarkerEdgeColor','b','MarkerFaceColor','r','MarkerSize',5); hold on;
%     end
%     if isempty(i3)
%     else
%         plot(i3/newFs,ValoresFase3(:,2),'.','MarkerEdgeColor','y','MarkerFaceColor','r','MarkerSize',5); hold on;
%     end
%     if isempty(i4)
%     else
%         plot(i4/newFs,ValoresFase4(:,2),'.','MarkerEdgeColor','g','MarkerFaceColor','r','MarkerSize',5); hold off;
%     end