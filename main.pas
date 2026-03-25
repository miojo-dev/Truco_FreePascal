program Truco_Paulista;

{
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

{ ===== Utils ===== }

{convert card num to truco base force of the card}
function NumToForce(card : integer) : integer;
begin
  case card of
    4 : Result := 1;
    5 : Result := 2;
    6 : Result := 3;
    7 : Result := 4;
    10: Result := 5;
    11: Result := 6;
    12: Result := 7;
    1 : Result := 8;
    2 : Result := 9;
    3 : Result := 10;
    else Result := 0;
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
function ValueStr(card : integer) : string;
begin
  case card of
    1 : ValueStr := 'A ';
    10 : ValueStr := 'J ';
    11 : ValueStr := 'Q ';
    12 : ValueStr := 'K ';
    else ValueStr := IntToStr(card) + ' ';
  end;
end;

