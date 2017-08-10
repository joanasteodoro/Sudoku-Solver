%Joana Teodoro - 86440
%Logica para Programacao

%----------------------------------------------- SOLUCIONADOR DE PROBLEMAS DE SUDOKU -----------------------------------------------

:-include('SUDOKU').

%-----------------------------------------------------------------------------------------------------------------------------------

/*  -------- PREDICADOS PARA A PROPAGACAO DE MUDANCAS -------- */

%tira_num_aux/4
%predicado auxiliar que retira um numero Num de um puzzle Puz da posicao Pos

tira_num_aux(Num, Puz, Pos, N_Puz):-
	puzzle_ref(Puz, Pos, Cont),
	delete(Cont, Num, N_Cont),
	\+ Cont = N_Cont,
    puzzle_muda_propaga(Puz, Pos, N_Cont, N_Puz).

tira_num_aux(_, Puz, _, N_Puz):-
	N_Puz = Puz.

%tira_num/4
%predicado que retira de todas as posicoes em Posicoes o num Num do puzzle Puz

tira_num(Num, Puz, Posicoes, N_Puz):-
	percorre_muda_Puz(Puz, tira_num_aux(Num), Posicoes, N_Puz).

%puzzle_muda_propaga/4
%predicado que muda para a posicao Pos o novo conteudo N_Cont do puzzle Puz e propaga a mudanca para as posicoes relacionadas,
%isto e, retira o numero usando tira_num caso este exista nestas posicoes
%se o novo conteudo N_Cont for o mesmo qu estava anteriormente, muda, nao alterando nada, mas nao propaga

puzzle_muda_propaga(Puz, Pos, N_Cont, N_Puz):-
	puzzle_muda(Puz, Pos, N_Cont, Res),
	length(N_Cont, 1),
	nth1(1, N_Cont, El),
	posicoes_relacionadas(Pos, Posicoes),
	tira_num(El, Res, Posicoes, N_Puz),!.

puzzle_muda_propaga(Puz, Pos, N_Cont, N_Puz):-
	puzzle_muda(Puz, Pos, N_Cont, N_Puz).

%-----------------------------------------------------------------------------------------------------------------------------------

/*  -------- PREDICADOS PARA A INICIALIZACAO DE MUDANCAS -------- */

%possibilidades/3
%Poss e uma lista de possibilidades na posicao Pos do puzzle Puz

possibilidades(Pos, Puz, Poss):-
	puzzle_ref(Puz, Pos, Cont),
	length(Cont, 1),
	Poss = Cont.

possibilidades(Pos, Puz, Poss):-
	numeros(L),
	posicoes_relacionadas(Pos, Posicoes),
	conteudos_posicoes(Puz, Posicoes, Conteudos),
	junta_conteudos_unitarios(Conteudos, Res, []),
	subtract(L, Res, Poss).

%junta_conteudos_unitarios/3
%predicado auxiliar iterativo do possibilidades que junta os conteudos das posicoes

junta_conteudos_unitarios([], Res, Res).
junta_conteudos_unitarios([P|R], Res, Ac):-
	length(P, 1),
	append(P, Ac, Ac_aux),
	junta_conteudos_unitarios(R, Res, Ac_aux).

junta_conteudos_unitarios([_|R], L, Res):-
	junta_conteudos_unitarios(R, L, Res).

%inicializa_aux/3
%predicado auxiliar que inicializa a posicao Pos do puzzle Puz

inicializa_aux(Puz, Pos, N_Puz):-
	possibilidades(Pos, Puz, Poss),
	puzzle_muda_propaga(Puz, Pos, Poss, N_Puz).

%inicializa/2
%inicializa todo o puzzle Puz, colocando em todas as posicoes deste as possibilidades

inicializa(Puz, N_Puz):-
	todas_posicoes(Todas_Posicoes),
	percorre_muda_Puz(Puz, inicializa_aux, Todas_Posicoes, N_Puz), !.

%-----------------------------------------------------------------------------------------------------------------------------------

/*  -------- PREDICADOS PARA A INSPECAO DE PUZZLES -------- */

%so_aparece_uma_vez/4
%verifica se existe algum nUmero que apenas ocorre numa das posicoes de uma linha, coluna ou bloco

so_aparece_uma_vez(_, _, [],_).
so_aparece_uma_vez(Puz, Num, [P|R], Pos_Num):-
	puzzle_ref(Puz, P, Cont),
	\+member(Num, Cont),
	so_aparece_uma_vez(Puz, Num, R, Pos_Num).

so_aparece_uma_vez(Puz, Num, [P|R], Pos_Num):-
	Pos_Num = P,
	so_aparece_uma_vez(Puz, Num, R, Pos_Num).

%inspecciona_num/4
%inspecciona se o numero Num so aparece uma vez nas posicoes guardadas em Posicoes
%caso apareca, retorna a sua posicao. Senao falha, retornando false

