program Truco_Paulista;

uses SysUtils, crt;

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
        weight : integer;
        suit : TSuit;
        isManilha : Boolean;
        isDrew : boolean;
	end;
	
    TPlayer = record
        hand : array[1..3] of TCard;
    end;
    
    TGame = record
		whichround : byte;
		
		turnedCard : TCard;
		currentManilha : integer;
		
		roundWeight: integer;
		
        playerRoundPts : double;
        playerMatchPts : integer;
        
        pcRoundPts : double;
        pcMatchPts : integer;
end;

type Deck = array[0..deckSize-1] of TCard;

{VARIÁVEIS}
var 
	d, suffled, Co: Deck;
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

{convert card weight to the respective string number or face letter}
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
    CardStr := FaceStr(c.weight) + ' of ' + SuitStr(c.suit);
    
    if c.isManilha then CardStr := CardStr + ' *Manilha!*';
end;

{gives more weight based on the card suit}
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
        TotalCardForce := NumToForce(c.weight);
    end;
end;

{next card in the sequence}
function NextCardweight(v: integer): integer;
begin
    case v of
        7 : NextCardweight :=  10;
        12 : NextCardweight := 1;
        else NextCardweight := v + 1;
    end;
end;

{ compare two cards

+0.5 if on first to give the first round advantage

1 = player won
2 = pc won
0 = tie
}
function CompareCards(const playerCards, pcCards: TCard): integer;
var playerPower, pcPower, sum: integer;
begin
    playerPower := TotalCardForce(playerCards);
    pcPower := TotalCardForce(pcCards);
        
    if playerPower > pcPower then sum := 1
    else if pcPower > playerPower then sum := 2
    else sum := 0;
        
    CompareCards := sum;
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
            
			d[i].weight := k;
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
    Valor:= NextCardweight(Manilha.weight);
    ViraManilha:= Valor;
    writeln('===================');
    writeln('THE MANILHA IS: ', Valor);
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
procedure Verifica_Manilha(var P:TPlayer);
var i:integer;
begin
 for i:=1 to 3 do
  if P.hand[i].weight = gameManager.currentManilha then
   P.hand[i].isManilha := True
  else 
   P.hand[i].isManilha := False;
end;
//RESETA O IS DREW PARA PODER EMBARALHAR NORMALMENTE.
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
    begin
        if hand[i].isDrew = false then
        begin
            writeln(' - [', i, '] ', CardStr(hand[i]));
        end;
    end;
end;

procedure ShowScore;
begin
    writeln;
    writeln('Score match >> Player: ', gameManager.playerMatchPts,
	' | PC: ', gameManager.pcMatchPts);
    writeln;
    writeln('Score round >> Player: ', gameManager.playerRoundPts:0:0,
	' | PC: ', gameManager.pcRoundPts:0:0);
	writeln;
end;

function ChoosePCcard(var round: integer) : integer;
var i, currentCard : integer;
    high, low, mid : TCard;
begin
    high.weight := 0;
    low.weight := pc.hand[1].weight;
    
    for i := 1 to 2 do
    begin
        currentCard := TotalCardForce(pc.hand[i]);
        
        if currentCard > TotalCardForce(high) then high.weight := pc.hand[i].weight
        
        else if currentCard < TotalCardForce(low) then low.weight := pc.hand[i].weight
        
        else mid.weight := pc.hand[i].weight;
    end;
    
    case round of
        1: ChoosePCcard := high.weight;
        2: ChoosePCcard := low.weight;
        3: ChoosePCcard := mid.weight;
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

