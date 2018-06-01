function [filtros,N]=filterMatrix_Loader(nfolder,namefile)

lowcut = [250 421 505 607 720 877 1053 1266 1521 1827 2196 2638 3170 3809 4577];
highcut=[420 504 606 719 876 1052 1265 1520 1826 2195 2637 3169 3808 4576 7940];

%Creamos array de filtros. Es una matriz cuyas filas son arrays de
%coeficientes del filtro:




[x,Fs]=audioread(['silabas/',nfolder,'/',namefile]); 

if Fs>16000
    newFs=16000;
    [P,Q]=rat(newFs/Fs);
    %Diseño de un filtro óptimo
    Fsb = (Fs/Q)/2; Fpb = Fsb-500;
    Rp = 1;
    As = 60;
    dp = (10^(Rp/20)-1)/(10^(Rp/20)+1);%parámetro de desviasión (banda pasante).
    ds = (10^(-As/20));%parámetro de desviasión (banda de rechazo).
    
    F = [Fpb Fsb]; %vector de frecuiencia (banda pasante y de rechazo).
    A = [1 0]; %parámetro de amplitudes deseadas en (pb % sb).
    DEV = [dp ds]; %vector de parámetros de desviación.
    
    [N,Fo,Ao,W] = firpmord(F,A,DEV,Fs); %N=190
    filtroB = firpm(N,Fo,Ao,W);
    xF=filter(filtroB,1,x);
    xD=resample(xF,P,Q);
end


Fp11=lowcut(1);  Fst11 = Fp11-60;
Fp22=highcut(1); Fst22 = Fp22+60;
Ap=2;
Ast1=40;
Ast2=40;
Hf = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst11,Fp11,Fp22,Fst22,Ast1,Ap,Ast2,16000);
H1= design(Hf,'equiripple');
b1= H1.numerator;
N=length(H1.numerator);
filtros={};
filtros{1}=b1;

for i=2:15
    
    Fp1=lowcut(i);  Fst1 = Fp1-60;
    Fp2=highcut(i); Fst2 = Fp2+60;
    
    Hf = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2,16000);
    H= design(Hf,'equiripple');
    b= H.numerator;
    
    filtros{i}=b;
    
end