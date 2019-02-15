clear all
clc

% Read audio

% noise:
[d,fs1] = audioread('Noise.wav') ;
% Signal
[x,fs1] = audioread('Music.wav') ;
% Noisy signal
[u_in,Fs] = audioread('Noisy_Music.wav') ;

N = length(u_in) ;
% Filter Order:
M = 12 ;

% *************************************************************************
% *************************************************************************
% *************************************************************************







% % LMS
% tic
% mu = 0.01 ;
% w = randn(M,1) ;
% padded_u = [zeros(M-1,1) ; u_in] ;
% y = zeros(N,1) ;
% for n=1:round(N)
%     u_vect = padded_u(n:n+M-1) ;
%     e = d(n) - w'*u_vect ;
%     w = w + mu*e*u_vect ;
%     y(n) = w'*u_vect ;
% end
% 
% % y2 = [zeros(sampleDelay,1) ; y] ;
% filtered_signal_LMS = u_in - y ;
% toc


% *************************************************************************

% % NLMS
% tic
% mu = 1 ;
% w = randn(M,1) ;
% padded_u = [zeros(M-1,1) ; u_in] ;
% y = zeros(N,1) ;
% Eps = 0.0001 ;
% for n=1:round(N)
%     u_vect = padded_u(n:n+M-1) ;
%     mu1 = mu/(Eps + norm(u_vect)^2) ;
%     %norm(u_vect)^2
%     e = d(n) - w'*u_vect ;
%     w = w + mu1*e*u_vect ;
%     y(n) = w'*u_vect ;
% end
% 
% % y2 = [zeros(sampleDelay,1) ; y] ;
% filtered_signal_NLMS = u_in - y ;
% toc


% *************************************************************************

% RLS my:


M   = 20                     ; % length of the filter
% wo  = fir1(M-1,0.2)'         ; % optimal filter coefficients
% sigv= 0.01                   ; % observation noise variance
% sigu= 1                      ; % variance of the white input signal
% Ru  = sigu*eye(M)            ; % correlation matrix
% rud = Ru*wo                  ; % cross-correlation vector
% sigd= sigv+wo'*Ru*wo         ; % power of the desired signal
% Jwo = sigv                   ; % minimum of the cost function
% simulation parameters
% N   = 10000                  ; % number of iterations
% % parameters of the adaptive filter
% w   = zeros(M,N+1)           ; % estimated filter coefficients
% e   = zeros(1,N)             ; % errors
% y   = zeros(1,N)             ; % output of the filter
% 
% Leff= 500                    ; % effective window length
% lamda = 1-1/Leff               ; % forgetting factor
% 
% del = 0.01; %sigu                   ; % variance of initial correlation matrix
% P   = eye(M)/del             ; % P(0)
% 
% wn   = sqrt(sigu)*randn(1,N+M-1); % white gaussian noise
% u   = flipud(hankel(wn(1:M),wn(M:N+M-1))); %matrix of input vectors
% z   = filter(wo,1,wn)         ; % create noiseless desired signal
% d   = z(M:N+M-1)+sqrt(sigv)*randn(1,N); % desired vector

% % RLS:
 lambda = 0.9 ;%1 - 1/(0.1*M) ;
 delta = 0.01 ;
 P = 1/delta*eye(M) ;
 w = randn(M,1) ;
 padded_u = [sqrt(delta)*randn(M-1,1) ; u_in] ;
 y = zeros(N,1) ;
u   = flipud(hankel(padded_u(1:M),padded_u(M:N+M-1))); %matrix of input vectors
 
for n=1:N
    % RLS
    
    pe       = P*u(:,n);
    k        = pe/(lambda+u'*pe);
    e(n)     = d(n)-(u'*w);
    w = w+k*e(n);
    P        = (P-k*pe')/lambda;
    y(n)     = u'*w(:,n);
    
    
%     u_vect = padded_u(n:n+M-1) ;
%     
%     
%     PI = P*u_vect ;
%     gain_k = PI/(lambda + u_vect'*PI) ;
%     prior_error = d(n) - w'*u_vect ;
%     w = w + prior_error*gain_k ;
%     P = P/lambda - gain_k*(u_vect'*P)/lambda ;
%     y(n) = w'*u_vect ;
end
% y1 = [zeros(sampleDelay,1) ; y] ;
filtered_signal = u_in - y ;
toc

soundsc(filtered_signal,fs1)
