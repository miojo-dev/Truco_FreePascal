program Truco_Paulista;

uses SysUtils;

{
feat: feature
fix: coreção
refactor: refatorar código

function NameFunction

var nameVar

type TNameTipe
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
end;

type deck = array[0..deckSize-1] of TCard;

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
procedure GenerateDeck(var d:Deck);
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
		for k := 1 to 10 do
        begin
		 if (k < 8) or (k > 9) then
		 begin
            d[i].suit := suit[j];
            
			d[i].value := k;
            
			i:= i + 1;
		   end;
		end;
	end;
end;
{Shuffle Deck Function}
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

{implementation}
begin
    
end.
