program TrucoGauchao;

{$mode objfpc}{$H+}

uses SysUtils;

const
  MAX_BARALHO = 40;
  CARTAS_MAO  = 3;

type
  TNaipe = (nOuros, nEspadas, nCopas, nPaus);

  TCarta = record
    Valor    : Integer;  { 1=A, 2..7, 10=J(Sota), 11=Q(Cavalo), 12=K(Rei) }
    Naipe    : TNaipe;
    EhManilha: Boolean;
  end;

  { ===== PILHA - baralho embaralhado ===== }
  TPilha = record
    Itens: array[0..MAX_BARALHO - 1] of TCarta;
    Topo : Integer;  { -1 = vazia }
  end;

  { ===== FILA - corte e distribuicao ===== }
  TFila = record
    Itens   : array[0..MAX_BARALHO - 1] of TCarta;
    Inicio  : Integer;
    Fim     : Integer;
    Tamanho : Integer;
  end;

  { ===== LISTA - mao dos jogadores ===== }
  TLista = record
    Itens     : array[0..CARTAS_MAO - 1] of TCarta;
    Quantidade: Integer;
  end;

{ ================================================================= }
{                         PILHA (Stack)                             }
{ ================================================================= }

procedure InicializarPilha(var P: TPilha);
begin
  P.Topo := -1;
end;

function PilhaVazia(const P: TPilha): Boolean;
begin
  Result := P.Topo < 0;
end;

procedure EmpilharCarta(var P: TPilha; const C: TCarta);
begin
  if P.Topo < MAX_BARALHO - 1 then
  begin
    Inc(P.Topo);
    P.Itens[P.Topo] := C;
  end;
end;

function DesempilharCarta(var P: TPilha; out C: TCarta): Boolean;
begin
  if not PilhaVazia(P) then
  begin
    C := P.Itens[P.Topo];
    Dec(P.Topo);
    Result := True;
  end
  else
    Result := False;
end;

{ ================================================================= }
{                          FILA (Queue)                             }
{ ================================================================= }

procedure InicializarFila(var F: TFila);
begin
  F.Inicio  := 0;
  F.Fim     := 0;
  F.Tamanho := 0;
end;

function FilaVazia(const F: TFila): Boolean;
begin
  Result := F.Tamanho = 0;
end;

procedure EnfileirarCarta(var F: TFila; const C: TCarta);
begin
  if F.Tamanho < MAX_BARALHO then
  begin
    F.Itens[F.Fim] := C;
    F.Fim := (F.Fim + 1) mod MAX_BARALHO;
    Inc(F.Tamanho);
  end;
end;

function DesenfileirarCarta(var F: TFila; out C: TCarta): Boolean;
begin
  if not FilaVazia(F) then
  begin
    C := F.Itens[F.Inicio];
    F.Inicio := (F.Inicio + 1) mod MAX_BARALHO;
    Dec(F.Tamanho);
    Result := True;
  end
  else
    Result := False;
end;

{ ================================================================= }
{                       LISTA (List)                                }
{ ================================================================= }

procedure InicializarLista(var L: TLista);
begin
  L.Quantidade := 0;
end;

procedure AdicionarCartaLista(var L: TLista; const C: TCarta);
begin
  if L.Quantidade < CARTAS_MAO then
  begin
    L.Itens[L.Quantidade] := C;
    Inc(L.Quantidade);
  end;
end;

function RemoverCartaLista(var L: TLista; Idx: Integer; out C: TCarta): Boolean;
var
  I: Integer;
begin
  if (Idx >= 0) and (Idx < L.Quantidade) then
  begin
    C := L.Itens[Idx];
    for I := Idx to L.Quantidade - 2 do
      L.Itens[I] := L.Itens[I + 1];
    Dec(L.Quantidade);
    Result := True;
  end
  else
    Result := False;
end;

{ ================================================================= }
{                     UTILITARIOS DE CARTA                          }
{ ================================================================= }

function NaipeStr(N: TNaipe): String;
begin
  case N of
    nPaus   : Result := 'Paus    [P]';
    nCopas  : Result := 'Copas   [C]';
    nEspadas: Result := 'Espadas [E]';
    nOuros  : Result := 'Ouros   [O]';
  end;
end;

function ValorStr(V: Integer): String;
begin
  case V of
    1 : Result := 'A ';
    10: Result := 'J ';
    11: Result := 'Q ';
    12: Result := 'K ';
    else Result := IntToStr(V) + ' ';
  end;
