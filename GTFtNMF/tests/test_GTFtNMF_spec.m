function test_suite = test_GTFtNMF_spec
  initTestSuite;

% Tests: 
%
% [W,H,mnV,covV,info] = GTFtNMF_spec(y,W,H,lamv,varv,omv,vary,lenx,mux,varx,varargin)
%

function test_likelihood_increases

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Forward model Settings

T = 101;
D = 5;
K = 3;

mux = [1,1,1];
varx = [3,3,3];
lenx = [10,20,30];

W = [1/3,0,1/3,0,1/3;
     0,1/3,0,2/3,0;
     1/3,1/3,1/3,0,0];

lamv  = ones(1,D)*0.995;
varv  = (1-lamv.^2);
omv = linspace(pi/4,pi/30,D);

vary = 1e-3;
tol = 11;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST
[y,V,H,Z] = randGTFtNMF(W,lamv,varv,omv,vary,lenx,mux,varx,tol,T);

A = sqrt(1/2*H*W);

HInit = exp(randn(T,K));
WInit = rand(K,D);

lamvInit  = ones(1,D)*0.9;
varvInit  = (1-lamvInit.^2);
omvInit = linspace(pi/10,pi/20,D);

% [WEst,HEst,lamvEst,varvEst,omvEst,mnV,covV,info] = GTFtNMF_train_spec(y, ...
% 						  WInit,HInit,lamvInit, ...
% 						  varvInit,omvInit,vary, ...
% 						  lenx,mux,varx);


[WEst,HEst,mnV,covV,info] = GTFtNMF(y,WInit,HInit,lamvInit,varvInit,omvInit,vary, ...
				       lenx,mux,varx);

[WEst,HEst,lamvEst,varvEst,omvEst,mnV,covV,info] = GTFtNMF_train_spec(y, ...
						  WEst,HEst,lamvInit, ...
						  varvInit,omvInit,vary, ...
						  lenx,mux,varx);

keyboard
tol = 1e-4;
assertVectorsAlmostEqual(sum(diff(info.lik)<0),0,'absolute',tol,0)


% alternative likelihood computation using EM objective
AEst = sqrt(1/2*HEst*WEst);
[likAlt,VV,RVV] = kalman_GTFtNMF_FB_hier_EM(y,AEst',lamvEst,varvEst,omvEst,vary);
likAlt = (likAlt-1/2*sum(info.Z(:).^2))/T; 
assertVectorsAlmostEqual(likAlt,info.lik(end),'absolute',tol,0)

% for d=1:D
%   figure
%   hold on
%   plot(real(V(:,d)),'-k')
%   plot(A(:,d),'-r','linewidth',2)
%   plot(AEst(:,d),'-b','linewidth',2)
% end

% figure
% hold on
% title('spectrum of y')
% specy = abs(fft(y));
% plot(specy(1:T/2))

% figure
% plot(info.Obj)

% figure
% for k=1:K
%   subplot(K,1,k)
%   hold on
%   plot(H(:,k),'-k')
%   plot(HEst(:,k),'-r')
%   set(gca,'yscale','log')
% end

% figure
% subplot(2,1,2)
% imagesc(WEst)

% subplot(2,1,1)
% imagesc(W)

% keyboard