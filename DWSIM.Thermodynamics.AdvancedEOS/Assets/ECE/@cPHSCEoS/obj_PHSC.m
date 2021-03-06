function [result EoS] = obj_PHSC(Z,EoS,T,P,mix)
%Objective function for the calculation of compressibility coefficient with
%PHSC-EoS
%Auxiliary function, not to be used directly
%
%Reference: Favari et al., Chem. Eng. Sci. 55 (2000) 2379-2392

%Copyright (c) 2011 �ngel Mart�n, University of Valladolid (Spain)
%This program is free software: you can redistribute it and/or modify
%it under the terms of the GNU General Public License as published by
%the Free Software Foundation, either version 3 of the License, or
%(at your option) any later version.
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%You should have received a copy of the GNU General Public License
%along with this program.  If not, see <http://www.gnu.org/licenses/>.

%Constants
a1 = 1.8681;	
a2 = 0.0619;
a3 = 0.6715;
a4 = 1.7317;
b1 = 0.7303;
b2 = 0.1649;
b3 = 0.2697;
b4 = 2.3973;

kb = 1.38048e-23; %Boltzmann constant (J/K)
R = 8.31; %Gas constant (J/K)
Na = 6.022e23; %Avogadro No

%Number density
dens = P/(Z*kb*T);

%Calculates sigma and epsilon for each component from V, A and E
numC = mix.numC;
sigma = zeros(numC,1);
r = zeros(numC,1);
epsilon = zeros(numC,1);
for i = 1:numC
    V = mix.comp(i).EoSParam(1);
    A = mix.comp(i).EoSParam(2);
    E = mix.comp(i).EoSParam(3);
    
    sigma(i) = 6*V/A; 
    r(i) = A/(pi*sigma(i)^2*Na);
    epsilon(i) = E/(r(i)*R);
end
k = mix.k1;
x = mix.x;

%Mixing rules for sigma and epsilon
sigmaij = zeros(numC,numC);
epsilonij = zeros(numC,numC);
for i =1:numC
    for j = 1:numC
        sigmaij(i,j) = 0.5*(sigma(i) + sigma(j)); %Eq. 17 of reference
        epsilonij(i,j) = sqrt(epsilon(i)*epsilon(j)) * (1 - k(i,j)); %Eq. 18 of reference       
    end
end

%Pure component parameters a and b
a = zeros(numC,1);
b = zeros(numC,1);
for i = 1:numC
    Fa = a1*exp(-a2*(T/epsilon(i)))+a3*exp(-a4*(T/epsilon(i))^1.5); %Eq. 4 of reference
    Fb = b1*exp(-b2*(T/epsilon(i))^0.5)+b3*exp(-b4*(T/epsilon(i))^1.5); %Eq. 5 of reference
    
    a(i) = (2*pi/3)*sigma(i)^3*epsilon(i)*kb*Fa; %Eq. 2 of reference
    b(i) = (2*pi/3)*sigma(i)^3*Fb; %Eq. 3 of reference       
end

%Mixture parameters aij and bij
aij = zeros(numC,numC);
bij = zeros(numC,numC);
for i = 1:numC
    for j = 1:numC
        Fa = a1*exp(-a2*(T/epsilonij(i,j)))+a3*exp(-a4*(T/epsilonij(i,j))^1.5); %Eq. 4 of reference
        Fb = b1*exp(-b2*(T/epsilonij(i,j))^0.5)+b3*exp(-b4*(T/epsilonij(i,j))^1.5); %Eq. 5 of reference

        aij(i,j) = (2*pi/3)*sigmaij(i,j)^3*epsilonij(i,j)*kb*Fa; %Eq. 15 of reference
        bij(i,j) = (2*pi/3)*sigmaij(i,j)^3*Fb; %Eq. 16 of reference
    end
end

%Packing fraction
nu = 0;
for i = 1:numC
    nu = nu + x(i)*r(i)*b(i);    
end
nu = nu*dens/4; %Eq. 20 of reference

%Function g(d+)
aus_ix = 0;
for i = 1:numC
    aus_ix = aus_ix + x(i)*r(i)*b(i)^(2/3);    
end
aus_ix = aus_ix*dens/4;

ix = zeros(numC,numC);
for i = 1:numC
    for j = 1:numC
        ix(i,j) = (b(i)*b(j)/bij(i,j))^(1/3)*aus_ix; %Eq. 21 of reference       
    end
end

g = zeros(numC,numC);
for i = 1:numC
    for j = 1:numC
        g(i,j) = 1/(1 - nu) + 3/2 * ix(i,j)/(1 - nu)^2 + 1/2 * ix(i,j)^2/(1 - nu)^3; %Eq. 19 of reference       
    end
end

%**********************************************************************
%Objective function
%**********************************************************************

%Reference term
ref_1 = 0;
ref_2 = 0;
for i = 1:numC
    for j = 1:numC
        ref_1 = ref_1 + x(i)*x(j)*r(i)*r(j)*bij(i,j)*g(i,j);
    end
end
ref_1 = ref_1 * dens;
for i = 1:numC
    ref_2 = ref_2 + x(i)*(r(i) - 1)*(g(i,i) - 1);    
end
Z_ref = 1 + ref_1 - ref_2; %Eq. 14 of reference

%Perturbation term
per = 0;
for i = 1:numC
    for j = 1:numC
        per = per + x(i)*x(j)*r(i)*r(j)*aij(i,j);        
    end
end
Z_pert = -per * dens/(kb*T); %Eq. 14 of reference

result = (Z - (Z_ref + Z_pert));
