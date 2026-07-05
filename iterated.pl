% -*- Mode: Prolog -*-
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   File name iterated.pl
   Iterated functions simulation in prolog
   
   1. first install swi-prolog 
   2. in a terminal, "swipl iterated.pl"
   3. welcome message give you some information
   4. start eclipse with PDT.. or other since it dont work anymore..
   5. start emacs editors in a terminal with 
        env HOME=/home/pascal/ellipse_perimeter emacs iterated.pl
        it has several other files in /home/pascal/ellipse_perimeter..
        - .emacs
        - ediprolog.el
        - etrace.el
        - prolog.el
   
   It show the values of typical iterated infinite functions 
     f(f(f(..))) with high convergence between 2 poles

   No infinite series (with sometimes unknown outcome) listed
   
   https://en.wikipedia.org/wiki/Mean_value_theorem
   https://en.wikipedia.org/wiki/Mean_value_theorem_(divided_differences)
   https://en.wikipedia.org/wiki/Divided_differences

   next.. 
   
   change all to pom(X,Y,P,Res,Action) :-
     Action = "Doc" then outpout the doc
     Action = "Cal" then output the calculation
   dont show 1 when test_mean1 with N=20..100 .. change from YStep into YStart+(YEnd-YStart)/Ncurrent.. precision improvement
   test agags..
   beta function as gagm  https://en.wikipedia.org/wiki/Beta_function
   introduce imaginary numbers within the iterations (not (x,y) but z=x+iy)
   inverse function of generalized geometric mean function f-1((f(a)f(b))^ 1 durch n )
   inverse lambert similar to mean of xlog(x)
   power mean of order r with z and exponent
   3 poles
   is the Gelfond constant the result of a 2 pole iteration  https://en.wikipedia.org/wiki/Gelfond%27s_constant
   Lambert  https://www.uwo.ca/apmaths/faculty/jeffrey/pdfs/W-adv-cm.pdf
   e as convergence of means  http://numbers.computation.free.fr/Constants/E/e.html
   implement  https://en.m.wikipedia.org/wiki/Borwein%27s_algorithm
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
% 
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   PROLOG libraries
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
% :- use_module(library(clpfd)).
%
/*------------------------------------------------------------------------------
   activate debugging ; comment this out after testing phase or during use
   https://www.swi-prolog.org/pldoc/man?section=debugger
   use:
   trace.  >> start the tracing then return return ..
   n       >> cont without debug
------------------------------------------------------------------------------*/
:- debug.
%
/*------------------------------------------------------------------------------
   show an introduction
------------------------------------------------------------------------------*/
%
:- initialization (welcome).
%
/*------------------------------------------------------------------------------
   diverse facts for the different used formats for drawing lines
   look at file hp41modconf.pl or create a common separate file
------------------------------------------------------------------------------*/
%
format_used(line80,Format_out) :- 
	atomics_to_string(["~`","\u2500","t","~s","~80|~n"],Format_out).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   general words
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
/* exit :- 
    halt(0).
leave :- 
    halt(0).
bye :- 
    halt(0). */
%
:- consult('/home/pascal/programming/prolog/general.pl').
%
/*------------------------------------------------------------------------------
   main explanation scripts
------------------------------------------------------------------------------*/
%
% started via initialization for the main menue
%
welcome :-
    	nl,
    	nl,
    	format_used(line80,F1),
 	format(F1,['\u2500']),
 	nl,
 	format(' Welcome to '),nl,
 	nl,
%  	format(F1,['\u2500']),
%    	nl,
    	format(' mean calculations ~n'),
    	format(' for identifying infinite iterations within fixed boundaries ~n'),
    	format(' then for high speed convergence (like AGM) ~n'),
    	nl,
    	format(F1,['\u2500']),
    	nl,
	format(' Feb 20, 2026                                                  ~n'),
	format(' pascaldagornet at yahoo dot de                                ~n'),
	format(' based on several math sources in wikipedia                    ~n'),
	format(' Copyright CC BY-NC-SA 4.0 ~n'),
	format(' https://creativecommons.org/licenses/by-nc-sa/4.0/ ~n'),
	format(' https://creativecommons.org/ ~n'),
	nl,
	format(F1,['\u2500']),
	nl,
	format(' recommendations for use interactively:                        ~n'),
	nl,
	format('   in a PC terminal give the letters within "" ~n'),
	nl,
	format('   "swipl"  then press the return key                          ~n'),
	format('   = it starts swipl (a swipl prompt ">" can be seen)          ~n'),
	format('   You can give following commands in the swipl prompt ">"     ~n'),
	format('   then press the return key each time after                   ~n'),
	format('   > consult(iterated).                                        ~n'),
	nl,
	format('   or "swipl /path/to/file/iterated.pl" directly in the terminal, \n   then commands below in the swipl prompt ~n'),
	nl,
	format('   > trace.            if debugger must be on for tracing      ~n'),
	format('   > howto.            show this text again                    ~n'),
%	format('   > ... however, more explained via the existing commands ... ~n'),
%	format('   > "list_commands."TBD show the available commands           ~n'),
	nl,
	format('   testing functionality implemented in the script:            ~n'),
	format('   > test_mean.                                                ~n'),
        format('   > test_mean1.                                               ~n'),
        format('   > createfile(''agm.dat'').                                  ~n'),
        format('   > plotfile(''agm.dat'').                                    ~n'),
	nl,	
	format(' EXIT option commands ~n > leave. ~n > exit. ~n > bye. ~n > halt(0).~n'),
	nl,
	format(' remarks:                                                      ~n'),
	format('   in testphase. Not for commercial use                        ~n'),
	format('   prototype for use at own risks                              ~n'),
	nl,
	format(F1,['\u2500']),
	nl,
	nl.
%
howto :- welcome.
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   special functions rewritten
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        complete elliptic integral of the first kind
	https://en.wikipedia.org/wiki/Elliptic_integral#Complete_elliptic_integral_of_the_first_kind
	release tbd
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
kprim(K,Res) :-
        K>1.0 -> Res is 0.0;
        Res is sqrt(1.0-K*K).
