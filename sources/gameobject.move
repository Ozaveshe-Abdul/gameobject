// Copyright (c) Sui Foundation, Inc.
// SPDX-License-Identifier: Apache-2.0
/// A basic object example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
/// Modified to use GameObject pattern
module sui_intro_unit_two::game_item;

use sui::event;
use sui::transfer;
use sui::object::{Self, UID, ID};
use sui::tx_context::TxContext;

public struct GameItem has key, store {
    id: UID,
    power: u64,
    rarity: u8,
    item_type: String,
}

public struct GameInventory has key {
    id: UID,
    item: GameItem,
    intended_player: address,
}

public struct GameAdminCap has key {
    id: UID,
}

public struct TestStruct has drop, store, copy {}

/// Event marking when a game item has been requested
public struct GameItemRequestEvent has copy, drop {
    // The Object ID of the game inventory wrapper
    wrapper_id: ID,
    // The requester of the game item
    requester: address,
    // The intended player of the game item
    intended_player: address,
}

// Error code for when a non-intended player tries to unpack the game item wrapper
const ENotIntendedPlayer: u64 = 1;

/// Module initializer is called only once on module publish.
fun init(ctx: &mut TxContext) {
    transfer::transfer(
        GameAdminCap {
            id: object::new(ctx),
        },
        tx_context::sender(ctx),
    )
}

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

#[allow(lint(self_transfer))]
public fun create_game_item(
    _: &GameAdminCap,
    power: u64,
    rarity: u8,
    item_type: String,
    ctx: &mut TxContext,
) {
    let game_item = GameItem {
        id: object::new(ctx),
        power,
        rarity,
        item_type,
    };
    transfer::public_transfer(game_item, tx_context::sender(ctx))
}

// You are allowed to retrieve the power but cannot modify it
public fun view_power(game_item: &GameItem): u64 {
    game_item.power
}

// You are allowed to view and edit the power but not allowed to delete it
public fun update_power(
    _: &GameAdminCap,
    game_item: &mut GameItem,
    power: u64,
) {
    game_item.power = power
}

// You are allowed to do anything with the game item, including view, edit, or delete
public fun delete_game_item(
    _: &GameAdminCap,
    game_item: GameItem,
) {
    let GameItem { id, .. } = game_item;
    id.delete();
}

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
    // Transfer the wrapped game item directly to the intended player
    transfer::transfer(inventory, intended_player);
}

#[allow(lint(self_transfer))]
public fun unpack_game_item(inventory: GameInventory, ctx: &mut TxContext) {
    // Check that the person unpacking the game item is the intended player
    assert!(inventory.intended_player == tx_context::sender(ctx), ENotIntendedPlayer);
    let GameInventory { id, item, .. } = inventory;
    transfer::transfer(item, tx_context::sender(ctx));
    object::delete(id);
}
