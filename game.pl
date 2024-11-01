% Facts about initial resources
resource(coal, 1000).
resource(stone, 500).
resource(iron, 100).

cost(furnace, [(coal, 1, false), (stone, 10, false)]).
cost(chemistry_lab, [(stone, 10, false), (iron, 20, false), (furnace, 500, true)]).

% Check if enough of a resource is available
has_enough(Resource, Quantity) :- 
    resource(Resource, Available),
    Available >= Quantity.

% Update resource quantities based on the consumable flag
update_resource(Resource, Quantity, false) :-  % Consumable
    resource(Resource, Available),
    NewAvailable is Available - Quantity,
    NewAvailable >= 0,  % Ensure resources do not go negative
    retract(resource(Resource, Available)),
    assert(resource(Resource, NewAvailable)).

update_resource(_, _, true).  % Non-consumable, do nothing

% Check if an item can be built and update resources accordingly
can_build(Item) :-
    can_build(Item, 1).

can_build(Item, Quantity) :-
    % If the item is already available, no need to build it
    resource(Item, Available),
    Available >= Quantity, !.

can_build(Item, Quantity) :-
    % Otherwise, check the item requirements and attempt to build
    resource(Item, Available),
    Need is Quantity - Available,
    cost(Item, Requirements),
    can_build_all(Requirements),
    % After successful building, add the item to the resources
    add_resource(Item) ; write(Item),write(Need).

build(Item, Quantity) :-
    cost(Item, Requirements),

build_all([]).

build_all([(Item, Quantity) | Rest]) :-
    can_build(),
    build(),
    build_all(Rest).

% Modified can_build_all to attempt producing resources if needed
can_build_all([]).

can_build_all([(Resource, Quantity, Consumable) | Rest]) :-
    (has_enough(Resource, Quantity) ; 
     (can_build(Resource, Quantity), has_enough(Resource, Quantity))),
    update_resource(Resource, Quantity, Consumable),
    can_build_all(Rest).

% Add the item to resources after building it
add_resource(Item) :-
    (resource(Item, Available) -> 
        NewAvailable is Available + 1,
        retract(resource(Item, Available)),
        assert(resource(Item, NewAvailable))
    ; 
        assert(resource(Item, 1))
    ).

win_condition(chemistry_lab).

can_win :-
    win_condition(Item),
    can_build(Item).


% Some requests
%?- can_build(furnace).
%?- can_win.