%
ka_integr(K,Res) :-
        kprim(K,Res1),
        agm(1.0,Res1,Res2),
        Res is pi/(2.0*Res2).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        theta functions
	https://en.wikipedia.org/wiki/Theta_function#Auxiliary_functions
        https://mathworld.wolfram.com/JacobiThetaFunctions.html
        https://arxiv.org/pdf/1502.04603
	release tbd
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%theta(Z,Qu,Res) :-
%        ka_integr(
%        Res is exp(-pi).
%
% test
%?- qu_of_theta(1.0,1.0,Res).
%Res = 0.0.
%
qu_of_theta(In,K,Res) :-
        KIn is In*K,
	( KIn=1.0 -> Res is 0.0;
        kprim(KIn,KPrm),
        agm(1.0,KIn,Res1),
        agm(1.0,KPrm,Res2),
        Res is exp(-pi*Res1/Res2)).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        special function for new algebra
	release tbd
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
ru(In,K,Res) :-
        KIn is In*K,
	( KIn=1.0 -> Res is 0.0;
        agm(1.0,KIn,Res1),
        Res is exp(-pi*(1.0/Res1 - 1.0)) ).
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	seiffert-transform
	release 22 April 2024
        origin? link?
	will make
	.. G (gm) -> A (PowerMean order r)
	.. A -> Q (rms2)
	.. P (1st seiffert) -> T (2nd seiffert)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
seiftr(A,B,ResA,ResB) :-
	ResA is ((sqrt(2*(A**2+B**2))+A-B)/2.0),
	ResB is ((sqrt(2*(A**2+B**2))-A+B)/2.0).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   power mean  
   more a generic mean function covering several mean functions
   release 23.04.2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
pom(X,Y,P,Res) :- 
	X=Y -> Res is X; 
	X=0.0,P =\=0.0 -> Res is exp((1.0 /P)*log((exp(P*log(Y)))/2.0)); 
	Y=0.0,P =\=0.0 -> Res is exp((1.0 /P)*log((exp(P*log(X)))/2.0));
    	P= -1.0 -> hm(X,Y,Res);
	P=0.0 -> gm(X,Y,Res);
	P=1.0 -> am(X,Y,Res);
	P=2.0 -> rms2(X,Y,Res);		
	P=3.0 -> cm(X,Y,Res);  
	Res is exp((1.0 /P)*log(((exp(P*log(X))) + (exp(P*log(Y))))/2.0)).	
	%
pom1_2(X,Y,Res) :- P is 1.0/2.0, pom(X,Y,P,Res).
pom1_3(X,Y,Res) :- P is 1.0/3.0, pom(X,Y,P,Res).
pom4_3(X,Y,Res) :- P is 4.0/3.0, pom(X,Y,P,Res).
pom2_3(X,Y,Res) :- P is 2.0/3.0, pom(X,Y,P,Res).
pom5_3(X,Y,Res) :- P is 5.0/3.0, pom(X,Y,P,Res).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   heinz mean from  https://en.wikipedia.org/wiki/Heinz_mean
   logarithmic type, between am and gm; use tbd
   generic mean function
   release 29 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
hem(A,B,X,Res) :- 
	X =< 0.5, X >= 0.0,!,
	(	X=0.0 -> am(A,B,Res);
		X=0.5 -> gm(A,B,Res);
		A=0.0 -> Res is 0.0;
		B=0.0 -> Res is 0.0;
		Res is (((exp(X*log(A))*exp((1.0-X)*log(B)))+(exp((1.0-X)*log(A))*exp(X*log(B))))/2.0)
	).
hem(A,B,X,Res) :- 
	Res is (((exp(X*log(A))*exp((1.0-X)*log(B)))+(exp((1.0-X)*log(A))*exp(X*log(B))))/2.0),
	format('~toutside of usual use [0.0 .. 0.5]~n').
/*
% hem(1.0,2.0,9.0,Res).
% outside of usual use [0.0 .. 0.5]
% Res = 256.001953125.
%
% hem(1.0,2.0,2.0,Res).
% outside of usual use [0.0 .. 0.5]
% Res = 2.25.
%
% hem(1.0,2.0,1.0,Res).
% outside of usual use [0.0 .. 0.5]
% Res = 1.5.
%
% hem(1.0,2.0,0.0,Res).
% Res = 1.5.
%
% hem(1.0,2.0,-9.0,Res).
% outside of usual use [0.0 .. 0.5]
% Res = 512.0009765625.
*/
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Hölder Mittel  https://de.wikipedia.org/wiki/H%C3%B6lder-Mittel
   more a generic mean function covering several mean functions
   release 03 Feb 2026
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
hoelm(X,Y,P,Res) :-
	X=0.0, Y=0.0 -> Res is 0.0,!;
        P= -1.0 -> hm(X,Y,Res);
	P=0.0 -> gm(X,Y,Res);
	P=1.0 -> am(X,Y,Res);
	P=2.0 -> rms2(X,Y,Res);
	P=3.0 -> cm(X,Y,Res);		 
	X > 0.0, Y > 0.0, Res is exp((1.0 / P)*log((exp(P*log(X)) + exp(P*log(Y)))/2.0 ));
	X=0.0 -> Res is exp((1.0 / P)*log(exp(P*log(Y))/2.0 ));
	Y=0.0 -> Res is exp((1.0 / P)*log(exp(P*log(X))/2.0 )).
%
hoelm0_5(X,Y,Res) :- P is 0.5, hoelm(X,Y,P,Res),!.     % = pom1_2
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   stolarsky mean  https://en.wikipedia.org/wiki/Stolarsky_mean
   logarithmic type
   more a generic mean function covering several mean functions
   release 29 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
stom(X,Y,P,Res) :-
	X=Y -> Res is X;
	P= -1.0 -> gm(X,Y,Res);
	P=0.0 -> lm(X,Y,Res);
        P=0.5 -> hoelm0_5(X,Y,Res);
	P=1.0 -> im(X,Y,Res);
	P=2.0 -> am(X,Y,Res);
	P=3.0 -> gm(X,Y,Res1),rms3(X,Y,Res1,Res);		 
	X=0.0 -> Res is exp((1.0 / (P - 1.0))*log((exp(P*log(Y)))/(P*Y))); 
	Y=0.0 -> Res is exp((1.0 / (P - 1.0))*log(((exp((P-1)*log(X)))/P))); 
	X > 0.0, Y > 0.0, Res is exp((1.0 / (P - 1.0))*log(((exp(P*log(X))) - (exp(P*log(Y))))/(P*(X-Y)))).
%
stom3(X,Y,Res) :- P is 3.0, stom(X,Y,P,Res).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Lehmer mean  
   https://en.wikipedia.org/wiki/Lehmer_mean with P deviation of 1
   >> https://files.ele-math.com/articles/jmi-04-51.pdf
   more a generic mean function covering several mean functions
   release 29 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
lehm(X,Y,P,Res) :-
	X=Y -> Res is X ;
	X=0.0 -> Res is Y;
	Y=0.0 -> Res is X;
	P= -1.0 -> hm(X,Y,Res);
	P= -0.5 -> gm(X,Y,Res);
	P=0.0 -> am(X,Y,Res);
	P=1.0 -> chm(X,Y,Res);
	Res is (exp((P+1)*log(X)) + exp((P+1)*log(Y)))/(exp(P*log(X)) + exp(P*log(Y))).
lehm1_3(X,Y,Res):- P is 1.0/3.0, lehm(X,Y,P,Res).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	nthroot according https://en.wikipedia.org/wiki/Nth_root#Computing_principal_roots
	for n=2, this is the heron method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots
	works for N as INTEGER value only (because use of mod)
	Positiv or Negative
	released 18 April 2024
	Update 11 Mai 2024	avoiding iteration starting with a Zero value	
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
/* test

?- nthroot(5.0,5,Res).
Res = 1.3797296614612147.

*/
%
nthroot_loop(A,_,Res,N) :-
	Rem is N mod 2, Rem =  0, A < 0.0 , Res is 0.0,format('~t the number to be squared should be positive ~4f ~n',[A]),!.
nthroot_loop(A,_,Res,_) :-
	A = 0.0 , Res is 0.0,!.
nthroot_loop(A,_,Res,_) :-
	A = 1.0 , Res is 1.0,!.
nthroot_loop(A,Iter1,Iter2,N) :-
	(	Iter1=0.0 
		-> 
		Iterzw is 99999999999.0,Iter2 is (((Iterzw*(N-1)) + (A/(Iterzw**(N - 1))))/N)
		;
		Iter2 is (((Iter1*(N-1)) + (A/(Iter1**(N - 1))))/N)
	),
	abs(Iter2-Iter1) < 1.0e-10,!.
nthroot_loop(A,Iter1,Res,N) :-
	( 	Iter1=0.0 
		-> 
		Iterzw is 99999999999.0,Iter2 is (((Iterzw*(N-1)) + (A/(Iterzw**(N - 1))))/N)
		;
		Iter2 is (((Iter1*(N-1)) + (A/(Iter1**(N - 1))))/N)
	),
%	Iter2 is (((Iter1*(N-1)) + (A/abs(Iter1**(N - 1))))/N),
	nthroot_loop(A,Iter2,Res,N).
%
nthroot(A,N,Res) :- Start is 1.0, nthroot_loop(A,Start,Res,N).
%
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   R S T from https://pca-pdmi.ru/2019/files/37/PCA2019SA_slides.pdf
   release tbd
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
%
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   gagm from https://semjonadlaj.com/SP/Computer+Algebra+in+Scientific+Computing_37-56.pdf
             https://pca-pdmi.ru/2022/files/16/PCA2022GAGM.pdf
   release tbd
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
gags_loop(_,_,_,_,Xm,Ym,_,_,Xm,IterM) :- 
	abs(Xm-Ym) < 1.0e-10,!,format('~t in ~2f ~t iterations ~n',[IterM]).
%
% now case at loop start.. which is redundant to the further calculation
gags_loop(_,UmA,UmB,UmC,Xm,Ym,_,_,Res,IterM) :- 
	IterM=0, 
	Res1 is (0.0 - sqrt(Xm*Ym)) ,
	UmC=Res1,
    	Res is (0.5 * ( 1.0 + (((UmA-UmB)-(Xm-Ym))/((UmA-UmB)*sqrt(Xm*Ym))))),!.
%
gags_loop(T,UmA,UmB,UmC,Xm,Ym,Zm,UmT,Res,IterM) :- 
	% MAGM sequence
	Xn is ((Xm+Ym)/2.0),
	Yn is (Zm + sqrt((Xm-Zm)*(Ym-Zm))),
	Zn is (Zm - sqrt((Xm-Zm)*(Ym-Zm))),
	% new functions sequences for iteration. UoT is the identity function T
	UnT is (((UmC*UmT)-(Yn*Zn))/(UmC+UmT-(2*Zm))),
	UnA is (((UmC*UmA)-(Yn*Zn))/(UmC+UmA-(2*Zm))),
	UnB is (((UmC*UmB)-(Yn*Zn))/(UmC+UmB-(2*Zm))),
	UnC is (((UmC*UmC)-(Yn*Zn))/(UmC+UmC-(2*Zm))),
    % 
    % generic functions non iterated
	VmT is ((T-UmA)/(T-UmC)),
	VmB is ((UmB-UmA)/(UmB-UmC)),
	WmT is (VmT/VmB),
	% Epsilon n
	VmXn is ((Xn-UmA)/(Xn-UmC)),
	WmXn is (VmXn/VmB),
	% Nano n
	VmYn is ((Yn-UmA)/(Yn-UmC)),
	WmYn is (VmYn/VmB),
	%
%	Res is Wn,
	format('~t Xn Yn Zn ~4f ~4f ~4f~n',[Xn,Yn,Zn]),
	format('~t UnA UnB UnC ~4f ~4f ~4f~n',[UnA,UnB,UnC]),
	format('~t WmXn WmYn T WmT ~4f ~4f ~4f ~4f~n~n',[WmXn,WmYn,T,WmT]),
%	write([Xn,Yn,Zn,WmT]),nl,
	!, IterN is IterM+1,
	gags_loop(T,UnA,UnB,UnC,Xn,Yn,Zn,UnT,Res,IterN).
%	
gagm(T,_,_,C,_,_,_) :- 
	T=C,
	format('~tIssue:~n'),
	format('~t  at start, C should not be equalt to T ~2f ~2f~n',[C,T]),!.
%
gagm(_,_,_,C,X,Y,_) :- 
	Max is max(X,Y), Min is min(X,Y), C > Min, C < Max ,
	format('~tIssue:~n'),
	format('~t  at start, C should not be in [X,Y] ~2f ~2f ~2f~n',[C,X,Y]),!.
%
gagm(T,A,B,C,X,Y,Res) :-
	%
	format('~t T A B C X Y  ~2f ~2f ~2f ~2f ~2f ~2f~n~n',[T,A,B,C,X,Y]),
	A=\=B,
	B=\=C,
	A=\=C,
	U0T is T,   % time linear function. Other functions?
	ZStart is 0.0,
	IterM is 0,
	gags_loop(T,A,B,C,X,Y,ZStart,U0T,Res,IterM).
%
gagm(_,A,B,C,_,_,_) :-
    	format('~tIssue:~n'),
	format('~t  at start, A or B or C should not be equal ~2f ~2f ~2f~n',[A,B,C]).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   =:= N from page noted 40 in https://semjonadlaj.com/SP/Computer+Algebra+in+Scientific+Computing_37-56.pdf
   release tbd
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
% only X
n(X,Res) :- X=0.0,Res is 0.0,!.
n(X,Res) :- magm(X,1.0,Res).
% page noted 41 in https://semjonadlaj.com/SP/Computer+Algebra+in+Scientific+Computing_37-56.pdf
% only X and 1 param
n(X,C,Res) :- C=0.0 , diff(X,0.0),Xn is 1/X, n(Xn,Res).
n(X,C,Res) :- A = 9999999999999999999.9 ,
			B is (C+1),!,n(X,A,B,C,Res).
n(X,A,B,C,Res) :- diff(X,0.0) , Xn is 1/X, diff(A,0.0),An is 1/A, diff(B,0.0),Bn is 1/B, diff(C,0.0),Cn is 1/C, !, n(Xn,An,Bn,Cn,Res).	
% B <> A		
n(X,A,B,C,Res) :- C=0.0 , diff(A,B), diff(X,0.0) , Xn is (1/X) , n(Xn,Res1) , Res is ((B*((A*Res1) -1.0)/(A-B))),!.
n(X,A,B,C,Res) :- diff(C,0.0), Cn is 1/C, Cn > 9999999999999999999.9  , diff(A,B) , n(X,Res1) , Res is ((Res1 - A)/(B - A)),!.
n(X,A,B,C,Res) :- diff(A,B), n(X,C,Res1) , Res is (((B-C)/(B-A))*(((C-A)*Res1) +1.0)),!.
% Finally 2 possibilities
n(X,A,B,C,Res) :- gagm(1.0,A,B,C,X,1.0,Res).
n(X,A,B,C,Res) :- sigma(X,1.0,Res1),sigma(X,A,C,Res2),sigma(X,B,C,Res3),sigma(X,C,Res4),!,n(Res1,Res2,Res3,Res4,Res).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
abreviated GAGS
agags from https://semjonadlaj.com/SP/Computer+Algebra+in+Scientific+Computing_37-56.pdf page 43
release tbd
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
tau(X,Y,Z,Res) :- Res is ((1/(2*Y))*((((Y/sqrt(X))-(sqrt(X)/Y))*(Z/4))-1)).
%
sigma(X,Y,Res) :- sigma(X,Y,Y,Res).
sigma(X,Y,Z,Res) :- Res is ((sqrt(X)+Y)*(sqrt(X)+Z)/(2*(Y+Z)*sqrt(X))).
%
agags_loop(Xm,_,_,_,Xn) :- abs(Xm-Xn) < 1.0e-10,!.
agags_loop(Xm,UmA,UmB,UmC,Res) :- 
	% MAGM sequence
	sigma(Xm,1.0,1.0,Res),
	sigma(Xm,UmA,UmC,UnA),
	sigma(Xm,UmB,UmC,UnB),
	sigma(Xm,UmC,UmC,UnC),
	%
	format('~t Xn Yn ~4f ~4f ~n',[Res,1.0]),
	format('~t UnA UnB UnC ~4f ~4f ~4f~n',[UnA,UnB,UnC]),
	!,
	agags_loop(Res,UnA,UnB,UnC,Xm).
%	
agags(_,_,C,_,_) :- T=C,format('~tIssue:~n'),format('~t  at start, C should not be equalt to T ~2f ~2f~n',[C,T]),!.
agags(_,_,C,X,_) :- Max is max(X,1.0), Min is min(X,1.0), C > Min, C < Max ,
			format('~tIssue:~n'),
			format('~t  at start, C should not be in [X,Y] ~2f ~2f ~2f~n',[C,X,1.0]),!.
agags(A,B,C,X,Res) :-
	%
	format('~t A B C X Y  ~2f ~2f ~2f ~2f ~2f ~2f~n~n',[A,B,C,X,1.0]),
	A=\=B,
	B=\=C,
	A=\=C,
	agags_loop(A,B,C,X,Res),!.
agags(A,B,C,_,_) :-
    format('~tIssue:~n'),
	format('~t  at start, A or B or C should not be equal ~2f ~2f ~2f~n',[A,B,C]).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	truncated GAGS
	tgags from https://semjonadlaj.com/SP/Computer+Algebra+in+Scientific+Computing_37-56.pdf page 43
	release tbd
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
tgags_loop(Xm,UmC,Xm) :- abs(Xm-UmC) < 1.0e-10,!.
tgags_loop(Xm,UmC,Res) :- 
	% MAGM sequence
	sigma(Xm,1.0,1.0,Xn),
	sigma(Xm,UmC,UnC),
	%
	format('~t Xn Yn ~4f ~4f ~n',[Xn,1.0]),
	format('~t UnA UnB UnC ~4f ~4f ~4f~n',[UnC,UnC,UnC]),
	!,
	tgags_loop(Xn,UnC,Res).
%	
tgags(C,_,_) :- T=C,format('~tIssue:~n'),format('~t  at start, C should not be equalt to T ~2f ~2f~n',[C,T]),!.
tgags(C,X,_) :- Max is max(X,1.0), Min is min(X,1.0), C > Min, C < Max ,
			format('~tIssue:~n'),
			format('~t  at start, C should not be in [X,Y] ~2f ~2f ~2f~n',[C,X,1.0]),!.
tgags(C,X,Res) :-
	%
	% format('~t A B C X Y  ~2f ~2f ~2f ~2f ~2f ~2f~n~n',[A,B,C,X,1.0]),
	tgags_loop(X,C,Res),!.
tgags(C,_,_) :-
    format('~tIssue:~n'),
	format('~t  at start, A or B or C should not be equal ~2f~n',[C]).
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   =:= w from page noted 46 in https://semjonadlaj.com/SP/Computer+Algebra+in+Scientific+Computing_37-56.pdf
   chapter 4.2
   release tbd
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
w(T,A,B,C,Res) :- Res is (((B-C)*(T-A))/((B-A)*(T-C))).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   agn from Borwein
   reference or link??
   agn(a,b,N), N>2 NOT symetric since A and B are differently weighted
   release 13 May 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */	
agn_loop(An,Bn,_,An) :- abs(An-Bn) < 1.0e-10,!.
agn_loop(Am,Bm,N,Res) :- 
	An is ((Am+(N-1)*Bm)/N),
	Cn is ((Am-Bm)/N),
	BnN is ((An**N)-(Cn**N)),
	nthroot(BnN,N,Bn), 
	!,
	agn_loop(An,Bn,N,Res).
agn(A,B,N,Res) :- 
	agn_loop(A,B,N,Res).
%
ag2(A,B,Res) :- agn(A,B,2,Res).  % = agm(a,b)
ag3(A,B,Res) :- agn(A,B,3,Res).  % N>2 NOT symetric since A and B are differently weighted
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	other means
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
rghm(X,Y,Res) :- rms2(X,Y,Res1),gm(X,Y,Res2),hm(X,Y,Res3),Res is Res1-Res2+Res3.
rhm(X,Y,Res) :-  rms2(X,Y,Res1),hm(X,Y,Res2), Res is ((1.0/3.0)*Res2 + (2.0/3.0)*Res1).
rgm(X,Y,Res) :-  rms2(X,Y,Res1),gm(X,Y,Res2), Res is ((1.0/2.0)*Res1 + (1.0/2.0)*Res2).
ahm(X,Y,Res) :-  am(X,Y,Res1),hm(X,Y,Res2), Res is ((1.0/2.0)*Res1 + (1.0/2.0)*Res2).
hrm(X,Y,Res) :-  rms2(X,Y,Res1),hm(X,Y,Res2), Res is ((1.0/3.0)*Res1 + (2.0/3.0)*Res2).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	other helpfull functions
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
maxi(A,B,Res) :- Res is max(A,B).
mini(A,B,Res) :- Res is min(A,B).
gamma(A,B,Res) :- AA is A*B, Res is exp(lgamma(AA)).        % valid for A & B > 0
gammap1(A,B,Res) :- AA is A+1.0, BB is B+1.0, gamma(AA,BB,Res). % valid for A & B > -1
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	functions where f(0)=0 and f(1)=0  >>>>>>>>>>>>  work this out
        only concav or convex

f=..*x*(x-1)
f=..*x*(x^n -1)=x*g(x) where g(1)=0
f=..*x*ln(x)
f=..ln(g(x)) where g(x)>0 and =1 at 0 and 1
f=..*((x^x) - 1)
f=..*sin(pi*x)
f=..x^a -x^b

        functions where f(0)=0 and f(1)=1   >>>>>>>>>>>>  work this out
f=x
f=..x^g(x) like g(x)=cte (e or 1/e or 2 or..)
f=..x^g(x) where g(x)=x^h(x).. where h(x)=..*x*(x-1)
     
        functions where f(1)=0 and f(e)=1   >>>>>>>>>>>>  work this out
f=ln(x)    
.. bring [1..e] into [1..1]

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	solver
	newton method
	release 30 April 2024
	https://stackoverflow.com/questions/26453574/how-can-i-pass-a-predicate-as-parameter-for-another-predicate-in-prolog
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* test

define first the "func_to_solve" below
then start solve with

solve.
------------- Start Solving -----------
X= 0.1468669873 
-------------- Ende ----------------
true.

check if the X calculated is the correct result..
hem(1.0,2.0,0.1468669873,Res2).
Res2 = 1.4567910310..360068.
agm(1.0,2.0,Res1).
Res1 = 1.4567910310..469068.

could be updated like
solve(Func,Start,IterM,IstIter,Res,Precision).
solve(func_to_solve,0.0001,50,Iter,Res,0.0001).
Iter = 6
Res = 0.1468669873
*/
func_to_solve(VarS,Res) :-
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	put the function to solve hereafter
*/
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%    example 1
/*	agm(1.0,2.0,Res1) - hem(1.0,2.0,X,Res1)= 0.0
	aka "agm(1.0,2.0,Res1),hem(1.0,2.0,VarS,Res2), Res is abs(Res1-Res2)."
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%	agm(1.0,2.0,Res1),hem(1.0,2.0,VarS,Res2), Res is abs(Res1-Res2).
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%    example 2
	agmxyhxy(1.0,VarS,Res1),gammap1(0.0,VarS,Res2), Res is abs(Res1-Res2).
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
output_func(Deriv,Operator,VarS,Res,Hdelta) :-
	% 0 >>  Res = f(VarS)
	Deriv = 0 -> 	call(Operator,VarS,Res);
    % 1 >>  Res = f(VarS)
	Deriv = 1 -> 	VarS2 is VarS + Hdelta, call(Operator,VarS,Res1),
					call(Operator,VarS2,Res2), Res is (Res2-Res1)/Hdelta
					;
	Deriv = 2 -> 	output_func(1,Operator,VarS,Res1,Hdelta), 
					VarS2 is VarS + Hdelta, output_func(1,Operator,VarS2,Res2,Hdelta), 
					Res is (Res2-Res1)/Hdelta;				
	fail.
%
solveloop_launch(XStart,XNext,_,_,FPrecision) :-
    number(XNext),
    XDelta is abs(XStart - XNext), XDelta < FPrecision,
	format('~tX= ~10f ~n',[XStart]),
	format('-------------- Ende ----------------~n'),!.
%
solveloop_launch(XStart,XNext,XIterCount,XIterMax,_) :-
    number(XNext),XIterCount > XIterMax,
	format('~tbetween X1= ~5f ~t and X2= ~5f stopped at ~0f ~titerations~n',[XStart,XNext,XIterMax]),
	format('-------------- Ende ----------------~n'),!.
%	
solveloop_launch(XStart,_,XIterCount,XIterMax,FPrecision) :-	
	output_func(0,func_to_solve,XStart,Res1,FPrecision),
    output_func(1,func_to_solve,XStart,Res2,FPrecision),
    XIterCountn is (XIterCount + 1),
    % according newton method 
    XStartn is XStart - (Res1/Res2),
    solveloop_launch(XStartn,XStart,XIterCountn,XIterMax,FPrecision).
%
solve :- 
% define a start value (can be adapted depending of the function called)
	XStart is 0.000000000001, 
% define a counter max in case there is no convergence
	XIterCount is 0,
	XIterMax is 50,
% define a value "precision" for calculating the 1st derivate for the newton function
% and stopping the iteration process
	FPrecision is 0.0000000001,
	format('---------- Start Solving -----------~n'),
	solveloop_launch(XStart,_,XIterCount,XIterMax,FPrecision).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% eventually put the lines below into a documentation output..
%
means (non iterated) from 
https://en.wikipedia.org/wiki/Mean
https://en.wikipedia.org/wiki/Generalized_mean
https://arxiv.org/pdf/1907.04110.pdf
    
order so far identified accross all X and Y 

shortenings  rms2-gm+hm          = rghm
             (1/3)*hm+(2/3)*rms2 = rhm
             (1/2)*rms2+(1/2)*gm = rgm
             (1/2)*am+(1/2)*hm   = ahm
             (2/3)*hm+(1/3)rms2  = hrm

put in order..
in 0..1
in 0..10
>>>>>>>>>>>>>>>>>>>>>
..
<<<<<<<<<<<<<<<<<<<<<

Within MAX MIN..            
      P--------------------------------------------------------------------------------------------------------hrm I magm > -----------------------------P     Zero collapse
                                                                                                           interesting area to look at.. 

xxx   Max > chm >  cm  > rms2 > pom5_3 > sm2 > pom4_3 > stom3 > nsm > am > rhm >  im > pom2_3 > herom >    pom1_2                 > lm > gm > ghm > hm > Min   xxx 


      P---------------------------------------------------------------------------------------------------------------------------------V----------------P     GM1
      X(P)  Y(P)  Z(Value)  W(Weight): 4D generic non-evolution function with W constant
      P---------------------------------------------------------------V----------------------------------------------------------------------------------P     AM1

      P---------------------------------------------------------------Q-----------------------------------------------------------------Q----------------P     AGM0
      Q---------------------------------------------------------------I-------------------------------------------------------V---------I----------------Q     AGM
      X(P)  Y(P)  Z(Value)  W(Weight): 4D generic evolution function with Z and W constant

      P---------------------------------------------------------------Q--------------------------?-------------------------------------------------------P     MAGM0
      Q---------------------------------------------------------------I--------------------------?---------------------V---------------------------------Q     MAGM
      X(P)  Y(P)  Z(Value)  W(Weight): 4D generic evolution function with W evolution


                         rms2 >                 rghm                > am                                                           
                                                                           rhm > rgm > pom2_3
                                                                                                           pom1_2 >    ahm     > hrm  > gm

      [LEHM]
            chm >   lehm1_3            > sm2   

      [STOM]                                                          am          im                       pom1_2                   lm   gm
                                                        stom3        stom2      stom1                      stom0.5                stom0  stom-1
                                                                                                           hoelm0_5
                              
      [POM]                                   
                                                                                                           pom1_2   >   pom1_3    > lm

      [special function]
                                                                                                           pom1_2  > magm >  agm  > lm
                                                            ag3  .. not symetric

                                                                           rhm >                 lmam             > magm

      [seiffert mean]
                                        sm2 >                             sm1                            > pom1_2



Over MAX MIN..

xxx                                   em                                                                                               > gm
xxx                                                                            magmxxyy                                                                    xxx   


class of prime 3 and 5 and 7..? nthroot
define the influence of the class of the 2 poles in the result
define mathematic of mean functions eg. ellipse perimeter linked to magm(a²,b²) DividedBy agm(a,b) which give a division with factor 1 as result 
infinite potenz turm here?
reprocical gamma here?
lambert here?

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	contraharmonic mean
	https://en.wikipedia.org/wiki/Contraharmonic_mean
	released 18 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
chm(X,Y,Res) :- 
	X=Y -> Res is X; 
	Res is (((X*X)+(Y*Y))/(X+Y)).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	cubic mean
	https://en.wikipedia.org/wiki/Cubic_mean
	released 18 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
cm(X,Y,Res) :- InP is ((X**3+Y**3)/2.0), nthroot(InP,3,Res).
% 
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	root square mean
	https://en.wikipedia.org/wiki/Root_mean_square
	released 18 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
rms2(X,Y,Res) :- Res is sqrt(((X*X)+(Y*Y))/2.0).
rms3(X,Y,Z,Res) :- Res is sqrt(((X*X)+(Y*Y)+(Z*Z))/3.0).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   neumann sandor mean  https://en.wikipedia.org/wiki/Neuman%E2%80%93S%C3%A1ndor_mean
   https://de.wikipedia.org/wiki/Areasinus_hyperbolicus_und_Areakosinus_hyperbolicus
   released 20 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
nsm(X,Y,Res) :- 
	X=Y -> Res is X;
	Res is ((X-Y)/(2.0*asinh((X-Y)/(X+Y)))).
%
% arithmetic mean
% https://en.wikipedia.org/wiki/Arithmetic_mean
% released 18 April 2024
%
am(X,Y,Res) :-
	Res is (X+Y)/2.0.
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   identric mean  https://en.wikipedia.org/wiki/Identric_mean
   logarithmic type; between herom and am
   released 20 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
im(X,Y,Res) :- 
	X=Y -> Res is X;
	X=0.0 -> Res is ((1.0/exp(1.0))*exp((1.0/(-Y))*log(1.0/(exp(Y*log(Y))))));
	Y=0.0 -> Res is ((1.0/exp(1.0))*exp((1.0/X)*log((exp(X*log(X))))));
	Res is ((1.0/exp(1.0))*exp((1.0/(X-Y))*log((exp(X*log(X)))/(exp(Y*log(Y)))))).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   heronian mean   https://en.wikipedia.org/wiki/Heronian_mean
   = weighted am and gm
   release 20 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
herom(A,B,Res) :- am(A,B,Res1), gm(A,B,Res2), Res is ((2.0*Res1/3.0)+(Res2/3.0)).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   first seiffert mean; see neumann mean page
   https://en.wikipedia.org/wiki/Neuman%E2%80%93S%C3%A1ndor_mean
   released 21 April 2024
   usually named "P" in seiffert litterature
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
sm1(X,Y,Res) :- 
	X=Y -> Res is X;
	X=0.0 -> Res is (-Y/(2.0*atan(-1.0)));
	Y=0.0 -> Res is (X/(2.0*atan(1.0)));
	Res is ((X-Y)/(2.0*asin((X-Y)/(X+Y)))).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   second seiffert mean; see neumann mean page
   https://en.wikipedia.org/wiki/Neuman%E2%80%93S%C3%A1ndor_mean
   https://files.ele-math.com/articles/jmi-09-83.pdf
   released 20 April 2024
   Usually named "T" in seiffert litterature
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
sm2(X,Y,Res) :- 
	X=Y -> Res is X;
%	X=0.0 -> Res is (-Y/(2.0*atan(-1.0)));
%	Y=0.0 -> Res is (X/(2.0*atan(1.0)));
	Res is ((X-Y)/(2.0*atan((X-Y)/(X+Y)))).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   magm from https:  www.ams.org  notices  201208  rtx120801094p.pdf   
   released 18 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
% basis loop
%magm_loop(A,AG1,_,A) :- abs(A-AG1) < 1.0e-10,!.
magm_loop(A,AG1,_,Res) :- abs(A-AG1) < 1.0e-10,Res is A,!.
magm_loop(Am,AG1m,AG2m,Res) :- 
	An is ((Am+AG1m)/2.0) ,
	AG1n is (AG2m + sqrt((Am-AG2m)*(AG1m-AG2m))),
	AG2n is (AG2m - sqrt((Am-AG2m)*(AG1m-AG2m))),
%	write([AG1n,AG2n]),nl,
	!,
	magm_loop(An,AG1n,AG2n,Res).
%
% basis function
magm(A,B,Res) :- 
	Start is 0.0,
	magm_loop(A,B,Start,Res).
%
% magm(x**2,y**2,Res)
magmxxyy(A,B,Res) :- 
	Start is 0.0,
	AA is A*A,
	BB is B*B,!,
	magm_loop(AA,BB,Start,Res).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   agm from https://de.wikipedia.org/wiki/Arithmetisch-geometrisches_Mittel
   https://rosettacode.org/wiki/Arithmetic-geometric_mean#Prolog
   between am and gm
   released 18 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
agm(A,G,Res):- abs(A-G) < 1.0e-10,Res is A,!.
agm(Am,Gm,Res):- 
%	An is ((Am+Gm)/2.0),
%	Gn is sqrt(Am*Gm),!,
	am(Am,Gm,Res1),
	gm(Am,Gm,Res2),!,
	agm(Res1,Res2,Res).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   agm of kprim
   released 10 june 2026
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
agm_kprim(Am,Km,Res):- 
	Kn is Am*Km,
	kprim(Kn,Res1),
	agm(1.0,Res1,Res).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   lmam 
   infinite iterated between lm and am
   released 05 feb 2026
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
lmam(X,Y,Res):- abs(X-Y) < 1.0e-10,Res is X,!.
lmam(Xn,Yn,Res):- 
	am(Xn,Yn,XN),
	lm(Xn,Yn,YN),!,
	lmam(XN,YN,Res).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	logarithmic mean
	https://en.wikipedia.org wiki Logarithmic_mean
	https://www.ncbi.nlm.nih.gov pmc articles PMC6061525 
	or = (X-Y)/(2*atanh((X-Y)/(X+Y))
	released 18 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
lm(X,Y,Res):- 
	X=Y -> Res is X; 
	X=0.0 -> Res is 0.0;
	Y=0.0 -> Res is 0.0;
	Res is (Y-X)/log(Y/X).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 	exponential mean
 	released 08 feb 2026
        XY^(1/e) = XY^e^(-1)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
em(X,Y,Res) :- 	
        X=0.0 -> Res is 0.0;
	Y=0.0 -> Res is 0.0;
	Res is exp(exp(-1.0)*log(X*Y)).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 	exponential mean2
 	04 April 2026
        (1-exp(-XY^(1/e)))*(e/(e-1)) from [0..1] to [0..1]
        centered exp(em)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
em2(X,Y,Res) :- 	
        X=0.0 -> Res is 0.0;
	Y=0.0 -> Res is 0.0;
	Res is ( (1.0-exp( 0.0 - exp( exp(-1.0) * log(X*Y) ))) * (exp(1.0)/(exp(1.0)-1.0)) ).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 	geometric mean
 	https://en.wikipedia.org/wiki/Geometric_mean
 	released 18 April 2024 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
gm(X,Y,Res) :- Res is sqrt(X*Y).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   geometric harmonic mean from https://en.wikipedia.org/wiki/Geometric%E2%80%93harmonic_mean
   released 20 April 2024
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
ghm(X,Y,Res) :- X=Y -> Res is X; 
	X=0.0 -> Res is 0.0;
	Y=0.0 -> Res is 0.0;
	InvX is 1.0/X, InvY is 1.0/Y , 
	agm(InvX,InvY,ResAgm),
	Res is 1.0/ResAgm.
%
/* harmonic mean
 https://en.wikipedia.org/wiki/Harmonic_mean
 released 18 April 2024 */
hm(X,Y,Res) :- 
	X=Y -> Res is X; 
	Res is ((2.0*X*Y)/(X+Y)).
%
% >>>>> min
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   several functions for gamma studies (finding an iterated function)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
/* Continued Fraction Representation of GAMMA 
 part 1
 created 11 April 2026 */
% https://en.wikipedia.org/wiki/Gamma_function#Continued_fraction_representation
% https://en.wikipedia.org/wiki/Continued_fraction
% 
cfg1_loop(_,ANN_1,ANN_2,BNN_1,BNN_2,Ncount,Res):- 
	Ncount > 1, 
	BNN_1 =\= 0.0,
	BNN_2 =\= 0.0,
	abs((ANN_1/BNN_1)-(ANN_2/BNN_2)) < 1.0e-8,Res is (ANN_1/BNN_1),!
	,format('~n~tcount= ~4f ',[Ncount])
	.
cfg1_loop(X,ANN_1,ANN_2,BNN_1,BNN_2,Ncount,Res):- 
% Ncount > 0
        BN is ((3.0*Ncount)-X),
        ( Ncount == 1 -> 
        AN is exp(-1.0) 
        ; 
        AN is (X-Ncount)
        ),
        increment(Ncount,NCOUNT,1),
	ANN is (BN*ANN_1+AN*ANN_2),
	BNN is (BN*BNN_1+AN*BNN_2 ),!,
	cfg1_loop(X,ANN,ANN_1,BNN,BNN_1,NCOUNT,Res).
%
cfgamma1(X,Y,Res) :- 
        X<0.0 -> Res is 0.0,!;
        Y<0.0 -> Res is 0.0,!;
	XX is (X*Y),
	B_0 is 1.0,
	A_0 is 0.0,  % A0=b0
	A_1 is 1.0,
	B_1 is 0.0,
	cfg1_loop(XX,A_0,A_1,B_0,B_1,1,Res).
%
/* Continued Fraction Representation of GAMMA 
 part 2
 created 12 April 2026 */
% https://en.wikipedia.org/wiki/Gamma_function#Continued_fraction_representation
% https://en.wikipedia.org/wiki/Continued_fraction
% 
cfg2_loop(_,ANN_1,ANN_2,BNN_1,BNN_2,Ncount,Res):- 
	Ncount > 1, 
	BNN_1 =\= 0.0,
	BNN_2 =\= 0.0,
	abs((ANN_1/BNN_1)-(ANN_2/BNN_2)) < 1.0e-10,Res is (ANN_1/BNN_1),!	
	,format('~n~tcount= ~4f ',[Ncount])
	.
cfg2_loop(X,ANN_1,ANN_2,BNN_1,BNN_2,Ncount,Res):- 
% Ncount > 0
        BN is (X+Ncount-1.0),
        Res1 is (Ncount mod 2),
        ( Ncount == 1 
        	-> 
        	AN is exp(-1.0),
        	increment(Ncount,NCOUNT,1),
        	ANN is AN,
		BNN is BN,!,
	 	cfg2_loop(X,ANN,ANN_1,BNN,BNN_1,NCOUNT,Res)
        	; 
        	( Res1 == 0 
        		->
        		AN is X+((Ncount/2.0)-1.0),
        		ANN is (BN*ANN_1+AN*ANN_2),
			BNN is (BN*BNN_1+AN*BNN_2)
			;
        		AN is ((Ncount-1.0)/2.0),
        		ANN is (BN*ANN_1-AN*ANN_2),
			BNN is (BN*BNN_1-AN*BNN_2)
        	)
        ),
        increment(Ncount,NCOUNT,1),
	!,cfg2_loop(X,ANN,ANN_1,BNN,BNN_1,NCOUNT,Res).
%
cfgamma2(X,Y,Res) :- 
        X<0.0 -> Res is 0.0,!;
        Y<0.0 -> Res is 0.0,!;
	XX is (X*Y),
	B_0 is 1.0,
	A_0 is 0.0,  % A0=b0
	A_1 is 1.0,
	B_1 is 0.0,
	cfg2_loop(XX,A_0,A_1,B_0,B_1,1,Res).
%
/* Continued Fraction Representation of GAMMA plus 1
 created 12 April 2026 */
% https://en.wikipedia.org/wiki/Gamma_function#Continued_fraction_representation
% https://en.wikipedia.org/wiki/Continued_fraction
cfgamp1(X,Y,Res) :- 
	increment(X,XX,1.0),
%	XX is (X+1.0),
	YY is (Y+1.0),
        cfgamma1(XX,YY,Res1),
        cfgamma2(XX,YY,Res2),
	Res is (Res1+Res2).
%
/* XY^XY
 tested 30 March 2026 */
xyhxy(X,Y,Res) :- 
	X=0.0 -> Res is 1.0;
	Y=0.0 -> Res is 1.0;
	Res is exp((X*Y)*log(X*Y)).
%
/* XY^AGM(X,Y)
 created 17 Mai 2026 */
xyhagmxy(X,Y,Res) :- 
	X=0.0 -> Res is 1.0;
	Y=0.0 -> Res is 1.0;
	agm(X,Y,Res1), Res is exp(Res1*log(X*Y)).
%
/* XY^(1/XY)
 7 April 2026 */
xyh1_xy(X,Y,Res) :- 
	X=0.0 -> Res is 0.0;
	Y=0.0 -> Res is 0.0;
	Res is exp((1.0/(X*Y))*log(X*Y)).
%
/* similar XY^(1/XY) but convex centered
 7 April 2026 */
xyh2_xy(X,Y,Res) :- 
	X=0.0 -> Res is 0.0;
	Y=0.0 -> Res is 0.0;
	XX is X*Y,
	Par1 is ((XX*(exp(1.0)-1.0))+1.0),
	Res is ( (1.0/((exp(exp(-1.0)))-1.0)) * (exp((1.0/(Par1))*log(Par1)) -1.0) ).
%	Res is ( (1.0/(exp(exp(-1.0))-1.0)) * exp((1.0/(X*Y*(exp(1.0)-1.0)+1.0))*log(X*Y*(exp(1.0)-1.0)+1.0)) ).
%
/* (1/XY)^(XY) concav [0..1] to [1..1.444..1] which is >1
 7 April 2026 */
onexyhxy(X,Y,Res) :- 
	X=0.0 -> Res is 1.0;
	Y=0.0 -> Res is 1.0;
	Res is exp((X*Y)*log(1.0/(X*Y))).
%
/* (1-((1/XY)^(XY)))/2 convex [0..1] to [0..-0.25..0]
 7 April 2026 */
twoxyhxy(X,Y,Res) :- 
	X=0.0 -> Res is 1.0;
	Y=0.0 -> Res is 1.0;
	Res is ((1.0-exp((X*Y)*log(1.0/(X*Y))))/2.0)+1.0.
%
% agmxyhxy = agm(1,XY^XY,Res)
%  tested 30 March 2026
agmxyhxy(A,B,Res) :- 
	xyhxy(A,B,AA),!,
	agm(1.0,AA,Res).
%
% or1
% created 26 April 2026
% (1,1) -> 1
% (0,0) -> 0
% (0,1) -> 0.5
% (1,0) -> 0.5
% similar to NAND operator https://www.hpmuseum.org/forum/thread-24944.html
or1(X,Y,Res) :- 
	Res is ( ( (1.0-exp(X))/(1.0-exp(1.0)) ) + ((1.0/log(2.0))*log(Y+1.0)) )/2.0.
%
%
/* Several functions with delta calculation to gamma (as value or as factor)  */
%
% gamdelta1
% created 30 March 2026
gamdelta1(X,_,Res) :- 
%	X=0.0 -> Res is 0.0;
%	Y=0.0 -> Res is 0.0;
	xyhxy(X,1.0,Res1),!,
	gammap1(X,0.0,Res2),
	em(X,1.0,Res3),
	Res is -((Res2 - 1.0) - (((Res1-1.0)/2.0) * Res3)).
%
% gamdelta2
% created 04 April 2026
gamdelta2(X,_,Res) :- 
%	X=0.0 -> Res is 0.0;
%	Y=0.0 -> Res is 0.0;
	xyhxy(X,1.0,Res1),!,
	gammap1(X,0.0,Res2),
	em2(X,1.0,Res3),
	Res is -((Res2 - 1.0) - (((Res1-1.0)/2.0) * Res3)).
%
% gamdelta3
% created 12 April 2026
gamdelta3(X,_,Res) :- 
%	X=0.0 -> Res is 0.0;
%	Y=0.0 -> Res is 0.0;
	xyhxy(X,1.0,Res1),
	gammap1(X,0.0,Res2),
	xyh1_xy(X,1.0,Res3),!,
	Res is -((Res2 - 1.0) - (((Res1-1.0)/2.0) * Res3)).
%
% gamdelta4
% created 12 April 2026
gamdelta4(X,_,Res) :- 
%	X=0.0 -> Res is 0.0;
%	Y=0.0 -> Res is 0.0;
	xyhxy(X,1.0,Res1),
	gammap1(X,0.0,Res2),
	xyh2_xy(X,1.0,Res3),!,
	Res is -((Res2 - 1.0) - (((Res1-1.0)/2.0) * Res3)).
%
% gamdelta5
% created 15 April 2026
gamdelta5(X,_,Res) :- 
	xyhxy(X,1.0,Res1),
	gammap1(X,0.0,Res2),
	agm(X,1.0,Res3),!,
	Res is -((Res2 - 1.0) - (((Res1-1.0)/2.0) * Res3)).
%
% gamdelta6
% created 15 April 2026
gamdelta6(X,_,Res) :- 
	xyhxy(X,1.0,Res1),
	gammap1(X,0.0,Res2),
	magm(X,1.0,Res3),!,
	Res is -((Res2 - 1.0) - (((Res1-1.0)/2.0) * Res3)).
%
% gamdelta7
% created 17 Mai 2026
gamdelta7(X,_,Res) :- 
	xyhagmxy(X,1.0,Res1),
	gammap1(X,0.0,Res2),!,
	Res is (Res2 - Res1).
%
% gamfact1
% created 12 April 2026
gamfact1(X,_,Res) :-  
	xyhxy(X,1.0,Res1),
	gammap1(X,0.0,Res2),!,
	Res is ( Res1 / Res2 ).
%
%
% gamfact2
% created 12 April 2026
gamfact2(X,_,Res) :- 
	xyhxy(X,1.0,Res1),
	gammap1(X,0.0,Res2),
	twoxyhxy(X,1.0,Res3),!,
	Res is ( ( ((( Res3 - 1.0) / 4.0)+1.0) * Res1 ) / Res2 ).
%
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   application 1
   ellipse perimeter from https://www.ams.org/notices/201208/rtx120801094p.pdf
   no need to calculate the perimeter if A or B = 0; its 4*A or 4*B
   >> Algebra 
      magm(a^2,b^2)/agm(a,b) is "ellipse-perimeter(a,b)/2*pi"
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
/* Test

first start in a terminal with "swipl iterated.pl" (this file)

?- eper12(10.0,6.0,Res).
Res = 51.05399772679625.

*/
%
eper12(A,B,Res) :- 
	A = 0.0 -> Res is 4.0*B;
	B = 0.0 -> Res is 4.0*A;   
	Ah2 is A*A,Bh2 is B*B,!,
	agm(A,B,Res1),magm(Ah2,Bh2,Res2),
	Res is (2.0*pi*Res2/Res1).
%	
/* test variant with GAGM

first start in a terminal with "swipl iterated.pl" (this file)

?- eper13(10.0,6.0,Res).
 T A B C X Y  10.00 10.00 80.00 16.00 10.00 6.00

 Xn Yn Zn 8.0000 7.7460 -7.7460
 UnA UnB UnC 8.4615 13.9583 9.8750
 WmXn WmYn T WmT 0.2286 0.2497 10.0000 -0.0000

 Xn Yn Zn 7.8730 7.8725 -23.3644
 UnA UnB UnC 7.9073 8.1824 7.9863
 WmXn WmYn T WmT 0.2184 0.2185 10.0000 9.1429

 Xn Yn Zn 7.8727 7.8727 -54.6015
 UnA UnB UnC 7.8728 7.8733 7.8729
 WmXn WmYn T WmT 0.2174 0.2174 10.0000 0.7410

 Xn Yn Zn 7.8727 7.8727 -117.0758
 UnA UnB UnC 7.8727 7.8727 7.8727
 WmXn WmYn T WmT 0.2174 0.2174 10.0000 0.7122

 in 4.00  iterations 
 T A B C X Y  10.00 10.00 80.00 16.00 100.00 36.00

 Xn Yn Zn 68.0000 60.0000 -60.0000
 UnA UnB UnC 144.6154 50.8333 120.5000
 WmXn WmYn T WmT 1.0198 1.0390 10.0000 -0.0000
 
 Xn Yn Zn 64.0000 63.9355 -183.9355
 UnA UnB UnC 75.7855 61.3916 72.7985
 WmXn WmYn T WmT 1.0599 1.0596 10.0000 0.9050

 Xn Yn Zn 63.9677 63.9677 -431.8387
 UnA UnB UnC 64.1698 63.9224 64.1196
 WmXn WmYn T WmT 1.0605 1.0605 10.0000 0.8302

 Xn Yn Zn 63.9677 63.9677 -927.6451
 UnA UnB UnC 63.9678 63.9677 63.9678
 WmXn WmYn T WmT 1.0605 1.0605 10.0000 0.7978

 in 4.00  iterations 
	TT is 10.0,       no effect?
	AA is 10000.0,
	BB is 80000.0,
Res = 51.05234989267874 .     ????????????  should be Res = 51.05399772679625.
*/
%
eper13(A,B,Res) :- 
	A = 0.0 -> Res is 4.0*B;
	B = 0.0 -> Res is 4.0*A;   
	Ah2 is A*A,Bh2 is B*B,!,
	% gagm(T,A,B,C,X,Y,Res) 
	TT is 100.0, % TT should have no effect?
	AA is 100000.0,  % should be big ? bigger?
	BB is 800000.0,
	CC is (A+B), % for being sure its outside the [A,B]
	X is A,
	Y is B,
	gagm(TT,AA,BB,CC,X,Y,Res1),gagm(TT,AA,BB,CC,Ah2,Bh2,Res2),
	Res is (2.0*pi*Res2/Res1).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ellipse perimeter according https://semjonadlaj.com/WrkShps/GMAGM.pdf
   https://www.ams.org/notices/201208/rtx120801094p.pdf
   https://de.wikipedia.org/wiki/Ellipse
   test in https://www.mathsisfun.com/geometry/ellipse-perimeter.html
   tested 16 Mai 2026
   OLD VERSION.. to be deleted.. keep "eper142"
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
nthroughm(Xn,Xnn,_,Zn,_,Ron,RoNRes,XRes):- 
	RoN is Ron * (Xnn-Zn)/(Xn-Zn), 
	abs(RoN-Ron) < 1.0e-10,RoNRes is Ron, XRes is Xn,!.
nthroughm(Xn,Xnn,Yn,Zn,Rnn,Ron,RoNRes,XRes):- 
%	An is ((Am+Gm)/2.0),
%	Gn is sqrt(Am*Gm),!,
        XN is ((Xn+Yn)/2.0),
        Rn is sqrt(2.0 * (Xn - Zn) * Rnn),
        YN is (Zn+Rn),
        ZN is (Zn-Rn),
	RoN is (Ron*(Xnn-Zn)/(Xn-Zn)),!,
	nthroughm(XN,Xn,YN,ZN,Rn,RoN,RoNRes,XRes).
%
% test https://www.mathsisfun.com/geometry/ellipse-perimeter.html
% 10.0  6.0  51.05399773
%  2.0  6.0  26.72978648
eper14(A,B,Res) :- 
	A = 0.0 -> Res is 4.0*B;
	B = 0.0 -> Res is 4.0*A;
% lets define the start value
% Beta is the semi-minor axis where Beta^2 + Gam^2 = 1
% Gam is the eccentricity
	( A < B -> Beta is A/B ; Beta is B/A ),
	X0 is Beta,
	Y0 is 1.0/Beta,
	Z0 is 0.0,
	R0 is 1.0,
% lets define the first recursion
        X1 is (X0+Y0)/2.0,
        Y1 is Z0 + R0,
        Z1 is Z0 - R0,
	Ro1 is 1.0,!,
%
	nthroughm(X1,X0,Y1,Z1,R0,Ro1,RoNRes,XRes),
	( A < B -> Res is (2*B*RoNRes*XRes*pi) ; Res is (2*A*RoNRes*XRes*pi) ).
%
%..................................  Optimized version 1 .......................
nthroughm1(Xn,Xnn,_,_,_,Ron,Res):- 
       abs(Ron*(Xn-Xnn)) < 1.0e-10 ,
       % average value of Xn and Xnn used based on a DeepSeek proposal
       Res is Ron*(Xn+Xnn)/2.0,!.
%
nthroughm1(Xn,Xnn,Yn,Zn,Rnn,Ron,Res):- 
% Xn    Current Xn
% Xnn   X_n-1
% Yn    Current Yn
% Zn    Current Zn
% Rnn   r_n-1
% Ron   ro_n
% Res   result
	XN is (Xn+Yn)/2.0,
        Rn is sqrt(2.0 * (Xn - Zn) * Rnn),
        YN is Zn+Rn,
        ZN is Zn-Rn,
	RoN is Ron*(Xnn-Zn)/(Xn-Zn),
	nthroughm1(XN,Xn,YN,ZN,Rn,RoN,Res).	
%..................................  Optimized version 2 .......................
% tested 17 Mai 2026
% iterated function with collapsing interval
% 6 parameters 
nthroughm2(Xn,Xnn,Yn,Zn,Rnn,Ron,Res):- 
% Xn    Current Xn
% Xnn   X_n-1
% Yn    Current Yn
% Zn    Current Zn
% Rnn   r_n-1
% Ron   ro_n
% Res   result
       ( abs(Ron*(Xn-Xnn)) < 1.0e-10 
       % average value of Xn and Xnn used based on a DeepSeek proposal
	-> Res is Ron*(Xn+Xnn)/2.0,! 
	; 
	XN is (Xn+Yn)/2.0,
        Rn is sqrt(2.0 * (Xn - Zn) * Rnn),
        YN is Zn+Rn,
        ZN is Zn-Rn,
	RoN is Ron*(Xnn-Zn)/(Xn-Zn),
	nthroughm2(XN,Xn,YN,ZN,Rn,RoN,Res) ).	
%
eper141(A,B,Res) :- 
	A = 0.0 -> Res is 4.0*B;
	B = 0.0 -> Res is 4.0*A;
% lets define the start value according https://semjonadlaj.com/WrkShps/GMAGM.pdf
	( A < B -> Beta is A/B ; Beta is B/A ),
	X0 is Beta,
	Y0 is 1.0/Beta,
	Z0 is 0.0,
	R0 is 1.0,
% lets define the first recursion values for starting the calculation
        X1 is (X0+Y0)/2.0,
        Y1 is Z0 + R0,
        Z1 is Z0 - R0,
	Ro1 is 1.0,!,
%
	nthroughm1(X1,X0,Y1,Z1,R0,Ro1,Res1),
	( A < B -> Res is 2*B*Res1*pi ; Res is 2*A*Res1*pi ).
%
eper142(A,B,Res) :- 
	A = 0.0 -> Res is 4.0*B;
	B = 0.0 -> Res is 4.0*A;
% lets define the start value according https://semjonadlaj.com/WrkShps/GMAGM.pdf
	( A < B -> Beta is A/B ; Beta is B/A ),
	X0 is Beta,
	Y0 is 1.0/Beta,
	Z0 is 0.0,
	R0 is 1.0,
% lets define the first recursion values for starting the calculation
        X1 is (X0+Y0)/2.0,
        Y1 is Z0 + R0,
        Z1 is Z0 - R0,
	Ro1 is 1.0,!,
%
	nthroughm2(X1,X0,Y1,Z1,R0,Ro1,Res1),
	( A < B -> Res is 2*B*Res1*pi ; Res is 2*A*Res1*pi ).
%
% simplify for not using Beta?
% NOT tested
eper143(A,B,Res) :- 
	A = 0.0 -> Res is 4.0*B;
	B = 0.0 -> Res is 4.0*A;
	X0 is A,
	Y0 is B,
	Z0 is 0.0,
	R0 is 1.0,
% lets define the first recursion values for starting the calculation
        X1 is (X0+Y0)/2.0,
        Y1 is Z0 + R0,
        Z1 is Z0 - R0,
	Ro1 is 1.0,!,
%
	nthroughm2(X1,X0,Y1,Z1,R0,Ro1,Res1),
	Res is 2*Res1*pi.
%
% https://semjonadlaj.com/Excerpts/QuarterMillennium.pdf
% ultimate ellipse perimeter calculation formula
nthloop144(Qn,Rn,Sn,Res):-
       Pn is 2.0*pi*(Qn-Rn),
       Snn is sqrt((Sn+(1.0/Sn))/2.0),
       Qnn is 2.0*Snn*Qn,
       Rnn is (Qn+Rn)/Snn,
       Pnn is 2.0*pi*(Qnn-Rnn),
       ( abs((Pn-Pnn)) < 1.0e-10 
	-> Res is (Pn+Pnn)/2.0,! 
	; 
	nthloop144(Qnn,Rnn,Snn,Res) ).
%	
eper144(A,B,Res) :- 
	A = 0.0 -> Res is 4.0*B;
	B = 0.0 -> Res is 4.0*A;
	( A < B -> Beta is A/B ; Beta is B/A ),
% initiate the values
	S0 is sqrt(Beta),
	Q0 is S0,
	R0 is 0.0,
% start the iterations
	nthloop144(Q0,R0,S0,Res1),
	( A < B -> Res is B*Res1 ; Res is A*Res1 ).
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   application 2
   seiffert-transform relation between sm1 and sm2
   same between gm and am
   same between am and rms2
   >> Algebra 
      sm2(a,b) = sm1(seiftr(a,b))
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
% seiftr(3.0,4.0,Res1,Res2),sm1(Res1,Res2,Res).
% Res1 = 3.0355339059327378,
% Res2 = 4.035533905932738,
% Res = 3.5236813152661997.
% sm2(3.0,4.0,Res).
% Res = 3.5236813152661997.
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   application 3
   
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
% agm(1.0,2.0,Res1), hem(1.0,2.0,0.14,Res2).
% Res1 = 1.4567910310469068,
% Res2 = 1.458471713255466.
% agm(1.0,2.0,Res1), hem(1.0,2.0,0.16,Res2).
% Res1 = 1.4567910310469068,
% Res2 = 1.4536686399640824.
%
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   scan sequence for printing out the several diverse mean
   therefore identifying their similarities
   
?- test_mean.
--------------------------- Start -------------------------------------

Y= 0.00000 

X= 0.000   Y= 0.000 
Stolarski means -------------------------
stom+infiniti= 0.000 stom2= 0.000 stom1= 0.000 stom-1= 0.000  stom0= 0.000  stom0.5= 0.000 stom-infiniti= 0.000  
-----------------------------------------
ag3= 0.000  rghm= 0.000  pom1/2= 0.0000  pom1/3= 0.000 rgm= 0.000 ahm= 0.000 hrm= 0.000 magm(x**2,y**2)= 0.000 
-----------------------------------------
max= 0.000 chm= 0.000  cm= 0.000  rms2= 0.000  pom5/3= 0.000  sm2= 0.000  pom4/3= 0.000  stom3= 0.000  nm= 0.000  am= 0.000  rhm= 0.000 im= 0.000  
      pom2/3= 0.000  herom= 0.000  sm1= 0.000  lmam= 0.000  magm= 0.0000  agm= 0.0000  lm= 0.000  gm= 0.000 ghm= 0.000 hm= 0.000 min= 0.000

X= 1.000   Y= 0.000 
Stolarski means -------------------------
stom+infiniti= 1.000 stom2= 0.500 stom1= 0.368 stom-1= 0.000  stom0= 0.000  stom0.5= 0.000 stom-infiniti= 0.000  
-----------------------------------------
ag3= 0.000  rghm= 0.707  pom1/2= 0.2500  pom1/3= 0.125 rgm= 0.354 ahm= 0.250 hrm= 0.236 magm(x**2,y**2)= 0.000 
-----------------------------------------
max= 1.000 chm= 1.000  cm= 0.794  rms2= 0.707  pom5/3= 0.660  sm2= 0.637  pom4/3= 0.595  stom3= 0.577  nm= 0.567  am= 0.500  rhm= 0.471 im= 0.368  
      pom2/3= 0.354  herom= 0.333  sm1= 0.318  lmam= 0.000  magm= 0.0000  agm= 0.0000  lm= 0.000  gm= 0.000 ghm= 0.000 hm= 0.000 min= 0.000

..
..

X= 8.000   Y= 10.000 
Stolarski means -------------------------
stom+infiniti= 10.000 stom2= 9.000 stom1= 8.981 stom-1= 8.944  stom0= 8.889  stom0.5= 8.889 stom-infiniti= 8.000  
-----------------------------------------
ag3= 9.334  rghm= 9.000  pom1/2= 8.9721  pom1/3= 8.963 rgm= 9.000 ahm= 8.944 hrm= 8.944 magm(x**2,y**2)= 80.998 
-----------------------------------------
max= 10.000 chm= 9.111  cm= 9.110  rms2= 9.055  pom5/3= 9.037  sm2= 9.037  pom4/3= 9.019  stom3= 9.018  nm= 9.018  am= 9.000  rhm= 9.000 im= 8.981  
      pom2/3= 8.981  herom= 8.981  sm1= 8.981  lmam= 8.981  magm= 8.9721  agm= 8.9721  lm= 8.963  gm= 8.944 ghm= 8.917 hm= 8.889 min= 8.000

X= 9.000   Y= 10.000 
Stolarski means -------------------------
stom+infiniti= 10.000 stom2= 9.500 stom1= 9.496 stom-1= 9.487  stom0= 9.474  stom0.5= 9.474 stom-infiniti= 9.000  
-----------------------------------------
ag3= 9.667  rghm= 9.500  pom1/2= 9.4934  pom1/3= 9.491 rgm= 9.500 ahm= 9.487 hrm= 9.487 magm(x**2,y**2)= 90.250 
-----------------------------------------
max= 10.000 chm= 9.526  cm= 9.526  rms2= 9.513  pom5/3= 9.509  sm2= 9.509  pom4/3= 9.504  stom3= 9.504  nm= 9.504  am= 9.500  rhm= 9.500 im= 9.496  
      pom2/3= 9.496  herom= 9.496  sm1= 9.496  lmam= 9.496  magm= 9.4934  agm= 9.4934  lm= 9.491  gm= 9.487 ghm= 9.480 hm= 9.474 min= 9.000

X= 10.000   Y= 10.000 
Stolarski means -------------------------
stom+infiniti= 10.000 stom2= 10.000 stom1= 10.000 stom-1= 10.000  stom0= 10.000  stom0.5= 10.000 stom-infiniti= 10.000  
-----------------------------------------
ag3= 10.000  rghm= 10.000  pom1/2= 10.0000  pom1/3= 10.000 rgm= 10.000 ahm= 10.000 hrm= 10.000 magm(x**2,y**2)= 100.000 
-----------------------------------------
max= 10.000 chm= 10.000  cm= 10.000  rms2= 10.000  pom5/3= 10.000  sm2= 10.000  pom4/3= 10.000  stom3= 10.000  nm= 10.000  am= 10.000  rhm= 10.000 im= 10.000  
      pom2/3= 10.000  herom= 10.000  sm1= 10.000  lmam= 10.000  magm= 10.0000  agm= 10.0000  lm= 10.000  gm= 10.000 ghm= 10.000 hm= 10.000 min= 10.000

=======================================================================

--------------------------- Ende --------------------------------------
true.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
%
increment(State,StateN,Step) :-
    StateN is (State+Step).
%
xloop_launch(XState,XEnde,XStep,_) :-
% 	XState > XEnde,!,
	XOverTaget is (XState -(XStep/2.0)), XOverTaget > XEnde,!,
	format('~n=======================================================================~n').
%	
xloop_launch(XState,XEnde,XStep,YState) :-
	% put all mean functions there to see how they behave
	format('~n~tX= ~3f ',[XState]),
	format('~t  Y= ~3f ~n',[YState]),
 	Max is max(XState,YState),
 	am(XState,YState,Res1), 
 	agm(XState,YState,Res2), 
 	gm(XState,YState,Res3),
 	hm(XState,YState,Res4),
 	lm(XState,YState,Res5),
 	chm(XState,YState,Res6), 
 	rms2(XState,YState,Res7), 
 	magm(XState,YState,Res8), 
 	cm(XState,YState,Res9), 
  	ghm(XState,YState,Res10), 	
 	herom(XState,YState,Res11),  
 	im(XState,YState,Res12), 
 	sm2(XState,YState,Res13), 
 	nsm(XState,YState,Res14), 
 	sm1(XState,YState,Res15),
 	pom5_3(XState,YState,Res16), 
 	pom4_3(XState,YState,Res17), 
 	pom2_3(XState,YState,Res18), 
 	pom1_3(XState,YState,Res19), 
 	pom1_2(XState,YState,Res20), 
 	lehm1_3(XState,YState,Res21),
 	rghm(XState,YState,Res22), 
 	rhm(XState,YState,Res23),
        rgm(XState,YState,Res24), 
        ahm(XState,YState,Res25),
	hrm(XState,YState,Res26),
 	stom3(XState,YState,Res27), 
% 	stom(XState,YState,3,Res27), 
        ag3(XState,YState,Res28),
        lmam(XState,YState,Res29),
        em(XState,YState,Res30),
        magmxxyy(XState,YState,Res31),
        hoelm0_5(XState,YState,Res32),      
        xyhxy(XState,YState,Res33),    
        agmxyhxy(XState,YState,Res34),   
        gammap1(XState,YState,Res35),  
        %
 	Min is min(XState,YState),
 	%
%
% special values output
        format('~tSpecial values --------------------------~n'),
    	format('~txyhxy= ~4f  ',[Res33]),
	format('~tagmxyhxy= ~4f  ',[Res34]),
	format('~tgammap1= ~4f  ',[Res35]),	
        format('~n-----------------------------------------~n'),
%
% Stolarsky Mittel output
        format('~tStolarski means -------------------------~n'),
    	format('~tstom+infiniti=max= ~4f  ',[Max]),
	format('~tstom2=am= ~4f  ',[Res1]),
    	format('~tstom1=im= ~4f  ',[Res12]),
 	format('~tstom-1=gm= ~4f  ',[Res3]),
 	format('~tstom0=hm= ~4f  ',[Res4]),
 	format('~tstom0.5=hoelm0_5= ~4f  ',[Res32]),
 	format('~tstom-infiniti=min= ~4f',[Min]),
        format('~n-----------------------------------------'),
%
%
% first line of output
 	format('~n~tag3= ~4f ',[Res28]),
 	format('~trghm= ~4f ',[Res22]),
 	format('~tlehm1_3= ~4f ',[Res21]),
 	format('~tlmam= ~4f  ',[Res29]),
 	format('~tem= ~4f ~n',[Res30]),
 	format('~tsm1= ~4f  ',[Res15]),
 	format('~tpom1_3= ~4f ',[Res19]),
    	format('~trgm= ~4f ',[Res24]),
	format('~tahm= ~4f ',[Res25]),
    	format('~thrm= ~4f ',[Res26]),
    	format('~tmagmxxyy= ~4f ',[Res31]),	
%
% second line of output
        format('~n-----------------------------------------~n'),
 	format('~tmax= ~4f  ',[Max]),
 	format('~tchm= ~4f  ',[Res6]),
 	format('~tcm= ~4f  ',[Res9]),
 	format('~trms2= ~4f  ',[Res7]),
 	format('~tpom5_3= ~4f  ',[Res16]),
 	format('~tsm2= ~4f  ',[Res13]),
 	format('~tpom4_3= ~4f  ~n',[Res17]),
 	format('~t     stom3= ~4f  ',[Res27]),
 	format('~tnsm= ~4f  ',[Res14]),
 	format('~tam= ~4f  ',[Res1]),
 	format('~trhm= ~4f  ',[Res23]),
 	format('~tim= ~4f  ',[Res12]),
 	format('~tpom2_3= ~4f  ',[Res18]),
 	format('~therom= ~4f  ',[Res11]),
 	format('~tpom1_2= ~4f ',[Res20]),
 	format('~n~t     magm= ~4f  ',[Res8]),
    	format('~tagm= ~4f  ',[Res2]),
    	format('~tlm= ~4f  ',[Res5]),
    	format('~tgm= ~4f  ',[Res3]),
    	format('~tghm= ~4f  ',[Res10]),
    	format('~thm= ~4f  ',[Res4]),
    	format('~tmin= ~4f',[Min]),
    %
    	format('~n'),
	increment(XState,XNState,XStep), 
    	xloop_launch(XNState,XEnde,XStep,YState).
%
yloop_launch(_,_,_,YState,YEnde,YStep) :-
%	YState > YEnde,!,
	YOverTaget is (YState -(YStep/2.0)), YOverTaget > YEnde,!,
%
	format('~n--------------------------- Ende --------------------------------------~n').
%
yloop_launch(XStart,XEnde,XStep,YState,YEnde,YStep) :-	
	format('~n~tY= ~5f ~n',[YState]),	
	xloop_launch(XStart,XEnde,XStep,YState),
  	increment(YState,YNState,YStep), 
  	yloop_launch(XStart,XEnde,XStep,YNState,YEnde,YStep).

test_mean :- 
	XStart is 0.0, XEnde is 10.0, XSteps is 20,
		XStep is ((XEnde-XStart)/XSteps),
	YStart is 0.0, YEnde is 10.0, YSteps is 20,
		YStep is ((YEnde-YStart)/YSteps),
	format('--------------------------- Start -------------------------------------~n'),
	yloop_launch(XStart,XEnde,XStep,YStart,YEnde,YStep),!.
	
test_mean1 :- 
	XStart is 0.0, XEnde is 1.0, XSteps is 50,
		XStep is ((XEnde-XStart)/XSteps),
	YStart is 0.0, YEnde is 1.0, YSteps is 50,
		YStep is ((YEnde-YStart)/YSteps),
	format('--------------------------- Start -------------------------------------~n'),
	yloop_launch(XStart,XEnde,XStep,YStart,YEnde,YStep),!.

/* 

looping for direct comparison between 2 mean functions

*/

xloop_launch_comp(XState,XEnde,XStep,_,_,_) :-
% 	XState > XEnde,!,
	XOverTaget is (XState -(XStep/2.0)), XOverTaget > XEnde,!,
%
	format('~n======================================================================~n').
%	
xloop_launch_comp(XState,XEnde,XStep,YState,FirstM,SecondM) :-
	format('~n  ~4f ',[XState]),	% output X into a new line
	format('~t  ~4f ',[YState]),	% output Y into the same line
        GoalF =.. [FirstM,XState,YState,Res00],	
        call(GoalF),	% call it
        format('~t  ~4f ',[Res00]),	% output Z into the same line than X and Y	
        GoalS =.. [SecondM,XState,YState,Res01],	
        call(GoalS),	% call it
        format('~t  ~4f ',[Res01]),	% output Z into the same line than X and Y
	increment(XState,XNState,XStep), 
    	xloop_launch_comp(XNState,XEnde,XStep,YState,FirstM,SecondM).
%
yloop_launch_comp(_,_,_,YState,YEnde,YStep,_,_) :-
%	YState > YEnde,!,
	YOverTaget is (YState -(YStep/2.0)), YOverTaget > YEnde,!,	
%
	format('~n-------------------------- Ende --------------------------------------~n').
%
yloop_launch_comp(XStart,XEnde,XStep,YState,YEnde,YStep,FirstM,SecondM) :-	
        format('~t    X        Y        ~s       ~s',[FirstM,SecondM]),
	xloop_launch_comp(XStart,XEnde,XStep,YState,FirstM,SecondM),
  	increment(YState,YNState,YStep), 
  	yloop_launch_comp(XStart,XEnde,XStep,YNState,YEnde,YStep,FirstM,SecondM).

% test 
% comp_mean1(rgm,im).
/*
?- comp_mean1(rgm,im).
--------------------------- Start -------------------------------------
    X        Y        rgm       im
  0.0000   0.0000   0.0000   0.0000 
  0.0200   0.0000   0.0071   0.0074 
  0.0400   0.0000   0.0141   0.0147 
  0.0600   0.0000   0.0212   0.0221 
  0.0800   0.0000   0.0283   0.0294 
  0.1000   0.0000   0.0354   0.0368 
  0.1200   0.0000   0.0424   0.0441 
  0.1400   0.0000   0.0495   0.0515 
  0.1600   0.0000   0.0566   0.0589 
..
which mean (analysis)
    X        Y        rgm       ipraxis@radiologie-city-plaza.dem
  0.1800   0.0000   0.0636   0.0662 
we can see that rgm and im dont have something like rgm > im 
or im > rgm but it changes accross the spectrum 0..1

you can see this when you look at the gnuplot contour lines which
cross themself in the area
..
gnuplot> set terminal x11 persist enhanced
gnuplot> set contour  .. (default is 5)
gnuplot> set cntrparam levels 10
gnuplot> splot 'rgm.dat' with lines, 'im.dat' with lines

*/
comp_mean1(FirstM,SecondM) :- 
	XStart is 0.0, XEnde is 1.0, XSteps is 100,
		XStep is ((XEnde-XStart)/XSteps),
	YStart is 0.0, YEnde is 1.0, YSteps is 100,
		YStep is ((YEnde-YStart)/YSteps),
	format('--------------------------- Start -------------------------------------~n'),
	yloop_launch_comp(XStart,XEnde,XStep,YStart,YEnde,YStep,FirstM,SecondM),!.
/*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

test_mean1.

--------------------------- Start -------------------------------------
Y= 0.00000 

X= 0.000   Y= 0.000 
Stolarski means -------------------------
stom+infiniti= 0.000 stom2= 0.000 stom1= 0.000 stom-1= 0.000  stom0= 0.000  stom0.5= 0.000 stom-infiniti= 0.000  
-----------------------------------------
ag3= 0.000  rghm= 0.000  pom1/3= 0.000 rgm= 0.000 ahm = 0.000 hrm= 0.000 
-----------------------------------------
max= 0.000 chm= 0.000  cm= 0.000  rm= 0.000  pom5/3= 0.000  sm2= 0.000  pom4/3= 0.000  stom3= 0.000  nm= 0.000  am= 0.000  rhm= 0.000 im= 0.000  
      pom2/3= 0.000  herom= 0.000  sm1= 0.000  pom1/2= 0.0000  magm= 0.0000  agm= 0.0000  lm= 0.000  gm= 0.000 ghm= 0.000 hm= 0.000 min= 0.000

X= 0.100   Y= 0.000 
Stolarski means -------------------------
stom+infiniti= 0.100 stom2= 0.050 stom1= 0.037 stom-1= 0.000  stom0= 0.000  stom0.5= 0.000 stom-infiniti= 0.000  
-----------------------------------------
ag3= 0.000  rghm= 0.071  pom1/3= 0.013 rgm= 0.035 ahm = 0.025 hrm= 0.024 
-----------------------------------------
max= 0.100 chm= 0.100  cm= 0.079  rm= 0.071  pom5/3= 0.066  sm2= 0.064  pom4/3= 0.059  stom3= 0.058  nm= 0.057  am= 0.050  rhm= 0.047 im= 0.037  
      pom2/3= 0.035  herom= 0.033  sm1= 0.032  pom1/2= 0.0250  magm= 0.0000  agm= 0.0000  lm= 0.000  gm= 0.000 ghm= 0.000 hm= 0.000 min= 0.000

X= 0.200   Y= 0.000 
Stolarski means -------------------------
stom+infiniti= 0.200 stom2= 0.100 stom1= 0.074 stom-1= 0.000  stom0= 0.000  stom0.5= 0.000 stom-infiniti= 0.000  
-----------------------------------------
ag3= 0.000  rghm= 0.141  pom1/3= 0.025 rgm= 0.071 ahm = 0.050 hrm= 0.047 
-----------------------------------------
max= 0.200 chm= 0.200  cm= 0.159  rm= 0.141  pom5/3= 0.132  sm2= 0.127  pom4/3= 0.119  stom3= 0.115  nm= 0.113  am= 0.100  rhm= 0.094 im= 0.074  
      pom2/3= 0.071  herom= 0.067  sm1= 0.064  pom1/2= 0.0500  magm= 0.0000  agm= 0.0000  lm= 0.000  gm= 0.000 ghm= 0.000 hm= 0.000 min= 0.000

..
..

X= 0.800   Y= 1.000 
Stolarski means -------------------------
stom+infiniti= 1.000 stom2= 0.900 stom1= 0.898 stom-1= 0.894  stom0= 0.889  stom0.5= 0.889 stom-infiniti= 0.800  
-----------------------------------------
ag3= 0.933  rghm= 0.900  pom1/3= 0.896 rgm= 0.900 ahm = 0.894 hrm= 0.894 
-----------------------------------------
max= 1.000 chm= 0.911  cm= 0.911  rm= 0.906  pom5/3= 0.904  sm2= 0.904  pom4/3= 0.902  stom3= 0.902  nm= 0.902  am= 0.900  rhm= 0.900 im= 0.898  
      pom2/3= 0.898  herom= 0.898  sm1= 0.898  pom1/2= 0.8972  magm= 0.8972  agm= 0.8972  lm= 0.896  gm= 0.894 ghm= 0.892 hm= 0.889 min= 0.800

X= 0.900   Y= 1.000 
Stolarski means -------------------------
stom+infiniti= 1.000 stom2= 0.950 stom1= 0.950 stom-1= 0.949  stom0= 0.947  stom0.5= 0.947 stom-infiniti= 0.900  
-----------------------------------------
ag3= 0.967  rghm= 0.950  pom1/3= 0.949 rgm= 0.950 ahm = 0.949 hrm= 0.949 
-----------------------------------------
max= 1.000 chm= 0.953  cm= 0.953  rm= 0.951  pom5/3= 0.951  sm2= 0.951  pom4/3= 0.950  stom3= 0.950  nm= 0.950  am= 0.950  rhm= 0.950 im= 0.950  
      pom2/3= 0.950  herom= 0.950  sm1= 0.950  pom1/2= 0.9493  magm= 0.9493  agm= 0.9493  lm= 0.949  gm= 0.949 ghm= 0.948 hm= 0.947 min= 0.900

X= 1.000   Y= 1.000 
Stolarski means -------------------------
stom+infiniti= 1.000 stom2= 1.000 stom1= 1.000 stom-1= 1.000  stom0= 1.000  stom0.5= 1.000 stom-infiniti= 1.000  
-----------------------------------------
ag3= 1.000  rghm= 1.000  pom1/3= 1.000 rgm= 1.000 ahm = 1.000 hrm= 1.000 
-----------------------------------------
max= 1.000 chm= 1.000  cm= 1.000  rm= 1.000  pom5/3= 1.000  sm2= 1.000  pom4/3= 1.000  stom3= 1.000  nm= 1.000  am= 1.000  rhm= 1.000 im= 1.000  
      pom2/3= 1.000  herom= 1.000  sm1= 1.000  pom1/2= 1.0000  magm= 1.0000  agm= 1.0000  lm= 1.000  gm= 1.000 ghm= 1.000 hm= 1.000 min= 1.000

=======================================================================

--------------------------- Ende --------------------------------------

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	part for file creation
	the files are for later in gnuplot
						
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

xloop_launch_of(XState,XEnde,XStep,_,_) :-
%
% 	XState > XEnde,!,
	XOverTaget is (XState -(XStep/2.0)), XOverTaget > XEnde,!,
%
	format('~n#======================================================================~n').
%	
xloop_launch_of(XState,XEnde,XStep,YState,BaseName) :-
	format('~n  ~4f ',[XState]),	% output X into a new line
	format('~t  ~4f ',[YState]),	% output Y into the same line
% 	Max is max(XState,YState),
        atom_string(BaseWord, BaseName),  % create the atom BaseWord out of the string
        Goal =.. [BaseWord,XState,YState,Res0],	% define the goal (example) gm(XState,YState, Res0)
        call(Goal),	% call it
        format('~t  ~4f ',[Res0]),	% output Z into the same line than X and Y
	increment(XState,XNState,XStep), 
    	xloop_launch_of(XNState,XEnde,XStep,YState,BaseName).


yloop_launch_of(_,_,_,YState,YEnde,YStep,_) :-
	YOverTaget is (YState -(YStep/2.0)), YOverTaget > YEnde,!,
%        YState > YEnde,!,
%
	format('~n#-------------------------- Ende --------------------------------------~n').
%
yloop_launch_of(XStart,XEnde,XStep,YState,YEnde,YStep,BaseName) :-	
%	format('~n~n~tY= ~5f ~n',[YState]),	
	xloop_launch_of(XStart,XEnde,XStep,YState,BaseName),
  	increment(YState,YNState,YStep), 
  	yloop_launch_of(XStart,XEnde,XStep,YNState,YEnde,YStep,BaseName).

outfile_mean1 :- 
	XStart is 0.0, XEnde is 1.0, XSteps is 50,
		XStep is ((XEnde-XStart)/XSteps),
	YStart is 0.0, YEnde is 1.0, YSteps is 50,
		YStep is ((YEnde-YStart)/YSteps),
	format('#-------------------------- Start -------------------------------------~n'),
	yloop_launch_of(XStart,XEnde,XStep,YStart,YEnde,YStep,_).
%
outfile_mean1_param(BaseName) :- 
	XStart is 0.0, XEnde is 1.0, XSteps is 50,
		XStep is ((XEnde-XStart)/XSteps),
	YStart is 0.0, YEnde is 1.0, YSteps is 50,
		YStep is ((YEnde-YStart)/YSteps),
	format('#-------------------------- Start -------------------------------------~n'),
	yloop_launch_of(XStart,XEnde,XStep,YStart,YEnde,YStep,BaseName).
%
% then use gnuplot
% gnuplot> set contour
% gnuplot> set terminal x11 persist
% gnuplot> splot 'lmam.dat' 
outlmam_to_file :-
    tell('lmam.dat'),
    outfile_mean1,
    told.
%
% gnuplot> set contour
% gnuplot> set terminal x11 persist
% gnuplot> splot 'agm.dat' with lines
outagm_to_file :-
    tell('agm.dat'),
    outfile_mean1,
    told.
%
/*
X= 0.880   Y= 0.960 
Stolarski means -------------------------
stom+infiniti=max= 0.9600  stom2=am= 0.9200  stom1=im= 0.9197  stom-1=gm= 0.9191  stom0=hm= 0.9183  stom0.5=hoelm0_5= 0.9196  stom-infiniti=min= 0.8800
-----------------------------------------
ag3= 0.9333 rghm= 0.9200 pom1_2= 0.9196 lehm1_3= 0.9206 lmam= 0.9197  em= 0.9398 
sm1= 0.9197  pom1_3= 0.9194 rgm= 0.9200 ahm= 0.9191 hrm= 0.9191 magmxxyy= 0.8464 
-----------------------------------------
max= 0.9600  chm= 0.9217  cm= 0.9217  rms2= 0.9209  pom5_3= 0.9206  sm2= 0.9206  pom4_3= 0.9203  
     stom3= 0.9203  nsm= 0.9203  am= 0.9200  rhm= 0.9200  im= 0.9197  pom2_3= 0.9197  herom= 0.9197  
     magm= 0.9196  agm= 0.9196  lm= 0.9194  gm= 0.9191  ghm= 0.9187  hm= 0.9183  min= 0.8800
*/
% createfile('gm.dat').
createfile(FileName) :-
    tell(FileName),
    file_name_extension(BaseName, dat, FileName),
    outfile_mean1_param(BaseName),
    told.
%
% plot existing file
% plotfile('gm.dat').
plotfile(FileName) :-
    process_create(
        path(gnuplot),
        ['-persist'],
        [ stdin(pipe(In)),
          detached(true)
        ]
    ),
% commented out: interactivity not existing; update only after clicking on another window
%    format(In, "set terminal wxt~n", []),   
% interactivity; quality good enough
    format(In, "set terminal x11 persist enhanced~n", []),
    format(In, "set contour~n", []),
    format(In, "set cntrparam levels 10~n", []),
    format(string(GnuplotCommand), "splot '~w' with lines~n", [FileName]),
    format(In, GnuplotCommand, []),
    flush_output(In).
%
% or several files
% gnuplot> set terminal x11 persist enhanced
% gnuplot> set contour
% gnuplot> set cntrparam levels 10
% gnuplot> splot 'agm.dat' with lines, 'lmam.dat' with lines
% splot 'agm.dat' with lines, 'magmxxyy.dat' with lines, 'magmxxyy.dat' with lines
%
% 2D representation with PlantUML.. https://plantuml.com/de/command-line
%