end;

function CartaStr(const C: TCarta): String;
begin
  Result := ValorStr(C.Valor) + 'de ' + NaipeStr(C.Naipe);
  if C.EhManilha then
    Result := Result + '  *MANILHA*';
end;

{ Forca base da carta (ordem do Truco): 4<5<6<7<J<Q<K<A<2<3 }
function ForcaBase(V: Integer): Integer;
begin
  case V of
    4 : Result := 1;
    5 : Result := 2;
    6 : Result := 3;
    7 : Result := 4;
    10: Result := 5;   { Sota (J) }
    11: Result := 6;   { Cavalo (Q) }
    12: Result := 7;   { Rei (K) }
    1 : Result := 8;   { As }
    2 : Result := 9;
    3 : Result := 10;
    else Result := 0;
  end;
end;

{ Forca da manilha pelo naipe: Paus > Copas > Espadas > Ouros }
function ForcaManilhaNaipe(N: TNaipe): Integer;
begin
  case N of
    nPaus   : Result := 4;
    nCopas  : Result := 3;
    nEspadas: Result := 2;
    nOuros  : Result := 1;
  end;
end;

{ Forca total para comparacao em rodada }
function ForcaCarta(const C: TCarta): Integer;
begin
  if C.EhManilha then
    Result := 100 + ForcaManilhaNaipe(C.Naipe)
  else
    Result := ForcaBase(C.Valor);
end;

{ Proximo valor na sequencia de cartas (para calcular a manilha) }
function ProximoValorCarta(V: Integer): Integer;
begin
  case V of
    1 : Result := 2;
    2 : Result := 3;
    3 : Result := 4;
    4 : Result := 5;
    5 : Result := 6;
    6 : Result := 7;
    7 : Result := 10;
    10: Result := 11;
    11: Result := 12;
    12: Result := 1;
    else Result := 0;
  end;
end;

{ Compara duas cartas: retorna 1=jogador venceu, 2=computador venceu, 0=empate }
function CompararCartas(const CJ, CC: TCarta): Integer;
var
  FJ, FC: Integer;
begin
  FJ := ForcaCarta(CJ);
  FC := ForcaCarta(CC);
  if FJ > FC then Result := 1
  else if FC > FJ then Result := 2
  else Result := 0;
end;

{ ================================================================= }
{                       BARALHO                                     }
{ ================================================================= }

{ Monta o baralho espanhol (40 cartas: sem 8, 9 e coringa) na pilha }
procedure InicializarBaralho(var P: TPilha);
const
  Naipes : array[0..3] of TNaipe  = (nOuros, nEspadas, nCopas, nPaus);
  Valores: array[0..9] of Integer = (1, 2, 3, 4, 5, 6, 7, 10, 11, 12);
var
  C   : TCarta;
  N, V: Integer;
begin
  InicializarPilha(P);
  C.EhManilha := False;
  for N := 0 to 3 do
    for V := 0 to 9 do
    begin
      C.Naipe := Naipes[N];
      C.Valor := Valores[V];
      EmpilharCarta(P, C);
    end;
end;

{ Embaralha usando Fisher-Yates sobre o array interno da pilha }
procedure EmbaralharBaralho(var P: TPilha);
var
  I, J: Integer;
  Tmp : TCarta;
begin
  for I := P.Topo downto 1 do
  begin
    J := Random(I + 1);
    Tmp := P.Itens[I];
    P.Itens[I] := P.Itens[J];
    P.Itens[J] := Tmp;
  end;
end;

{ Corta o baralho e transfere para a fila (principio de fila) }
procedure CortarBaralho(var P: TPilha; var F: TFila);
var
  Total, Corte, I: Integer;
begin
  InicializarFila(F);
  Total := P.Topo + 1;
  Corte := (Total div 4) + Random(Total div 2);
  { Segunda metade vai para a fila primeiro (parte de cima do baralho cortado) }
  for I := Corte to Total - 1 do
    EnfileirarCarta(F, P.Itens[I]);
  { Depois a primeira metade (parte de baixo) }
  for I := 0 to Corte - 1 do
    EnfileirarCarta(F, P.Itens[I]);
  InicializarPilha(P);
end;

{ Distribui 3 cartas para cada jogador e vira a ultima carta (principio de fila) }
procedure DistribuirCartas(var F: TFila;
                            var MaoJ, MaoC: TLista;
                            out Vira: TCarta);
var
  I: Integer;
  C: TCarta;