function NegotiateTruco(currentWeight, whoCalled : integer) : integer;
var nextWeight, choice: integer;
begin
    if currentWeight < 12 then
    begin
        case currentWeight of
            1: nextWeight := 3;
            else nextWeight := currentWeight + 3;
        end;
        
        if whoCalled = 1 then
        {Player called}
        begin
            case nextWeight of
              3 : writeln('  >> You called TRUCO!  (proposal: 3 points)');
              6 : writeln('  >> You called for SIX!  (proposal: 6 points)');
              9 : writeln('  >> You called for NINE!  (proposal: 9 points)');
              12 : writeln('  >> You called for TWELVE!  (proposal: 12 points)');
            end;
            
            writeln('Computer  is choosing...');
            if random(10) <= 7 then
            begin
                writeln(' > ACCEPTED! <');
                writeln;
                writeln('Now the hand is worth ', nextWeight);
                
                NegotiateTruco := nextWeight;
            end;
        end
        else
        begin
            writeln('  Computer  RAN AWAY! You won! ', currentWeight, ' points(s).');
            NegotiateTruco := -currentWeight;
        end;
      end
      else
      begin
        {Computer called}
        case nextWeight of
          3 : writeln('  >> Computer called TRUCO!  (proposal: 3 points)');
          6 : writeln('  >> Computer called for SIX!  (proposal: 6 points)');
          9 : writeln('  >> Computer called for NINE!  (proposal: 9 points)');
          12: writeln('  >> Computer called for TWELVE!  (proposal: 12 points)');
        end;
        
        writeln('  What do you do?');
        writeln('    > 1 - Accept  (', nextWeight, ' points)');
        
        writeln('    > 2 - Run   (computer wins ', currentWeight, ' point(s))');
        
        if nextWeight < 12 then
            writeln('    > 3 - Call for more (call for ', nextWeight + 3, ' points)');
            
        repeat
            write('  Your choice: ');
            readln(choice);
        until (choice = 1) or (choice = 2) or (choice = 3);
    
        case choice of
            1:
            begin
                writeln('  You accept! now this hand worth: ', nextWeight, ' points.');
                NegotiateTruco := nextWeight;
            end;
            
            2:
            begin
                writeln('  You ran away! Computer won ', currentWeight, ' point(s).');
                NegotiateTruco := -currentWeight;
            end;
            
            3:
            begin
                writeln('  You re-called! Asked for ', nextWeight + 3, ' points...');
                
                if Random(10) <= 5 then
                begin
                    writeln('  Computer ACCEPTED the re-call! now this hand worth: ', nextWeight + 3, ' points.');
                    NegotiateTruco := nextWeight + 3;
                end
                else
                begin
                    writeln('  Computer RAN AWAY from the re-call! You won ', nextWeight, ' point(s).');
                    NegotiateTruco := -nextWeight;
                end;
            end;
        end;
    end;
end;

{plays one hand (3 rounds).
return 1 if player won, 2 if pc won}
function PlayHand: Integer;
var
    handWinner, handWeight, resp, round, IdxP, IdxC, firstToGo : Integer;
    cardPlayer, cardPc : TCard;
    isOnTruco : Boolean;
    choice : String;
