program Truco_Paulista;

uses SysUtils;

{
feat: feature
fix: coreção
refactor: refatorar código

function NameFunction

var nameVar

type TNameType
}

const
    deckSize = 40;
    handSize  = 3;

type	
    TSuit = (nClubs, nHearts, nSpades, nDiamonds);

    TCard = record
        value : integer;
        suit : TSuit;
        isManilha : Boolean;
        isDrew : boolean;
	end;
	
    TPlayer = record
        hand : array[1..3] of TCard;
    end;
    
    TGame = record
		whichRound : byte;
		
        playerRoundPts : double;
        playerMatchPts : integer;
        
        pcRoundPts : double;
        pcMatchPts : integer;
end;

type Deck = array[0..deckSize-1] of TCard;

{VARIÁVEIS}
var 
	De, Em, Co: Deck;
    Position, Manilha: integer;
    Carta: TCard;
    player : TPlayer;
    pc : TPlayer;
	gameManager: TGame;

{TODO: list, queue and stack}

{ ===== Utils ===== }

{convert card num to truco base force of the card}
function NumToForce(card : integer) : integer;
begin
    case card of
        4 : NumToForce := 1;
        5 : NumToForce := 2;
        6 : NumToForce := 3;
        7 : NumToForce := 4;
        10: NumToForce := 5;
        11: NumToForce := 6;
        12: NumToForce := 7;
        1 : NumToForce := 8;
        2 : NumToForce := 9;
        3 : NumToForce := 10;
        else NumToForce := 0;
    end;
end;

{convert suit to the respective name in string type}
function SuitStr(n : TSuit) : string;
begin
    case n of
        nClubs : SuitStr := 'Clubs [C]';
        nHearts : SuitStr := 'Hearts [H]';
        nSpades : SuitStr := 'Spades [S]';
        nDiamonds : SuitStr := 'Diamonds [D]';
    end;
end;

{convert card value to the respective string number or face letter}
function FaceStr(card : integer) : string;
begin
    case card of
        1 : FaceStr := 'A ';
        10 : FaceStr := 'J ';
        11 : FaceStr := 'Q ';
        12 : FaceStr := 'K ';
        else FaceStr := IntToStr(card) + ' ';
    end;
end;

{formats the card into a stringwith all the info}
function CardStr(const c: TCard): string;
begin
    CardStr := FaceStr(c.value) + ' of ' + SuitStr(c.suit);
    
    if c.isManilha then CardStr := CardStr + ' *Manilha!*';
end;

{gives more value based on the card suit}
function ManilhaForce(n: TSuit): integer;
begin
    case n of
        nClubs : ManilhaForce := 4;
        nHearts : ManilhaForce := 3;
        nSpades : ManilhaForce := 2;
        nDiamonds : ManilhaForce := 1;
    end;
end;

{total force of the card}
function TotalCardForce(const c: TCard): integer;
begin
    if c.isManilha then
    begin
        TotalCardForce := 100 + ManilhaForce(c.suit);
    end
    else
    begin
        TotalCardForce := NumToForce(c.value);
    end;
end;

{next card in the sequence}
function NextCardValue(v: integer): integer;
begin
    case v of
        7 : NextCardValue :=  10;
        12 : NextCardValue := 1;
        else NextCardValue := v + 1;
    end;
end;

{
compare two cards

1 = player won
2 = pc won
0 = tie
}
function CompareCards(const playerCards, pcCards: TCard): integer;
var playerPower, pcPower: integer;
begin
    playerPower := TotalCardForce(playerCards);
    pcPower := TotalCardForce(pcCards);
  
    if playerPower > pcPower then 
        CompareCards := 1
    else if pcPower > playerPower then
        CompareCards := 2
    else
        CompareCards := 0;
end;

{ ===== Deck ====== }

{Populate Deck Function}
procedure GenerateDeck(var d:Deck; ds:integer; var p: integer);
var i,j,k:integer;
suit: array[1..4] of TSuit;
begin
	//Adicionar validação se está vazia(opcional)
	suit[1] := nDiamonds;
	suit[2] := nHearts;
	suit[3] := nSpades;
	suit[4] := nClubs;
  
	i := 0;
	for j := 1 to 4 do
	begin
		for k := 1 to 12 do
        begin
        if (k < 8) or (k > 9) then
        begin
            d[i].suit := suit[j];
            
			d[i].value := k;
            d[i].isDrew:= false;      
			i:= i + 1;
			end;
		end;
	end;
	p:= ds;
end;