begin
  InicializarLista(MaoJ);
  InicializarLista(MaoC);
  { Distribuicao alternada: 1 para jogador, 1 para computador, repete 3x }
  for I := 1 to 3 do
  begin
    DesenfileirarCarta(F, C);
    AdicionarCartaLista(MaoJ, C);
    DesenfileirarCarta(F, C);
    AdicionarCartaLista(MaoC, C);
  end;
  { Ultima carta virada define a manilha }
  DesenfileirarCarta(F, Vira);
end;

{ Marca as manilhas nas maos com base na carta virada }
procedure DefinirManilhas(var MaoJ, MaoC: TLista; const Vira: TCarta);
var
  ValMan, I: Integer;
begin
  ValMan := ProximoValorCarta(Vira.Valor);
  for I := 0 to MaoJ.Quantidade - 1 do
    MaoJ.Itens[I].EhManilha := (MaoJ.Itens[I].Valor = ValMan);
  for I := 0 to MaoC.Quantidade - 1 do
    MaoC.Itens[I].EhManilha := (MaoC.Itens[I].Valor = ValMan);
end;

{ ================================================================= }
{                       LOGICA DO JOGO                              }
{ ================================================================= }

var
  Pilha           : TPilha;
  Fila            : TFila;
  MaoJogador      : TLista;
  MaoComputador   : TLista;
  Vira            : TCarta;
  PontosJogador   : Integer;
  PontosComputador: Integer;

procedure ExibirMaoJogador(const L: TLista);
var
  I: Integer;
begin
  WriteLn('  Suas cartas:');
  for I := 0 to L.Quantidade - 1 do
    WriteLn('    [', I + 1, '] ', CartaStr(L.Itens[I]));
end;

procedure ExibirPlacar;
begin
  WriteLn('');
  WriteLn('  Placar >> Voce: ', PontosJogador, ' ponto(s)  |  Computador: ',
          PontosComputador, ' ponto(s)');
end;

{ IA: escolhe a menor carta que venca o adversario; se nao der, joga a menor }
function EscolherCartaComputador(var MaoC: TLista;
                                  const CAdv: TCarta;
                                  JogarDepois: Boolean): Integer;
var
  I, MelhorVenc, IdxMenor: Integer;
  FMelhorVenc, FMenor, FA: Integer;
begin
  if JogarDepois then
  begin
    MelhorVenc  := -1;
    FMelhorVenc := 999;
    IdxMenor    := 0;
    FMenor      := 999;
    for I := 0 to MaoC.Quantidade - 1 do
    begin
      FA := ForcaCarta(MaoC.Itens[I]);
      if FA < FMenor then
      begin
        FMenor  := FA;
        IdxMenor := I;
      end;
      if (FA > ForcaCarta(CAdv)) and (FA < FMelhorVenc) then
      begin
        FMelhorVenc := FA;
        MelhorVenc  := I;
      end;
    end;
    if MelhorVenc >= 0 then
      Result := MelhorVenc
    else
      Result := IdxMenor;
  end
  else
    Result := Random(MaoC.Quantidade);  { Computador joga primeiro: carta aleatoria }
end;

{ Determina o vencedor da mao com base nos resultados das rodadas.
  VencRod[i]: 0=empate, 1=jogador, 2=computador.
  Retorna 0 se ainda nao ha vencedor (precisa de mais rodadas). }
function DeterminarVencedorMao(const VencRod: array of Integer; Rodada: Integer): Integer;
begin
  Result := 0;

  if Rodada >= 2 then
  begin
    { Jogador ganhou as duas }
    if (VencRod[1] = 1) and (VencRod[2] = 1) then begin Result := 1; Exit; end;
    { Jogador ganhou a 1a e empatou a 2a }
    if (VencRod[1] = 1) and (VencRod[2] = 0) then begin Result := 1; Exit; end;
    { Empatou a 1a e jogador ganhou a 2a }
    if (VencRod[1] = 0) and (VencRod[2] = 1) then begin Result := 1; Exit; end;
    { Computador ganhou as duas }
    if (VencRod[1] = 2) and (VencRod[2] = 2) then begin Result := 2; Exit; end;
    { Computador ganhou a 1a e empatou a 2a }
    if (VencRod[1] = 2) and (VencRod[2] = 0) then begin Result := 2; Exit; end;
    { Empatou a 1a e computador ganhou a 2a }
    if (VencRod[1] = 0) and (VencRod[2] = 2) then begin Result := 2; Exit; end;
    { Cada um ganhou uma rodada OU duas rodadas empatadas -> precisa da 3a }
  end;

  if Rodada = 3 then
  begin
    if VencRod[3] = 1 then begin Result := 1; Exit; end;
    if VencRod[3] = 2 then begin Result := 2; Exit; end;
    { Empate na 3a rodada: quem ganhou a 1a vence }
    if VencRod[1] = 1 then Result := 1
    else if VencRod[1] = 2 then Result := 2
    else Result := 1;  { Empate total: quem comecou a mao vence (desempate) }
  end;
