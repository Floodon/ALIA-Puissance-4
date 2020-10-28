% ** Retourne la longueur de la liste **
longueur([],0).
longueur([_|T],L):- longueur(T,L1),L is L1+1.

% ** Retourne vrai si la liste H au dÃ©but de L **
prefixe(H,L):-append(H,_,L).

% ** Retourne si ML est une sous-liste de L **
sousliste(ML,L):-prefixe(ML,L). % si ML au dÃ©but de L
sousliste(ML,[_|T]):-sousliste(ML,T).

% * Retourne le Nième élement de la liste L *
element(N, L, []):- longueur(L, N1), N1 < N.
element(N, L, X):- nth1(N, L, X).

% * Retourne si le joueur J a gagné sur une colonne *
gagnerColonne(J, [H|_]) :- sousliste([J,J,J,J], H).
gagnerColonne(J, [_|T]) :- T \== [], gagnerColonne(J, T).

% ** Retourne si le joueur J à gagner sur la ligne Y
gagnerLigne(J, Y, G):- maplist(nth1(Y),G,L), sousliste([J,J,J,J], L).

gagnerLignes(J, G):- gagnerLigne(J, Y, G), Y>0, Y<7.

% Regarder si le joueur J a gagnÃ©
% 1. Les colonnes
gagner(J, G):- gagnerColonne(J, G).

% 2. Les lignes
gagner(J,G):- gagnerLignes(J,G).

% 3.1. Recherche les diagonales (type \) dans G
gagner(J,G):- sousliste([C1,C2,C3,C4], G), % Recup 4 colonnes
		   element(I1,C1,J), % qui contiennent J
                   I2 is I1+1,
                   element(I2,C2,J),
                   I3 is I2+1,
		   element(I3,C3,J),

                   I4 is I3+1,
		   element(I4,C4,J).
                   % Et chacun sont sur une meme diagonale \


% 3.2. Recherche les diagonales (type /) dans G
gagner(J,G):- sousliste([C1,C2,C3,C4], G), % Recup 4 colonnes
		   element(I1,C1,J), % qui contiennent J
                   I2 is I1-1,
                   element(I2,C2,J),
                   I3 is I2-1,
		   element(I3,C3,J),
                   I4 is I3-1,
		   element(I4,C4,J).
                   % Et chacun sont sur une meme diagonale /

%Afficher gagnant
afficherGagnant(J):- write("Le joueur "),write(J),write(" a gagne"),nl.


% Affiche La grille L
affiche([],L) :- afficheColonne(L,0,0),nl,nl,nl,nl,nl.
affiche([H|T],L) :- reverse(H,R), append(L,[R],L2), affiche(T,L2).

afficheColonne(_,_,6).
afficheColonne(L,7,B) :- nl, B1 is B+1, afficheColonne(L,0,B1).
afficheColonne([[H1|T1]|T],A,B) :- H1\==[],H1 == 1, write("X"), append(T,[T1],L), A1 is A+1, afficheColonne(L,A1,B).
afficheColonne([[H1|T1]|T],A,B) :- H1\==[],H1 == 2, write("O"), append(T,[T1],L), A1 is A+1, afficheColonne(L,A1,B).
afficheColonne([[H1|T1]|T],A,B) :- H1\==[],H1 == 0, write("."), append(T,[T1],L), A1 is A+1, afficheColonne(L,A1,B).



% Compte le nombre N de de zero dans L avec count(L,N)
compter([],0).
compter([0|T],N) :- compter(T,N1), N is N1 + 1.
compter([X|T],N) :- X \== 0, compter(T,N).

% Ajoute en fin de colonne
ajouterEnFin(X,[0|T],[X|T]).
ajouterEnFin(X,[],[X]).
ajouterEnFin(X,[H|L1],[H|L2]):- H\==0, ajouterEnFin(X,L1,L2).

% Essaie d'ajouter l'élément X Ã  la colonne C
ajouter(C,_,C) :- compter(C,0).
ajouter(C,X,A) :- compter(C,N), N \== 0,ajouterEnFin(X,C,A).

