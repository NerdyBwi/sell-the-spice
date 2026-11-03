# sell-the-spice
Initial responsibilities:
# Area    Primary owner   Backup owner  What the owner will deliver
# Shop    
> Nuo Xiang Yan, Owen
>> Handles cards and goods being contained in a shop. Manages taking items in and out of the shop.

# Display 
> Anish, Brian + Potentially everyone else because GUIs hard
>> Presents game state and information to the user. (Start with terminal, “upgrade” to GUI or “downgrade” to text if needed)

# Player
> Owen, Brian
>> Manages the player’s stats, gold, and inventory, as well as any changes to those values

# Enemies
> Brian, Owen
>> Manages the enemies’ stats and behaviors, turn scaling, and loot dropped if defeated.

# Game
> Anish, Gabe
>> Handles interactions between modules, game states, user input, and visual UI, handles exceptions/failures

# Main
> Gabe, Anish
>> Initializes “Game” with RNG seed and prints exceptions/errors

# Combat
> Brian, Nuo Xiang Yan
>> Handles the interaction between Player and enemies, as well as cards

# Cards
> Nuo Xiang Yan, Gabe
>> Handles the execution of cards as well as their storage 

# Goods
> Gabe, Nuo Xiang Yan
>> Make a list of goods available to players. Interacts with Shop, Player, and Combat.



