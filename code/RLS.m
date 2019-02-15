%filter parameters 
clear all

M   = 20                     ; % length of the filter
wo  = fir1(M-1,0.2)'         ; % optimal filter coefficients
sigv= 0.01                   ; % observation noise variance
sigu= 1                      ; % variance of the white input signal
Ru  = sigu*eye(M)            ; % correlation matrix
rud = Ru*wo                  ; % cross-correlation vector
sigd= sigv+wo'*Ru*wo         ; % power of the desired signal
Jwo = sigv                   ; % minimum of the cost function
% simulation parameters
N   = 10000                  ; % number of iterations
% parameters of the adaptive filter
w   = zeros(M,N+1)           ; % estimated filter coefficients
e   = zeros(1,N)             ; % errors
y   = zeros(1,N)             ; % output of the filter

Leff= 500                    ; % effective window length
lamda = 1-1/Leff               ; % forgetting factor

del = sigu                   ; % variance of initial correlation matrix
P   = eye(M)/del             ; % P(0)

wn   = sqrt(sigu)*randn(1,N+M-1); % white gaussian noise
u   = flipud(hankel(wn(1:M),wn(M:N+M-1))); %matrix of input vectors
z   = filter(wo,1,wn)         ; % create noiseless desired signal
d   = z(M:N+M-1)+sqrt(sigv)*randn(1,N); % desired vector

for n=1:N
pe       = P*u(:,n);
k        = pe/(lamda+u(:,n)'*pe);
e(n)     = d(n)-(u(:,n)'*w(:,n));
w(:,n+1) = w(:,n)+k*e(n);
P        = (P-k*pe')/lamda;
y(n)     = u(:,n)'*w(:,n);

%   pe        = P*u(:,n); 
%   k         = pe/(lamda+u(:,n)'*pe); 
%   e(n)      = d(n)-u(:,n)'*w(:,n); 
%   w(:,n+1)  = w(:,n)+k*e(n); 
%   P         = (P-k*pe')/lamda;
%   y(n)      = u(:,n)'*w(:,n);
end




subplot(3,1,1);
plot(1:N,[d;y;e]);
legend('Desired','Output','Error');
title('System Identification of FIR Filter');
xlabel('Time Index'); ylabel('Signal Value');
subplot(2,1,2);
stem([wo, w(:,N+1)]);
legend('Actual','Estimated'); grid on;
xlabel('Coefficient #'); ylabel('Coefficient Value'); 