% Q renvoi la liste passé en premier paramatre mais la colonne X est changée par la colonne C
changeColonne([],_,_,G1,8,G1).
changeColonne([H|T], X, C, G1, N,Q) :- N \== X, append(G1,[H],G2), N1 is N+1, changeColonne(T,X,C,G2,N1,Q).
changeColonne([_|T], X, C, G1, X,Q) :- append(G1,[C],G2), N1 is X+1, changeColonne(T,X,C,G2,N1,Q).

%test maxList
max_l([X],X) :- !, true.
max_l([X|Xs], M):- max_l(Xs, M), M >= X.
max_l([X|Xs], X):- max_l(Xs, M), X >  M.

% heuristque min-max statique
minmaxStatique(JoueurJouant,Grille,Grille1) :- MMS=[[3,4,5,5,4,3,-1],[4,6,8,8,6,4,-1],[5,8,11,11,8,5,-1],[7,10,13,13,10,7,-1],[5,8,11,11,8,5,-1],[4,6,8,8,6,4,-1],[3,4,5,5,4,3,-1]], heuristiqueMMS(Grille,_,MMS,Grille1,JoueurJouant).

%G la grille du jeu, L la ligne MinMax jouable, MMS le tableau MinMaxStatique
heuristiqueMMS(G,L,MMS,G1,JoueurJouant) :- length(L,T), T < 7,J is T+1, %Trouve l'indice de la colone sur laquelle on travail
                                        joueurOppose(JoueurJouant,JoueurOppose),jouerMove(JoueurJouant, G, J, G2),testMovePourGagner(JoueurOppose, G2,_), %Vérifie si jouer dans cette colonne offre un coup gagnant
                                        nth1(J,G,C), compter(C,N) ,nth1(J,MMS,Cbis),I is 7-N,nth1(I,Cbis,E), %Trouve la case du tableau MMS correspondant
                                        ajouterEnFin(E,L,L1),heuristiqueMMS(G,L1,MMS,G1,JoueurJouant). %Ajoute la valeur au tableau, refais un appel a lui meme
heuristiqueMMS(G,L,MMS,G1,JoueurJouant) :- length(L,T), T < 7,ajouterEnFin(-1,L,L1),heuristiqueMMS(G,L1,MMS,G1,JoueurJouant).
heuristiqueMMS(G,L,_,G1,JoueurJouant) :- max_l(L,X),nth1(I,L,X),jouerMove(JoueurJouant, G, I, G1).


lancerJeu(_) :- G=[[0,0,0,0,0,0], [0,0,0,0,0,0], [0,0,0,0,0,0], [0,0,0,0,0,0], [0,0,0,0,0,0], [0,0,0,0,0,0], [0,0,0,0,0,0]], affiche(G,[]), heuristique1(G). % ajouter l'appel à la premiÃ¨re heuristique

heuristique1(G) :- gagner(1,G).
heuristique1(G) :- gagner(2,G).
heuristique1(G) :- finis(G).
heuristique1(G) :- movePourGagner(1, G, G1),
    write("1 joue pour gagner : "), nl,
    affiche(G1,[]),
    afficherGagnant(1).

heuristique1(G) :- movePourEmpecherGagner(1, 2, G, G1),
    write("1 joue pour empecher de gagner 2 : "), nl,
    affiche(G1,[]),
    heuristique2(G1).

%heuristique1(G) :- heuristiqueRandomAvecAnticipation(1,G,G1),
%    write("RandomAvecAnticipation (1) joue"), nl,
%    affiche(G1,[]),
%    heuristique2(G1).

%heuristique1(G) :- heuristiqueRandom(1, G, G1),
%    write("Random (2) joue "), nl,
%    affiche(G1,[]),
%    heuristique2(G1).

heuristique1(G) :- minmaxStatique(1, G, G1),
    write("MinMax (1) joue "), nl,
    affiche(G1,[]),
    heuristique2(G1).

