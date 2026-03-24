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
and;

{ ===== Utils ===== }

{convert card num to truco base force of the card}
function NumToForce(v : integer) : integer;
begin
  case v of
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
