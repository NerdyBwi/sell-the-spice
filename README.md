# Sell the Spice!
Roguelike turn based deckbuilder game themed around being a merchant aiming to make a profit through long distance travel and trading.

# Initial responsibilities:
**Shop:** Nuo Xiang Yan (ny227), Owen (od89)
> Handles cards and goods being contained in a shop. Manages taking items in and out of the shop.

**Display:** Anish (akd82), Brian (bc544) + Potentially everyone else because GUIs hard
> Presents game state and information to the user. (Start with terminal, “upgrade” to GUI or “downgrade” to text if needed)

**Player:** Owen (od89), Brian (bc544)
> Manages the player’s stats, gold, and inventory, as well as any changes to those values

**Enemies:** Brian (bc544), Owen (od89)
> Manages the enemies’ stats and behaviors, turn scaling, and loot dropped if defeated.

**Game:** Anish (akd82), Gabe (gx57)
> Handles interactions between modules, game states, user input, and visual UI, handles exceptions/failures

**Main:** Gabe (gx57), Anish (akd82)
> Initializes “Game” with RNG seed and prints exceptions/errors

**Combat:** Brian (bc544), Nuo Xiang Yan (ny227)
> Handles the interaction between Player and enemies, as well as cards

**Cards:** Nuo Xiang Yan (ny227), Gabe (gx57)
> Handles the execution of cards as well as their storage 

**Goods:** Gabe (gx57), Nuo Xiang Yan (ny227)
> Make a list of goods available to players. Interacts with Shop, Player, and Combat.