heuristique2(G) :- gagner(1,G).
heuristique2(G) :- gagner(2,G).
heuristique2(G) :- finis(G).
heuristique2(G) :- movePourGagner(2, G, G1),
    write("2 joue pour gagner : "), nl,
    affiche(G1,[]),
    afficherGagnant(2).
heuristique2(G) :- movePourEmpecherGagner(2, 1, G, G1),
    write("2 joue pour empecher de gagner 1 : "), nl,
    affiche(G1,[]),
    heuristique1(G1).

heuristique2(G) :- heuristiqueRandomAvecAnticipation(2,G,G1),
    write("RandomAvecAnticipation (2) joue"), nl,
    affiche(G1,[]),
    heuristique1(G1).

heuristique2(G) :- heuristiqueRandom(2, G, G1),
    write("Random (2) joue"), nl,
    affiche(G1,[]),
    heuristique1(G1).


jouerJoueur1(G) :- write("Joue, J1 :"), read(L), nth1(L,G,C), ajouter(C, 1, C1), changeColonne(G,L,C1,[],1,G1), affiche(G1,[]), heuristique2(G1). % gagnant(), jouerJoueur2().

jouerJoueur2(G) :- write("Joue, J2 :"), read(L), nth1(L,G,C), ajouter(C, 2, C1), changeColonne(G,L,C1,[],1,G1), affiche(G1,[]), heuristique1(G1).

% joue l'heuristique random J joueur (1 ou 2), G grille
heuristiqueRandom(Joueur, Grille, Grille1) :- random_between(1,7,Index), nth1(Index,Grille,Colonne), compter(Colonne,Count), joueRandom(Joueur, Grille, Index, Count, Colonne, Grille1).

% joue un coup random
joueRandom(Joueur, Grille, Index, Count, Colonne, Grille1) :- Count\==0,
    ajouter(Colonne, Joueur, Colonne1),
    changeColonne(Grille,Index,Colonne1,[],1,Grille1).
joueRandom(Joueur, Grille, _, 0, _, Grille1) :- heuristiqueRandom(Joueur, Grille, Grille1).

% joue un coup random qui ne mene pas � la victoire de l'adversaire
heuristiqueRandomAvecAnticipation(Joueur, Grille, Grille1) :- joueurOppose(Joueur, JoueurOp), heuristiqueRandom(Joueur, Grille, Grille1), testMovePourGagner(JoueurOp, Grille1, _).

test(Joueur, Grille, Grille1) :- joueurOppose(Joueur, JoueurOp), nth1(3,Grille,Colonne), compter(Colonne,Count), joueRandom(Joueur, Grille, 3, Count, Colonne, Grille1) , testMovePourGagner(JoueurOp, Grille1, X), X == 0.

%renvoi le joueur oppose
joueurOppose(1,2).
joueurOppose(2,1).


% Cree la grille G1 a partir de G dans laquelle le joueur J a joue la

% colonne L, si possible.
jouerMove(J, G, L, G1) :- nth1(L,G,C), compter(C,Y), Y\==0, ajouter(C, J, C1), changeColonne(G,L,C1,[],1,G1).

% la colonne C ferrai gagner le joueur J joue un move pour gagner si possible

movePourGagner(Joueur, Grille, Grille1) :- jouerMove(Joueur, Grille, _, Grille1),
    gagner(Joueur, Grille1).

% renvoi false si possibilite de gagner et true autrement
testMovePourGagner(Joueur, Grille, G) :- movePourGagner(Joueur, Grille, G), !, fail.
testMovePourGagner(_Joueur, _Grille, _G).

movePourEmpecherGagner(JoueurJouant, JoueurAdverse, Grille, Grille1) :- jouerMove(JoueurAdverse, Grille, Coup, Grille2),
    gagner(JoueurAdverse, Grille2),
    jouerMove(JoueurJouant, Grille, Coup, Grille1).

% Check si la grille est complete
finis([]) :- write("Fini : match nul").
finis([H|T]) :- compter(H,Y), Y==0, finis(T).




