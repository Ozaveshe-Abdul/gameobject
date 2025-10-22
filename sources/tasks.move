// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0
/// Game Object Example with Student Tasks
/// This module demonstrates game item management with three student tasks
module gameobject::tasks;

use sui::event;
use std::string::String;


// Game item structure representing in-game assets
public struct GameItem has key, store {
    id: UID,
    power: u64,
    rarity: u8,
    item_type: String,
}

// Inventory structure to wrap game items
public struct GameInventory has key {
    id: UID,
    item: GameItem,
    intended_player: address,
}

// Admin capability for privileged actions
public struct GameAdminCap has key {
    id: UID,
}

// Test structure (can be ignored for this exercise)
public struct TestStruct has drop, store, copy {}

// Event for tracking game item requests
public struct GameItemRequestEvent has copy, drop {
    wrapper_id: ID,
    requester: address,
    intended_player: address,
}

public struct GameItemCreatedEvent has copy, drop {
    item_id: ID,
    item_type: String,
    rarity: u8,
    creator: address
}


public struct GameItemTransferredEvent has copy, drop {
    item_id: ID,
    from_address: address,
    to_address: address
}
   


// Error codes
const ENotIntendedPlayer: u64 = 1;
const EInvalidPower: u64 = 2;  // New error code for Task 1

/// Module initializer - creates the first admin cap
fun init(ctx: &mut TxContext) {
    transfer::transfer(
        GameAdminCap {
            id: object::new(ctx),
        },
        tx_context::sender(ctx),
    )
}

/* ---------- COMPLETED EXAMPLES ---------- */

// Example: View a game item's power (read-only)
public fun view_power(game_item: &GameItem): u64 {
    game_item.power
}

// Example: Admin can delete a game item
public fun delete_game_item(
    _: &GameAdminCap,
    game_item: GameItem,
) {
    let GameItem { id, .. } = game_item;
    id.delete();
}

/* ---------- STUDENT TASK 1 ---------- */
/*
TASK 1: Power Level Validation
Complete the update_power function to:
1. Add validation to ensure power values are between 1-100
2. Return an error (EInvalidPower) if validation fails
3. Only allow updates if the new power is greater than current power

Hints:
- Use assert! for validation
- Compare new_power with game_item.power
- Remember to use the EInvalidPower constant
*/
public fun update_power(
    _: &GameAdminCap,
    game_item: &mut GameItem,
    new_power: u64,
) {
    // STUDENT CODE GOES HERE
    assert!(new_power >= 1 && new_power <= 100, EInvalidPower);
    game_item.power = new_power;  // Final line after validation
}

/* ---------- STUDENT TASK 2 ---------- */
/*
TASK 2: Enhanced Game Item Creation
Modify the create_game_item function to:
1. Add validation for rarity (must be 1-5)
2. Add an event emission when a game item is created
3. Create a new GameItemCreatedEvent struct for this purpose

Hints:
- Define the new event struct with copy, drop abilities
- Include fields: item_id, item_type, rarity, creator
- Use event::emit to send the event
- Add rarity validation with assert!
*/
#[allow(lint(self_transfer))]
public fun create_game_item(
    _: &GameAdminCap,
    power: u64,
    rarity: u8,
    item_type: String,
    ctx: &mut TxContext,
) {
    // STUDENT CODE FOR VALIDATION GOES HERE
    assert!(rarity >= 1 && rarity <= 5, EInvalidPower);
    let game_item = GameItem {
        id: object::new(ctx),
        power,
        rarity,
        item_type,
    };

    // STUDENT CODE FOR EVENT EMISSION GOES HERE
    event::emit(
        GameItemCreatedEvent {
            item_id : object::id(&game_item),
            item_type,
            rarity,
            creator: ctx.sender()
        }
    );

    transfer::public_transfer(game_item, tx_context::sender(ctx))
}

/* ---------- STUDENT TASK 3 ---------- */
/*
TASK 3: Game Inventory Management
Complete the transfer_game_item function to:
1. Transfer a game item from one player to another
2. Add validation to ensure the sender owns the item
3. Emit a GameItemTransferredEvent with details

Hints:
- Create a new GameItemTransferredEvent struct
- Include fields: item_id, from_address, to_address
- Use transfer::transfer to move the item
- Add ownership validation
*/
public fun transfer_game_item(
    game_item: GameItem,
    recipient: address,
    ctx: &mut TxContext,
) {
    // STUDENT CODE GOES HERE
    // assert!(game_item.);

    event::emit(
        GameItemTransferredEvent {
            item_id : object::id(&game_item),
            from_address : ctx.sender(),
            to_address : recipient
        }
    );

    transfer::transfer(game_item, recipient);

}

/* ---------- PROVIDED FUNCTIONS ---------- */

// Provided: Add additional admin
public fun add_additional_admin(
    _: &GameAdminCap,
    new_admin_address: address,
    ctx: &mut TxContext,
) {
    transfer::transfer(
        GameAdminCap {
            id: object::new(ctx),
        },
        new_admin_address,
    )
}

// Provided: Request a game item
public fun request_game_item(
    game_item: GameItem,
    intended_player: address,
    ctx: &mut TxContext,
) {
    let inventory = GameInventory {
        id: object::new(ctx),
        item: game_item,
        intended_player,
    };
    event::emit(GameItemRequestEvent {
        wrapper_id: object::id(&inventory),
        requester: tx_context::sender(ctx),
        intended_player,
    });
    transfer::transfer(inventory, intended_player);
}

// Provided: Unpack a game item
#[allow(lint(self_transfer))]
public fun unpack_game_item(inventory: GameInventory, ctx: &mut TxContext) {
    assert!(inventory.intended_player == tx_context::sender(ctx), ENotIntendedPlayer);
    let GameInventory { id, item, .. } = inventory;
    transfer::transfer(item, tx_context::sender(ctx));
    object::delete(id);
}
