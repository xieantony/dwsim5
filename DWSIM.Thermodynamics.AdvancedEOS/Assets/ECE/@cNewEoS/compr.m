function [Z EoS] = compr(EoS,T,P,mix,phase,varargin)
%Calculation of the compressibility coefficient with a new equation of
%state overloading the method of the base IdealEoS class
%Implement here the code for calculating the compressibility coefficient
%
%Parameters:
%EoS: Equation of state used for calculations
%T: Temperature(K)
%P: Pressure (Pa)
%mix: cMixture object
%phase: set phase = 'liq' to get the coefficient of the liquid phase, phase = 'gas'  
%   to get the coefficient of the gas phase 
%
%Results:
%Z: compresibility coefficient
%EoS: returns EoS used for calculations

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

Z = 1;