end;

{ Negociacao de truco.
  ValorAtual : valor corrente da mao antes da proposta (1, 3, 6 ou 9)
  QuemPediu  : 1=jogador  2=computador
  Retorno    : > 0 = novo valor aceito
               < 0 = adversario correu; |retorno| = pontos que o proponente ganha }
function NegociarTruco(ValorAtual, QuemPediu: Integer): Integer;
var
  ProxVal: Integer;
  Resp   : Integer;
  Linha  : String;
begin
  case ValorAtual of
    1: ProxVal := 3;
    3: ProxVal := 6;
    6: ProxVal := 9;
    9: ProxVal := 12;
    else ProxVal := 3;
  end;

  if QuemPediu = 1 then
  begin
    { ----- Jogador propos; computador responde ----- }
    case ProxVal of
      3 : WriteLn('  >> Voce pediu TRUCO!  (proposta: 3 pontos)');
      6 : WriteLn('  >> Voce pediu SEIS!   (proposta: 6 pontos)');
      9 : WriteLn('  >> Voce pediu NOVE!   (proposta: 9 pontos)');
      12: WriteLn('  >> Voce pediu DOZE!   (proposta: 12 pontos)');
    end;
    WriteLn('  Computador esta pensando...');
    { IA aceita com 70% de probabilidade }
    if Random(10) < 7 then
    begin
      WriteLn('  Computador ACEITOU! Mao vale ', ProxVal, ' pontos.');
      Result := ProxVal;
    end
    else
    begin
      WriteLn('  Computador CORREU! Voce ganha ', ValorAtual, ' ponto(s).');
      Result := -ValorAtual;
    end;
  end
  else
  begin
    { ----- Computador propos; jogador responde ----- }
    case ProxVal of
      3 : WriteLn('  >> Computador pediu TRUCO!  (', ProxVal, ' pontos)');
      6 : WriteLn('  >> Computador pediu SEIS!   (', ProxVal, ' pontos)');
      9 : WriteLn('  >> Computador pediu NOVE!   (', ProxVal, ' pontos)');
      12: WriteLn('  >> Computador pediu DOZE!   (', ProxVal, ' pontos)');
    end;
    WriteLn('  O que voce faz?');
    WriteLn('    1 - Aceitar  (mao vale ', ProxVal, ' pontos)');
    if ProxVal < 12 then
      WriteLn('    2 - Re-trucar (propor ', ProxVal + 3, ' pontos)');
    WriteLn('    3 - Correr   (computador ganha ', ValorAtual, ' ponto(s))');

    repeat
      Write('  Sua escolha: ');
      ReadLn(Linha);
      Resp := StrToIntDef(Trim(Linha), 0);
    until (Resp = 1) or ((Resp = 2) and (ProxVal < 12)) or (Resp = 3);

    case Resp of
      1:
      begin
        WriteLn('  Voce aceitou! Mao vale ', ProxVal, ' pontos.');
        Result := ProxVal;
      end;
      2:
      begin
        WriteLn('  Voce re-trucou! Propondo ', ProxVal + 3, ' pontos...');
        { IA aceita re-truco com 50% de chance }
        if Random(10) < 5 then
        begin
          WriteLn('  Computador ACEITOU o re-truco! Mao vale ', ProxVal + 3, ' pontos.');
          Result := ProxVal + 3;
        end
        else
        begin
          WriteLn('  Computador CORREU do re-truco! Voce ganha ', ProxVal, ' ponto(s).');
          Result := -ProxVal;  { jogador recebe o valor que o computador havia proposto }
        end;
      end;
      3:
      begin
        WriteLn('  Voce correu! Computador ganha ', ValorAtual, ' ponto(s).');
        Result := -ValorAtual;
      end;
    end;
  end;
end;

{ Joga uma mao completa (ate 3 rodadas).
  Retorna 1 se o jogador venceu, 2 se o computador venceu. }
