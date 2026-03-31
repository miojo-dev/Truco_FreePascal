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
end
