program Truco_Paulista;

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

{convert card value to the respective string number or face letter}
function FaceStr(card : integer) : string;
begin
  case card of
    1 : ValueStr := 'A ';
    10 : ValueStr := 'J ';
    11 : ValueStr := 'Q ';
    12 : ValueStr := 'K ';
    else ValueStr := IntToStr(card) + ' ';
  end;
end;

{formats the card into a stringwith all the info}
function CardStr(const c: TCard): string;
begin
    CardStr := FaceStr(c.ValueStr) + ' of ' + SuitStr(c.suit);
    
    if c.isManilha then CardStr := CardStr + ' *Manilha!*'
end;

{gives more value based on the card suit}
function ManilhaForce(n: TSuit): integer;
begin
    case n of
        nClubs := 4;
        nHearts := 3;
        nSpades := 2;
        nDiamonds := 1;
        end;
end;

{total force of the card}
function TotalCardForce(const c: TCard): integer;
begin
    if c.isManilha then 
        TotalCardForce := 100 + ManilhaForce(c.suit);
    else
        TotalCardForce := NumToForce(c.value);
end;

{next card in the sequence}
function NextCardValue(v: integer): integer
begin
    case v of
        7 : NextCardValue :=  10;
        12 : NextCardValue := 1;
        else NextCardValue := v + 1;
    end;
end;

{ ===== Deck ====== }

{Populate Deck Function}
procedure GenerateDeck(var d:Deck);
var i,j,k:integer;
suit: array[1..4] of string;
begin
	//Adicionar validação se está vazia(opcional)
	suit[1] := 'Diamonds';
	suit[2] := 'Hearts';
	suit[3] := 'Spades';
	suit[4] := 'Clubs';
  
	i := 0;
	for j := 1 to 4 do
	begin
		for k := 1 to 10 do
    	begin
    		d[i].suit := suit[j];
	  
			d[i].value := k;
	  
			i:= i + 1;
		end;
	end;
end;

