# Shoot the Target / Mushroom Massacre – MIPS Assembly Game

## Aim of the project
This project is a simple arcade-style shooting game developed in MIPS Assembly. The player controls a shooter at the bottom of the screen and must shoot down all mushrooms before they reach the player’s row.

## Objective

- Learn how to work with memory-mapped I/O in MIPS.
- Gain experience in assembly-level control structures.
- Implement game mechanics like movement, collision detection, and user input handling in low-level language.

## Game Mechanics

- **Shooter**: Can move left (`j`) and right (`k`) within a limited range (992–1023).
- **Darts**: Press `x` to fire. Maximum 10 darts can be on screen at once.
- **Mushrooms**: Move left/right and drop one row when they hit the edge. Each has 2 health points (green when full, orange when hit).
- **Win Condition**: If all mushrooms are destroyed, a yellow "YOU WIN" message is shown.
- **Lose Condition**: If any mushroom reaches shooter's row, the game ends.

## How to Run

1. Open **Mars MIPS** simulator.
2. Load the `.asm` file.
3. Run the program.
4. Use the keyboard inputs:
   - `j` → move left
   - `k` → move right
   - `x` → shoot a dart

### Bitmap Display Configuration

Before running the game, make sure you configure the Bitmap Display as follows:

- **Unit Width in Pixels**: `8`
- **Unit Height in Pixels**: `8`
- **Display Width in Pixels**: `256`
- **Display Height in Pixels**: `256`
- **Base Address for Display**: `0x10008000 ($gp)`


## Logic Structure 

- `main`: Jumps into the main loop.
- `loop`: Calls all display, input, update, and check functions every frame.
- `disp_*`: Draws shooter, mushrooms, and darts.
- `move_mushrooms`: Updates mushroom movement and direction.
- `check_dart_collision`: Detects if a dart hit a mushroom.
- `check_shooter_collision`: Checks if mushroom reaches the shooter.
- `check_keystroke`: Handles player input.
- `set_dart_next`: Updates dart positions, removes out-of-bound darts.
- `draw_win_message`: Shows "YOU WIN" in yellow pixels.
- `clear_screen`: Refreshes the screen with black pixels.

## Data Segment

```assembly
.data
displayAddress:      .word 0x10008000
mushroomLocation:    .word 200, 250, 300, 350, 400
mushroomHealth:      .word 2, 2, 2, 2, 2
mushroomDirection:   .word 1, 1, 1, 1, 1
mushroomNum:         .word 5
shooterLocation:     .word 992
dartLocation:        .word 0:10
dartNum:             .word 0
gameOver:            .word 0
