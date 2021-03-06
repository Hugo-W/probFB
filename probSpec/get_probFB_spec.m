function spec = get_probFB_spec(lamx,varx,om,vary,T)
  
  % spec = get_probFB_spec(lamx,varx,om,vary,T)
  %
  % 
  % Probabilistic Filter Bank (see Turner 2010, Chapter 5 for details)
  %
  % Implemented using the FFT - fast but only returns the means and
  % cannot handle non-stationary noise.
  %
  % INPUTS
  % lamx = dynamical AR parameters [D,1]
  % varx = dynamical noise parameters [D,1]
  % om = mean frequencies of the sinusoids [D,1]
  % vary = oberservation noise
  % T = number of fft coefficients to return
  %  
  % OUTPUTS
  % spec = probabilistic filter bank fft values, size [T,D]
  %
  
RngFreqs = [0,1/2];
D = length(varx);

% % DETERMINE PADDING BASED ON LONGEST TIME-CONSTANTS OF Xs
% tol = 3;
% tau = max(ceil(2*pi*tol./om));
% Tx = 2^ceil(log2(T+tau)); % make a power of two so fft is fast
Tx = T;

% GET THE SPECTRA OF THE COMPONENTS AND THE DATA
specX = zeros(Tx,D);
specY = vary*ones(Tx,1);

for d=1:D
    
  delta = 1/Tx;	
  [Freqs1,spec1] = getCompSpecPFB(lamx(d),varx(d),-om(d),Tx/2+1,[0,1/2]);  

  [Freqs2,spec2] = getCompSpecPFB(lamx(d),varx(d),-om(d),Tx/2-1,[-1/2+ ...
		    delta,-delta]);  

  % This is round the houses but it wraps the spectrum correctly
  specX(:,d) = [spec1,spec2]';

  specY = specY+(specX(:,d)+specX([1,[Tx:-1:Tx/2+1],[Tx/2:-1:2]],d))/2;
  %specY = specY+[spec1,spec1(end-1:-1:2)]'/2;
  
end

% USE THE SPECTRA TO FILTER THE SIGNAL

% edges have to be handled heuristically as they are effectively
% non-stationary

%dT = Tx-T;

% linearly interpolate the extra chunk
%yExtra = linspace(y(end),y(1),dT)';


%yFFT = fft([y(:);yExtra]);
%yFFT

spec = zeros(Tx,D);

for d=1:D

    spec(:,d) = specX(:,d)./specY;
  
end