begin
    handWeight := 1;
    isOnTruco := False;
    firstToGo := 1 + Random(2);
    handWinner := 0;
    
    clrscr;
    writeln;
    writeln('========================================');
    writeln('             NEW HAND                   ');
    writeln('========================================');

    {Iron hand rules}
    if (gameManager.playerMatchPts = 11) and (gameManager.pcMatchPts = 11) then
    begin
        writeln('  *** IRON HAND both with 11 points ***');
        writeln('  Who wins the round wins the match!');
        handWeight := 3;
    end
    else if gameManager.playerMatchPts = 11 then
    begin
        writeln('  *** 11 POINT HAND! You are with 11 points***');
        writeln('  If you win the round you win the match! If you lose, the opponent receives 3 points.');
        writeln;
        writeln('  Turned card: ', CardStr(gameManager.turnedCard));
        ShowPlayerHand(player.hand);
        writeln;
        writeln('  You want to play this hand?');
        writeln('       y?  or  n?');
        repeat
            write('  > ');
            readln(choice);
        until (choice = 'y') or (choice = 'n');
            if choice = 'n' then
            begin
                writeln('  You forfeight, Computer receives 3 points.');
                gameManager.pcMatchPts := gameManager.pcMatchPts + 3;
                PlayHand := 2;
            end;
            
        handWeight := 3;
    end
    else if gameManager.pcMatchPts = 11 then
    begin
        writeln('  *** 11 POINT HAND! You are with 11 points***');
        writeln('  Computer decided to play this hand.');
        handWeight := 3;
    end;

    writeln;
    writeln('  Turned card: ', CardStr(gameManager.turnedCard));
    
    {round loops}
    round := 0;
    while (round < 3) and (handWinner = 0) do
    begin
        round := round + 1;
        writeln;
        writeln('========================================');
        writeln('  -------- round: ', round, ' --------');
        ShowPlayerHand(player.hand);
        ShowScore;
        
        { Computer can call Truco before the player (30% chance) }
        if (not isOnTruco) and (handWeight < 12) and
           (not ((gameManager.playerMatchPts = 11) or (gameManager.pcMatchPts = 11))) and
           (Random(10) <= 3) then
        begin
            writeln;
            resp := NegotiateTruco(handWeight, 2);
            if resp < 0 then
            begin
                gameManager.pcMatchPts := gameManager.pcMatchPts - resp;
                PlayHand := 2;
            end;
            handWeight := resp;
            isOnTruco := True;
        end;
        
    { Player plays card or calls for truco }
    IdxP := 0;
    repeat
        writeln;
        if (not isOnTruco) and (handWeight < 12) and
            (not ((gameManager.playerMatchPts = 11) or (gameManager.pcMatchPts = 11))) then
            writeln('  Type the card number or T to call for a truco:')
        else
            writeln('  Type the card number:');
        write('  > ');
        readln(choice);
            
        if (choice = 'T') and
            (not isOnTruco) and (handWeight < 12) and
            (not ((gameManager.playerMatchPts = 11) or (gameManager.pcMatchPts = 11))) then
        begin
            resp := NegotiateTruco(handWeight, 1);
            
            if resp < 0 then
            begin
                gameManager.playerMatchPts := gameManager.playerMatchPts - resp;
                PlayHand := 1;
            end;
            
            handWeight := resp;
            isOnTruco := True;
            ShowPlayerHand(player.hand);
        end
        else
        begin
            IdxP := StrToIntDef(choice, 0);
            if (IdxP < 1) or (IdxP > 3) then
            begin
                writeln('  You can not do this now, try again.');
                IdxP := 0;
            end;
        end;
    until IdxP >= 1;
    
        player.hand[IdxP].isDrew := true;
        
        {Computer chooses}
        IdxC := ChoosePCcard(round);
        pc.hand[IdxC].isDrew := true;
        
        cardPlayer := player.hand[IdxP];
        cardPc := pc.hand[IdxC];
        
        writeln;
        writeln('  You played: ', CardStr(cardPlayer));
        writeln('  PC Played: ', CardStr(cardPc));
        
        handWinner := CompareCards(cardPlayer, cardPc);
        writeln;
        case handWinner of
            1: begin 
                writeln('  >>> You won the hand!');
                    
                gameManager.playerRoundPts := gameManager.playerRoundPts + 1;
                    
                if round = 1 then
                    gameManager.playerRoundPts := gameManager.playerRoundPts + 0.5;
                    
                firstToGo := 1;
            end;
            
            2: begin 
                writeln('  >>> Computer won the hand!');
                    
                gameManager.pcRoundPts := gameManager.pcRoundPts + 1;
                    
                if round = 1 then
                    gameManager.pcRoundPts := gameManager.pcRoundPts + 0.5;
                    
                firstToGo := 2;
            end;
            
            0: writeln('  >>> Hand ended as a Tie!');
        end;
            
        if round >= 2 then
            handWinner := ChooseWinner(round);
    end;
        
    if handWinner = 0 then
        handWinner := ChooseWinner(round);
        
    writeln;
    writeln('  ====================================');
    if handWinner = 1 then
    begin
        writeln('  YOU WON THIS HAND!  +', handWeight, ' point(s)');
        gameManager.playerMatchPts := gameManager.playerMatchPts + handWeight;
    end
    else
    begin
        writeln('  COMPUTER WON THIS HAND!  +', handWeight, ' point(s)');
        gameManager.pcMatchPts := gameManager.pcMatchPts + handWeight;
    end;
    writeln('  ====================================');
    
    gameManager.playerRoundPts := 0;
    gameManager.pcRoundPts := 0;

    PlayHand := handWinner;
end;

procedure PrepareHand;
begin
    {todo implementar funções de inicialização}
end;

{implementation}
begin
  gameManager.pcMatchPts := 0;
  gameManager.pcMatchPts := 0;
  gameManager.pcRoundPts := 0;
  gameManager.pcRoundPts := 0;

  writeln('=======================================================');
  writeln('                   WELCOME TO TRUCO!                   ');
  writeln('=======================================================');
  writeln;
  writeln('    Clubs [C] > Hearts [H] > Spades [S] > Diamonds [D]');
  writeln;
  writeln(' > Card forces:');
  writeln('    4 < 5 < 6 < 7 < J < Q < K < A < 2 < 3');
  writeln;
  writeln('  Press ENTER to initiate...');
  readln;

  while (gameManager.playerMatchPts < 12) and (gameManager.pcMatchPts < 12) do
  begin
    PrepareHand;
    PlayHand;
    ShowScore;

    if (gameManager.playerMatchPts < 12) and (gameManager.pcMatchPts < 12) then
    begin
      writeln;
      writeln('  Press ENTER for the next hand...');
      readln;
    end;
  end;

  writeln;
  writeln('==========================================');
  if gameManager.playerMatchPts >= 12 then
    writeln('    CONGRATS! YOU WON THE GAME!')
  else
    writeln('    COMPUTER WON! Try again.');
  writeln;
  writeln('  Final score board:');
  writeln('    You        : ', gameManager.playerMatchPts, ' points');
  writeln('    Computer   : ', gameManager.pcMatchPts, ' points');
  writeln('==========================================');
  writeln;
  writeln('  Press any key to exit the program...');
  readln;
end.