inspecciona_num(Posicoes, Puz, Num, N_Puz):-
	so_aparece_uma_vez(Puz, Num, Posicoes, Pos_Num),
	puzzle_muda_propaga(Puz, Pos_Num, [Num], N_Puz).

inspecciona_num(_, Puz, _, N_Puz):-
	Puz = N_Puz.

%inspecciona_grupo/3 
%inspecciona cada numero possivel, de acordo com a dimensao do puzzle, para as posicoes do grupo Gr e caso o numero
%so apareca uma vez, muda-o para essa posicao e propaga a mudanca 

inspecciona_grupo(_,[],_).
inspecciona_grupo(Puz, Gr, N_Puz):-
	numeros(L),
	percorre_muda_Puz(Puz, inspecciona_num(Gr), L, N_Puz).
	
%inspecciona/2
%inspecciona todo o puzzle Puz a partir de todos os seus grupos recorrendo as funcoes auxiliares definidas acima, retornando
%o puzzle resultante desta inspecao

inspecciona(Puz, N_Puz):-
	grupos(Gr),
	percorre_muda_Puz(Puz, inspecciona_grupo, Gr, N_Puz), !.

%-----------------------------------------------------------------------------------------------------------------------------------

/*  -------- PREDICADOS PARA A VERIFICACAO DE SOLUCOES -------- */

%grupo_correcto/3
%verifica se o conteudo de cada posicao de Gr corresponde a um numero da lista de numeros Nums, sem repeticoes

grupo_correcto(Puz, Nums, Gr):-
	conteudos_posicoes(Puz, Gr, Conteudos),
	append(Conteudos, Lista_Conteudos_Desordenados),
	same_length(Nums, Lista_Conteudos_Desordenados),
	sort(Lista_Conteudos_Desordenados, Lista_Conteudos_Ordenados),
	Lista_Conteudos_Ordenados = Nums.

%solucao/1
%retorna true ou false consoante se o puzzle Puz e uma solucao

solucao(Puz):-
	grupos(Gr),
 	numeros(L),
 	verify_gr(Puz, L, Gr).

%verify_gr/3
%predicado auxiliar de solucao para verificar se cada grupo do puzzle Puz esta correto

verify_gr(_, _, []).
verify_gr(Puz, L, [P|R]):-
 	grupo_correcto(Puz, L, P),
 	verify_gr(Puz, L, R).

%escolhe_pos/2
%predicado que vai sempre escolher a primeira posicao nao unitaria do puzzle Puz

escolhe_pos(Puz, Posicao):-
	todas_posicoes(Todas_Posicoes),
	member(Pos, Todas_Posicoes),
	puzzle_ref(Puz, Pos, Cont),
	\+length(Cont, 1),
	Posicao = Pos, !.

%encontra_sol/3
%predicado auxiliar que encontra uma solucao Sol para o puzzle Puz, retornando-a para o predicado resolve

encontra_sol(Puz, Sol):-
	procura(Puz, P_Resultante), 
	verifica_conts(P_Resultante),
	P_Resultante = Sol.

encontra_sol(Puz, Sol):-
	procura(Puz, P_Resultante),
	encontra_sol(P_Resultante, Sol).

%procura/2
%predicado auxiliar que faz a procura dos numeros possiveis numa posicao nao unitaria do puzzle Puz sendo P_Resultante 
%o puzzle resultante dessa procura

procura(Puz, P_Resultante):-
	escolhe_pos(Puz, Pos),
	puzzle_ref(Puz, Pos, Cont),
	member(Num, Cont), 
	puzzle_muda_propaga(Puz, Pos, [Num], P_Resultante).

%continua_procura/2
%predicado auxiliar que caso o puzzle ainda nao contenha todas as posicoes unitarias continua a procura nas nao unitarias

continua_procura(Puz, Sol):-
	encontra_sol(Puz, Sol), !.

%verifica_conts/1
%predicado auxiliar que verifica se todos os conteudos do puzzle Puz sao unitarios, ou seja, sendo 81 o total dos conteudos
%quando a dimensao e 9x9

verifica_conts(Puz):-
	todas_posicoes(Todas_Posicoes),
	conteudos_posicoes(Puz, Todas_Posicoes, Conteudos),
	Numero_Posicoes_Puz = 81,
	append(Conteudos, List_Conteudos),
	length(List_Conteudos, Numero_Posicoes_Puz).

%resolve/2
%predicado que resolve um puzzle Puz, sendo Sol uma ou a solucao

resolve(Puz, Sol):-
	inicializa(Puz, Res),
	inspecciona(Res, N_Puz),
	verifica_conts(N_Puz),
	N_Puz = Sol, !.

resolve(Puz, Sol):-
	inicializa(Puz, Res),
	inspecciona(Res, N_Puz),
	encontra_sol(N_Puz, Sol).


%---------------------------------------------------------------- FIM --------------------------------------------------------------
