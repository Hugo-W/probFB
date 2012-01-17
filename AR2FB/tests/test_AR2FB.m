function test_suite = test_AR2FB
  initTestSuite;

% Tests: 
%
% function [X,covX] = AR2FB(y,Lam,Var,vary,verbose,KF)
%

function testTwoStepComputeByHand

% Two time-step example which can be computed by hand

dispFig = 0;

T = 2;
D = 1;
K = 2;

lam = 0.9;
Lam = [lam,0];
Var = 1.4;
vary = 0.02;

autoCor = Var/(1-lam^2)*[1,lam];
tiny = 1e-10;


x0 = zeros(K,1);
P0 = [autoCor(1),autoCor(2);autoCor(2),autoCor(1)];
A = [lam,0;
     1,0];
C = [1,0];
Q = [Var,0;
     0,tiny];

R = vary; 
Y = randn([1,D,T]);

Y0 = squeeze(Y(1,:,1))';
Y1 = squeeze(Y(1,:,2))';

pre = [inv(P0)+A'*inv(Q)*A+C'*inv(R)*C,-A'*inv(Q);
       -inv(Q)*A,inv(Q)+C'*inv(R)*C];

muPre = [x0'*inv(P0)+Y0'*inv(R)*C,Y1'*inv(R)*C]';

sigmaPost = inv(pre);
muPost = sigmaPost*muPre;

Xfin1 = reshape(muPost,[1,K,T]);

Pfin1 = zeros(K,K,T);
Pfin1(:,:,1) = sigmaPost(1:K,1:K);
Pfin1(:,:,2) = sigmaPost(K+1:2*K,K+1:2*K);

% lik1 = -1/2*log(det(2*pi*P0))-1/2*log(det(2*pi*Q)) ...
%        -log(det(2*pi*R))+1/2*log(det(2*pi*sigmaPost)) ...
%        -1/2*Y0'*inv(R)*Y0-1/2*Y1'*inv(R)*Y1 ...
%        -1/2*x0'*inv(P0)*x0 + 1/2*muPost'*inv(sigmaPost)*muPost;

% Ptsum_1 = Pfin1(:,:,1)+Pfin1(:,:,2)+...
% 	  Xfin1(1,:,1)'*Xfin1(1,:,1)+Xfin1(1,:,2)'*Xfin1(1,:,2);

% YX_1 = Y(1,:,1)'*Xfin1(1,:,1)+Y(1,:,2)'*Xfin1(1,:,2);

% A1_1 = Xfin1(1,:,2)'*Xfin1(1,:,1)+sigmaPost(K+1:2*K,1:K);
% A2_1 = Pfin1(:,:,1)+ Xfin1(1,:,1)'*Xfin1(1,:,1);
% A3_1 = Pfin1(:,:,2)+ Xfin1(1,:,2)'*Xfin1(1,:,2);

X1 = reshape(Xfin1(1,1,:),[1,T]);
covX1 = reshape(Pfin1(1,1,:),[1,1,T]);

[X2,covX2] = AR2FB(Y(:),Lam,Var,vary);

tol = 1e-5;

assertVectorsAlmostEqual(X1,X2,'absolute',tol,0)
assertVectorsAlmostEqual(covX1,covX2,'absolute',tol,0)

% assertVectorsAlmostEqual(lik1,lik2,'absolute',tol,0)
% assertVectorsAlmostEqual(Ptsum_1,Ptsum_2,'absolute',tol,0)
% assertVectorsAlmostEqual(YX_1,YX_2,'absolute',tol,0)
% assertVectorsAlmostEqual(A1_1,A1_2,'absolute',tol,0)
% assertVectorsAlmostEqual(A2_1,A2_2,'absolute',tol,0)
% assertVectorsAlmostEqual(A3_1,A3_2,'absolute',tol,0)



function testTwoStepComputeByHandFiltering

% Two time-step example which can be computed by hand for a
% filtering example

dispFig = 0;

T = 2;
D = 1;
K = 2;

lam = 0.9;
Lam = [lam,0];
Var = 1.4;
vary = 0.02;

autoCor = Var/(1-lam^2)*[1,lam];
tiny = 1e-10;


x0 = zeros(K,1);
P0 = [autoCor(1),autoCor(2);autoCor(2),autoCor(1)];
A = [lam,0;
     1,0];
C = [1,0];
Q = [Var,0;
     0,tiny];

R = vary; 
Y = randn([1,D,T]);

Y0 = squeeze(Y(1,:,1))';
Y1 = squeeze(Y(1,:,2))';

pre = [inv(P0)+A'*inv(Q)*A+C'*inv(R)*C,-A'*inv(Q);
       -inv(Q)*A,inv(Q)+C'*inv(R)*C];

muPre = [x0'*inv(P0)+Y0'*inv(R)*C,Y1'*inv(R)*C]';

sigmaPostKS = inv(pre);
muPostKS = sigmaPostKS*muPre;

sigmaPostKF = inv(inv(P0)+C'*inv(R)*C);
muPostKF = sigmaPostKF*(x0'*inv(P0)+Y0'*inv(R)*C)';

Xfin1 = zeros(1,K,T);
Xfin1(1,:,1) = reshape(muPostKF,[1,K,1]);
Xfin1(1,:,2) = reshape(muPostKS(K+1:2*K),[1,K,1]);

Pfin1 = zeros(K,K,T);
Pfin1(:,:,1) = sigmaPostKF;
Pfin1(:,:,2) = sigmaPostKS(K+1:2*K,K+1:2*K);

X1 = reshape(Xfin1(1,1,:),[1,T]);
covX1 = reshape(Pfin1(1,1,:),[1,1,T]);

[X2,covX2] = AR2FB(Y(:),Lam,Var,vary,0,1);

% NOT YET IMPLEMENTED
% lik1 = -1/2*log(det(2*pi*P0))-1/2*log(det(2*pi*Q)) ...
%        -log(det(2*pi*R))+1/2*log(det(2*pi*sigmaPostKS)) ...
%        -1/2*Y0'*inv(R)*Y0-1/2*Y1'*inv(R)*Y1 ...
%        -1/2*x0'*inv(P0)*x0 + 1/2*muPostKS'*inv(sigmaPostKS)*muPostKS;

% Not yet implement sufficient statistic computation for Kalman
% filtering:

% Ptsum_1 = Pfin1(:,:,1)+Pfin1(:,:,2)+...
% 	  Xfin1(1,:,1)'*Xfin1(1,:,1)+Xfin1(1,:,2)'*Xfin1(1,:,2);

% YX_1 = Y(1,:,1)'*Xfin1(1,:,1)+Y(1,:,2)'*Xfin1(1,:,2);

% A1_1 = Xfin1(1,:,2)'*Xfin1(1,:,1)+sigmaPost(K+1:2*K,1:K);
% A2_1 = Pfin1(:,:,1)+ Xfin1(1,:,1)'*Xfin1(1,:,1);
% A3_1 = Pfin1(:,:,2)+ Xfin1(1,:,2)'*Xfin1(1,:,2);

tol = 1e-5;
assertVectorsAlmostEqual(X1,X2,'absolute',tol,0)
assertVectorsAlmostEqual(covX1,covX2,'absolute',tol,0)

%assertVectorsAlmostEqual(Xfin1(:),Xfin2(:),'absolute',tol,0)
%assertVectorsAlmostEqual(Pfin1(:),Pfin2(:),'absolute',tol,0)
% assertVectorsAlmostEqual(Ptsum_1,Ptsum_2,'absolute',tol,0)
% assertVectorsAlmostEqual(YX_1,YX_2,'absolute',tol,0)
% assertVectorsAlmostEqual(A1_1,A1_2,'absolute',tol,0)
% assertVectorsAlmostEqual(A2_1,A2_2,'absolute',tol,0)
% assertVectorsAlmostEqual(A3_1,A3_2,'absolute',tol,0)


function testMultiStepRuns

% Test the function returns the true variables when the observation
% noise is zero and the data are sampled from the model

 T = 100;
 D = 1;
 K = 1;

 %Lam = [1.5,-0.9;
 %       1.9,-0.95];
 %Var = [1,0.5];

 Lam = [1.5,-0.9];
 Var = [1];

 vary = 1e-6;
 
x1 = sampleARTau(Lam(1,:),Var(1),T,1);
Y = x1';
%x2 = sampleARTau(Lam(2,:),Var(2),T,1);
%Y = (x1+x2)';

[X,covX] = AR2FB(Y,Lam,Var,vary);

% figure
% subplot(2,1,1)
% hold on
% plot(X(1,:),'-r','linewidth',2)
% plot(x1,'-b')

% subplot(2,1,2)
% hold on
% plot(X(2,:),'-r')
% plot(x2,'-b')

tol = 1e-3;
assertVectorsAlmostEqual(x1(:),X(:),'absolute',tol,0)