function JogarMao: Integer;
var
  ValorMao      : Integer;
  VencRod       : array[0..3] of Integer;  { indice 1..3 }
  Rodada        : Integer;
  CJ, CC        : TCarta;
  IdxJ, IdxC    : Integer;
  PrimJ         : Integer;  { quem joga primeiro na rodada: 1=jogador, 2=computador }
  TrucoFoiPedido: Boolean;
  VencedorMao   : Integer;
  Resp          : Integer;
  Linha         : String;
begin
  ValorMao       := 1;
  TrucoFoiPedido := False;
  PrimJ          := 1 + Random(2);
  VencedorMao    := 0;
  VencRod[1]     := 0;
  VencRod[2]     := 0;
  VencRod[3]     := 0;

  WriteLn('');
  WriteLn('========================================');
  WriteLn('             NOVA MAO                   ');
  WriteLn('========================================');

  { ---- Regras especiais de mao de 11 e mao de ferro ---- }
  if (PontosJogador = 11) and (PontosComputador = 11) then
  begin
    WriteLn('  *** MAO DE FERRO! Ambos com 11 pontos! ***');
    WriteLn('  Quem ganhar esta mao, vence o jogo!');
    ValorMao := 3;
  end
  else if PontosJogador = 11 then
  begin
    WriteLn('  *** MAO DE 11! Voce esta com 11 pontos ***');
    WriteLn('  Se vencer, ganha o jogo. Se perder, computador ganha 3 pontos.');
    WriteLn('');
    WriteLn('  Vira: ', CartaStr(Vira));
    ExibirMaoJogador(MaoJogador);
    WriteLn('');
    WriteLn('  Deseja jogar esta mao?  1=Sim  2=Desistir');
    repeat
      Write('  > ');
      ReadLn(Linha);
      Resp := StrToIntDef(Trim(Linha), 0);
    until (Resp = 1) or (Resp = 2);
    if Resp = 2 then
    begin
      WriteLn('  Voce desistiu. Computador ganha 3 pontos.');
      Inc(PontosComputador, 3);
      Result := 2;
      Exit;
    end;
    ValorMao := 3;
  end
  else if PontosComputador = 11 then
  begin
    WriteLn('  *** MAO DE 11! Computador esta com 11 pontos ***');
    WriteLn('  Computador decidiu jogar a mao.');
    ValorMao := 3;
  end;

  WriteLn('');
  WriteLn('  Vira: ', CartaStr(Vira));

  { ---- Loop de rodadas ---- }
  Rodada := 0;
  while (Rodada < 3) and (VencedorMao = 0) do
  begin
    Inc(Rodada);
    WriteLn('');
    WriteLn('  -------- Rodada ', Rodada, ' --------');
    ExibirMaoJogador(MaoJogador);
    ExibirPlacar;

    { Computador pode pedir truco antes do jogador agir (30% de chance) }
    if (not TrucoFoiPedido) and (ValorMao < 12) and
       (not ((PontosJogador = 11) or (PontosComputador = 11))) and
       (Random(10) < 3) then
    begin
      WriteLn('');
      Resp := NegociarTruco(ValorMao, 2);
      if Resp < 0 then
      begin
        Inc(PontosComputador, -Resp);
        Result := 2;
        Exit;
      end;
      ValorMao       := Resp;
      TrucoFoiPedido := True;
    end;

    { Jogador escolhe uma carta ou pede truco }
    IdxJ := -1;
    repeat
      WriteLn('');
      if (not TrucoFoiPedido) and (ValorMao < 12) and
         (not ((PontosJogador = 11) or (PontosComputador = 11))) then
        WriteLn('  Digite o numero da carta OU  T  para pedir truco:')
      else
        WriteLn('  Digite o numero da carta:');
      Write('  > ');
      ReadLn(Linha);
      Linha := UpperCase(Trim(Linha));

      if (Linha = 'T') and
         (not TrucoFoiPedido) and (ValorMao < 12) and
         (not ((PontosJogador = 11) or (PontosComputador = 11))) then
      begin
        Resp := NegociarTruco(ValorMao, 1);
        if Resp < 0 then
        begin
          Inc(PontosJogador, -Resp);
          Result := 1;
          Exit;
        end;
        ValorMao       := Resp;
        TrucoFoiPedido := True;
        ExibirMaoJogador(MaoJogador);
      end
      else
      begin
        IdxJ := StrToIntDef(Linha, 0) - 1;
        if (IdxJ < 0) or (IdxJ >= MaoJogador.Quantidade) then
        begin
          WriteLn('  Opcao invalida. Tente novamente.');
          IdxJ := -1;
        end;
      end;
    until IdxJ >= 0;

    RemoverCartaLista(MaoJogador, IdxJ, CJ);

    { Computador escolhe carta }
    IdxC := EscolherCartaComputador(MaoComputador, CJ, (PrimJ = 1));
    RemoverCartaLista(MaoComputador, IdxC, CC);

    WriteLn('');
    WriteLn('  Voce jogou   : ', CartaStr(CJ));
    WriteLn('  Computador   : ', CartaStr(CC));

    VencRod[Rodada] := CompararCartas(CJ, CC);
    WriteLn('');
    case VencRod[Rodada] of
      1: begin WriteLn('  >>> Voce venceu a rodada!'); PrimJ := 1; end;
      2: begin WriteLn('  >>> Computador venceu a rodada!'); PrimJ := 2; end;
      0: WriteLn('  >>> Empate nesta rodada!');
    end;

    if Rodada >= 2 then
      VencedorMao := DeterminarVencedorMao(VencRod, Rodada);
  end;

  { Caso ainda sem vencedor apos o loop }
  if VencedorMao = 0 then
    VencedorMao := DeterminarVencedorMao(VencRod, Rodada);

  WriteLn('');
  WriteLn('  ====================================');
  if VencedorMao = 1 then
  begin
    WriteLn('  VOCE VENCEU A MAO!  +', ValorMao, ' ponto(s)');
    Inc(PontosJogador, ValorMao);
  end
  else
  begin
    WriteLn('  COMPUTADOR VENCEU A MAO!  +', ValorMao, ' ponto(s)');
    Inc(PontosComputador, ValorMao);
  end;
  WriteLn('  ====================================');

  Result := VencedorMao;