//IRÁ EMBARALHAR DE FORMA ALEATÓRIA AS CARTAS
procedure ShuffleDeck(var d, e:Deck; ds:integer);
var i, n: integer;
begin
 i:=0;
 while i <= ds-1 do
  begin
   n:= random(40);
   if (d[n].isDrew = false) then
    begin
     e[i]:= d[n];
     d[n].isDrew:= true;
     i:= i+1;
    end;
	end;
end;

//CORTA O BARALHO DE FORMA ALEATÓRIA E REORGANIZA
procedure Cut(var e, f:Deck; ds:integer);
var i, c, j:integer;
begin
 c:= random(40);
 i:=0;
 for j:=c to ds-1 do
  begin
   f[i]:= e[j];
   i:=i+1;
	end;
 
 for j:=0 to c-1 do
  begin
   f[i]:= e[j];
   i:=i+1;
	end;
end;

//FUNÇÃO IRÁ COMPRAR UMA CARTA E IRÁ ORGANIZAR A FILA
function BuyCard(var f:Deck; var p:integer):TCard;
var i:integer;
begin
 BuyCard:=f[0];
 p:= p-1;
 for i:= 0 to p-1 do
    f[i] := f[i+1];
end;

//FUNÇÃO COMPRA UMA CARTA E DEFINE A MANILHA
function ViraManilha(f:Deck; var p:integer ): integer;
var Manilha:TCard;
Valor:integer;
begin
    Manilha:= BuyCard(f,p);
    Valor:= NextCardValue(Manilha.value);
    ViraManilha:= Valor;
    writeln('===================');
    Writeln('MANILHA É: ', Valor);
    writeln('===================');
end;

//FUNÇÃO PARA JOGAR AS CARTAS PARA CADA JOGADOR
procedure Distribuir_Carta(var f:Deck; var PL, PC:TPlayer; var p:integer);
var i, ipl, ipc:integer;
begin
 ipl:=1;
 ipc:=1;
 for i:=1 to 6 do
 begin
  if i mod 2 = 0 then
   begin
    PL.hand[ipl]:= BuyCard(f,p);
    ipl:= ipl + 1;
	 end
	else
	 begin
	  PC.hand[ipc]:= BuyCard(f,p);
	  ipc:= ipc+1;
	 end; 
 end;
end;

//FUNCAO PARA VERIFICAR SE ALGUÉM DOS JOGADORES POSSUI MANILHA
procedure Verifica_Manilha(var P:TPlayer; var Valor:integer);
var i:integer;
begin
 for i:=1 to 3 do
  if P.hand[i].value = Valor then
   P.hand[i].isManilha := True
  else 
   P.hand[i].isManilha := False;
end;
//RESETA O ISDREW PARA PODER EMBARALHAR NORMALMENTE.
procedure ResetDeck(var d: Deck);
var
  i: integer;
begin
  for i := 0 to deckSize - 1 do
    d[i].isDrew := false;
end;

{ == Game Logic === }
    
procedure ShowPlayerHand(const hand: array of TCard);
var i : integer;
begin
    writeln;
    
    for i := 1 to 3 do
        writeln(' - [', i, '] ', CardStr(hand[i]));
end;

procedure ShowScore;
begin
    writeln;
    writeln('Score match >> Player: ', gameManager.playerMatchPts,
	' | PC: ', gameManager.pcMatchPts);
    writeln;
    writeln('Score round >> Player: ', gameManager.playerRoundPts,
	' | PC: ', gameManager.pcMatchPts);
	writeln;
end;

function ChoosePCCard(var round: integer) : TCard;
var i, currentCard: integer;
var high, low, mid : TCard;

begin
    high.value := 0;
    high.suit := nDiamonds;
    low := pc.hand[1];
    
    for i := 1 to 2 do
    begin
        currentCard := TotalCardForce(pc.hand[i]);
        
        if currentCard > TotalCardForce(high) then high := pc.hand[i]
        
        else if currentCard < TotalCardForce(low) then low := pc.hand[i]
        
        else mid := pc.hand[i];
        
        
    end;
    
    case round of
        1: ChoosePCCard := high;
        2: ChoosePCCard := low;
        3: ChoosePCCard := mid;
    end;
end;

{
    0 = Tie
    1 = player Won
    2 = pc Won
}
function ChooseWinner(round: byte): byte;
var diff: double;
begin
    diff := gameManager.playerRoundPts - gameManager.pcRoundPts;
    
    if round = 3 then
    begin
        
        if diff = 0.5 then ChooseWinner := 1
        
        else if diff = -0.5  then ChooseWinner := 2
        
        else ChooseWinner := 0;
    end 
    else if round = 2 then
    begin
        
        if diff = 2.5 then ChooseWinner := 1
        
        else if diff = -2.5  then ChooseWinner := 2
        
        else ChooseWinner := 0;
    end;
end;
{implementation}
begin
    
end.
