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
    deckSize = 39;
    handSize = 3;

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
		
        playerRoundPts : real;
        playerMatchPts : integer;
        
        pcRoundPts : real;
        pcMatchPts : integer;
end;

type Deck = array[0..deckSize] of TCard;

{VARIÁVEIS}
var 
	initial, shuffled, cutted: Deck;
    position: integer;
    player : TPlayer;
    pc : TPlayer;
	gameManager: TGame;

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
        1 : FaceStr := 'A';
        10 : FaceStr := 'J';
        11 : FaceStr := 'Q';
        12 : FaceStr := 'K';
        else FaceStr := IntToStr(card);
    end;
end;

{formats the card into a stringwith all the info}
function CardStr(var c: TCard): string;
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
function TotalCardForce(var c: TCard): integer;
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
function NextCardWeight(v: integer): integer;
begin
    case v of
        7 : NextCardWeight :=  10;
        12 : NextCardWeight := 1;
        else NextCardWeight := v + 1;
    end;
end;

{ compare two cards

+0.5 if on first to give the first round advantage

1 = player won
2 = pc won
0 = tie
}
function CompareCards(var playerCards, pcCards: TCard): integer;
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
        if (k <> 8) and (k <> 9) then
        begin
            d[i].suit := suit[j];
			d[i].weight := k;
            d[i].isDrew:= false;
            d[i].isManilha:=false;
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
 while i <= ds do
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
 for j:=c to ds do
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
 
 for i:= 0 to p-1 do
    f[i] := f[i+1];
    
 p:= p-1;
end;

//FUNÇÃO COMPRA UMA CARTA E DEFINE A MANILHA
procedure DefineManilha(var f:Deck; var p:integer);
begin
    gameManager.turnedCard := BuyCard(f,p);
    
    gameManager.currentManilha:= NextCardWeight(gameManager.turnedCard.weight);
    
end;

//FUNÇÃO PARA JOGAR AS CARTAS PARA CADA JOGADOR
procedure DealCards(var f:Deck; var PL, PC:TPlayer; var p:integer);
var i, ipl, ipc:integer;
begin
 ipl:=1;
 ipc:=1;
 for i:=1 to 6 do
 begin
  if i mod 2 <> 0 then
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
procedure VerifyManilhaHand(var P:TPlayer);
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
    
procedure ShowPlayerHand(player: TPlayer);
var i : integer;
begin
    writeln;
        
    for i := 1 to 3 do
    begin
        if player.hand[i].isDrew <> true then
        begin
            if player.hand[i].weight = gameManager.CurrentManilha then
                writeln(' - [', i, '] ', FaceStr(player.hand[i].weight),
                    ' of ', SuitStr(player.hand[i].suit),'  **MANILHA**')
                
            else
                writeln(' - [', i, '] ', FaceStr(player.hand[i].weight),
                    ' of ', SuitStr(player.hand[i].suit));
        end;
    end;
end;

procedure esc(d:Deck; p:integer);
var i:integer;
begin
 for i:= 0 to p do
  writeln('Card in position ',i,' ', d[i].weight,' of ',SuitStr(d[i].suit));
 writeln;
end;

procedure PrepareHands;
begin
    GenerateDeck(initial, deckSize, position);
    ShuffleDeck(initial, shuffled, deckSize);
    Cut(shuffled, cutted, deckSize);
    DealCards(cutted, player, pc, position);
    DefineManilha(cutted, position);
    
    VerifyManilhaHand(player);
    VerifyManilhaHand(pc);
end;

procedure ShowScore;
begin
    writeln;
    writeln('Score match >> Player: ', gameManager.playerMatchPts,
	    ' | PC: ', gameManager.pcMatchPts);
    writeln;
    writeln('Score round >> Player: ', gameManager.playerRoundPts:0:1,
	    ' | PC: ', gameManager.pcRoundPts:0:1);
	writeln;
end;

function ChoosePCcard(var round: integer) : integer;
var i, currentCard, highIdx, lowIdx, midIdx : integer;
begin
    highIdx := 1;
    lowIdx := 1;
    midIdx := 1;
    
    for i := 1 to 3 do
    begin
        if pc.hand[i].isDrew then continue;
        currentCard := TotalCardForce(pc.hand[i]);
        
        if currentCard > TotalCardForce(pc.hand[highIdx]) then highIdx := i
        else if currentCard < TotalCardForce(pc.hand[lowIdx]) then lowIdx := i
        else midIdx := i;
    end;
    
    case round of
        1: ChoosePCcard := highIdx;
        2: ChoosePCcard := lowIdx;
        3: ChoosePCcard := midIdx;
    end;
end;

{
    0 = Tie
    1 = player Won
    2 = pc Won
}
function ChooseWinner(round: byte): byte;
var diff: real;
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