end;

{ Prepara uma nova mao: embaralha, corta, distribui e define manilhas }
procedure PrepararMao;
begin
  InicializarBaralho(Pilha);    { 1. Monta baralho na pilha (lista sem ordenacao) }
  EmbaralharBaralho(Pilha);     { 2. Embaralha usando Fisher-Yates sobre a pilha   }
  CortarBaralho(Pilha, Fila);   { 3. Corta e transfere para a fila                 }
  DistribuirCartas(             { 4. Distribui usando principio de fila             }
    Fila, MaoJogador, MaoComputador, Vira);
  DefinirManilhas(              { 5. Marca manilhas com base na vira                }
    MaoJogador, MaoComputador, Vira);
end;

{ ================================================================= }
{                       PROGRAMA PRINCIPAL                          }
{ ================================================================= }

begin
  Randomize;
  PontosJogador    := 0;
  PontosComputador := 0;

  WriteLn('==========================================');
  WriteLn('      BEM-VINDO AO TRUCO GAUCHO!          ');
  WriteLn('  Baralho espanhol de 40 cartas (sem 8,   ');
  WriteLn('  9 e coringa).  Objetivo: 12 pontos.     ');
  WriteLn('==========================================');
  WriteLn('');
  WriteLn('  Hierarquia de manilhas (maior para menor):');
  WriteLn('    Paus [P] > Copas [C] > Espadas [E] > Ouros [O]');
  WriteLn('');
  WriteLn('  Forca das cartas (sem manilha, menor para maior):');
  WriteLn('    4 < 5 < 6 < 7 < J < Q < K < A < 2 < 3');
  WriteLn('');
  WriteLn('  Pressione ENTER para comecar...');
  ReadLn;

  while (PontosJogador < 12) and (PontosComputador < 12) do
  begin
    PrepararMao;
    JogarMao;
    ExibirPlacar;

    if (PontosJogador < 12) and (PontosComputador < 12) then
    begin
      WriteLn('');
      WriteLn('  Pressione ENTER para a proxima mao...');
      ReadLn;
    end;
  end;

  WriteLn('');
  WriteLn('==========================================');
  if PontosJogador >= 12 then
    WriteLn('    PARABENS! VOCE VENCEU O JOGO!')
  else
    WriteLn('    COMPUTADOR VENCEU! Tente novamente.');
  WriteLn('');
  WriteLn('  Placar final:');
  WriteLn('    Voce        : ', PontosJogador, ' pontos');
  WriteLn('    Computador  : ', PontosComputador, ' pontos');
  WriteLn('==========================================');
  WriteLn('');
  WriteLn('  Pressione ENTER para sair...');
  ReadLn;
end.