function NegotiateTruco(currentWeight, whoCalled : integer; var winner: integer) : integer;
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
                
                winner := 0;
                NegotiateTruco := nextWeight;
            end
            else
            begin
                writeln('  Computer  RAN AWAY! You won! ', currentWeight, ' points(s).');
                
                winner := 1;
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
                    
                    winner := 0;
                    NegotiateTruco := nextWeight;
                end;
                
                2:
                begin
                    writeln('  You ran away! Computer won ', currentWeight, ' point(s).');
                    
                    winner := 2;
                    NegotiateTruco := -currentWeight;
                end;
                
                3:
                begin
                    writeln('  You re-called! Asked for ', nextWeight + 3, ' points...');
                    
                    if Random(10) <= 5 then
                    begin
                        writeln('  Computer ACCEPTED the re-call! now this hand worth: ', nextWeight + 3, ' points.');
                        
                        winner := 0;
                        NegotiateTruco := nextWeight + 3;
                    end
                    else
                    begin
                        writeln('  Computer RAN AWAY from the re-call! You won ', nextWeight, ' point(s).');
                        
                        winner := 1;
                        NegotiateTruco := -nextWeight;
                    end;
                end;
            end;
        end;
    end;
end;

{
    plays one hand (3 rounds).
    return 1 if player won, 2 if pc won
}
procedure PlayHand;
var
    handWinner, handWeight, resp, round, IdxP, IdxC, roundResult, whoWon: Integer;
    cardPlayer, cardPc : TCard;
    isOnTruco : Boolean;
    choice : String;
begin
    handWeight := 1;
    isOnTruco := False;
    handWinner := 0;
    gameManager.playerRoundPts := 0;
    gameManager.pcRoundPts := 0;
    
    PrepareHands;
    
    //clrscr;
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
        ShowPlayerHand(player);
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
                
                handWinner := 2;
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
        writeln('  -------- Round: ', round, ' --------');
        ShowPlayerHand(player);
        ShowScore;
        
        { Computer can call Truco before the player (30% chance) }
        if (not isOnTruco) and (handWeight < 12) and
           (not ((gameManager.playerMatchPts = 11) or (gameManager.pcMatchPts = 11))) and
           (Random(10) <= 3) then
        begin
            writeln;
            resp := NegotiateTruco(handWeight, 2, whoWon);
            
            if resp < 0 then
            begin
                handWinner := whoWon;
                handWeight := -resp;
            end
            else
            begin
                handWeight := resp;
                isOnTruco := True;
            end;
        end;
        
        { Player plays card or calls for truco }
        if handWinner <= 0 then
        begin
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
                    resp := NegotiateTruco(handWeight, 1, whoWon);
                    
                    if resp < 0 then
                    begin
                        handWinner := whoWon;
                        handWeight := -resp;
                    end
                    else
                    begin
                        handWeight := resp;
                        isOnTruco := True;
                        ShowPlayerHand(player);
                    end;
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
            until (IdxP >= 1) or (handWinner <> 0);
            
            if handWinner = 0 then
            begin
                player.hand[IdxP].isDrew := true;
                    
                {Computer chooses}
                IdxC := ChoosePCcard(round);
                pc.hand[IdxC].isDrew := true;
                cardPc := pc.hand[IdxC];
                    
                cardPlayer := player.hand[IdxP];
                cardPc := pc.hand[IdxC];
                    
                writeln;
                writeln('  You played: ', CardStr(cardPlayer));
                writeln('  PC Played: ', CardStr(cardPc));
                    
                roundResult := CompareCards(cardPlayer, cardPc);
                writeln;
                case roundResult of
                    1: begin
                        writeln('  >>> You won the round!');
                        gameManager.playerRoundPts := gameManager.playerRoundPts + 1;
                        if round = 1 then
                            gameManager.playerRoundPts := gameManager.playerRoundPts + 0.5;
                    end;
                    2: begin
                        writeln('  >>> Computer won the round!');
                        gameManager.pcRoundPts := gameManager.pcRoundPts + 1;
                        if round = 1 then
                            gameManager.pcRoundPts := gameManager.pcRoundPts + 0.5;
                    end;
                    0: writeln('  >>> Round ended as a Tie!');
                end;
                
                if round >= 2 then
                    handWinner := ChooseWinner(round);
                    
                ResetDeck(initial);
            end;
        end;
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
end;

{implementation}
begin
    Randomize;

    gameManager.playerMatchPts := 0;
    gameManager.pcMatchPts := 0;
    gameManager.playerRoundPts := 0;
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
        PlayHand();
        ShowScore;
        
        writeln;
        writeln('  Press ENTER for the next hand...');
        readln;
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
