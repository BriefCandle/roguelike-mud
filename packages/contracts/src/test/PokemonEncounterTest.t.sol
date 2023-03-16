// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import { Deploy } from "./Deploy.sol";
import { PokemonTest } from "./PokemonTest.t.sol"; 
import "std-contracts/test/MudTest.t.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";

import { LibBattle } from "../libraries/LibBattle.sol";
import { LibPokemon } from "../libraries/LibPokemon.sol";

import { PokemonStats } from "../components/PokemonStatsComponent.sol";
import { BattleActionType } from "../BattleActionType.sol";
import { BattleType } from "../BattleType.sol";


import { CrawlSystem, ID as CrawlSystemID } from "../systems/CrawlSystem.sol";
import { BattleSystem, ID as BattleSystemID } from "../systems/BattleSystem.sol";

import { PositionComponent, ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID, PokemonInstance } from "../components/PokemonInstanceComponent.sol";


contract PokemonEncounterTest is PokemonTest {

  BattleSystem battleSystem;

  constructor() PokemonTest(new Deploy()) {
  }

  // function testCraw() public {
  //   setup();
  //   crawlTo(Coord(0,1)); 
  // }

  // function testEncounterAttackWithTackle() public {
  //   setup();
  //   crawlTo(Coord(0,1)); 

  //   setupBattle();

  //   (uint256 pokemonID1, uint256 pokemonID2) = getBattlePokemonIDs();
  //   console.log("pokemonID1", pokemonID1);
  //   console.log("pokemonID2", pokemonID2);

  //   PokemonStats memory stats2 = LibPokemon.getPokemonBattleStats(components, pokemonID2);
  //   console.log("pokemonID2 health: ", stats2.HP);

  //   uint8 moveNumber = 0;
  //   attack(pokemonID1, pokemonID2, moveNumber);

  //   PokemonStats memory stats2_after = LibPokemon.getPokemonBattleStats(components, pokemonID2);
  //   console.log("pokemonID2 health: ", stats2_after.HP);

  // }
  
  function testEncounterAttackInTurn() public {
    setup();
    crawlTo(Coord(0,1)); 

    setupBattle();

    uint256 battleID =  LibBattle.playerIDToBattleID(components, BattleSystemID);

    uint256[] memory commanderIDs = LibBattle.battleIDToCommanderIDs(components, battleID);
    console.log("commander #1: ", commanderIDs[0]);
    console.log("commander #2: ", commanderIDs[1]);
    console.log("battle ID: ", battleID);
    console.log("alice: ", addressToEntity(alice));

    uint256[] memory aliceTeam = LibBattle.getTeamPokemons(components, addressToEntity(alice));
    uint256[] memory enemyTeam = LibBattle.getTeamPokemons(components, BattleSystemID);
    console.log("alice memeber 0: ", aliceTeam[0]);
    console.log("NPC memeber 0: ", enemyTeam[0]);

    BattleActionType action = BattleActionType.Move0;

    vm.expectRevert("Battle: player cannot command pokemon");
    doAct(enemyTeam[0], aliceTeam[0], action, alice);
    
    // battle order only initiated when first attack
    assertTrue(LibBattle.isBattleOrderExist(components, battleID) == false);

    // first attack, alice attack wild pokemon
    console.log("------ First Round: Attack 1: NPC Attack Alice; precommit ------");
    doAct(aliceTeam[0], enemyTeam[0], action, alice);
    PokemonStats memory stats1 = LibPokemon.getPokemonBattleStats(components, aliceTeam[0]);
    console.log("alice pokemon HP: ", stats1.HP);
    PokemonStats memory stats2 = LibPokemon.getPokemonBattleStats(components, enemyTeam[0]);
    console.log("enemy pokemon HP: ", stats2.HP);
    uint256 nextPokemon = LibBattle.getBattleNextOrder(components, battleID);
    console.log("next pokemon: ", nextPokemon);


    // second attack, wild pokemon attack alice
    console.log("------ First Round: Attack 1: NPC Attack Alice; resolve ------");
    doAct(aliceTeam[0], enemyTeam[0], action, alice);
    stats1 = LibPokemon.getPokemonBattleStats(components, aliceTeam[0]);
    console.log("alice pokemon HP: ", stats1.HP);
    stats2 = LibPokemon.getPokemonBattleStats(components, enemyTeam[0]);
    console.log("enemy pokemon HP: ", stats2.HP);
    nextPokemon = LibBattle.getBattleNextOrder(components, battleID);
    console.log("next pokemon: ", nextPokemon);


    // assertTrue(LibBattle.checkBattleOrderExist(components, battleID) == false);
    // third attack, alice attack wild pokemon
    console.log("------ First Round: Attack 2: Alice Attack NPC; precommit ------");
    doAct(aliceTeam[0], enemyTeam[0], action, alice);
    stats1 = LibPokemon.getPokemonBattleStats(components, aliceTeam[0]);
    console.log("alice pokemon HP: ", stats1.HP);
    stats2 = LibPokemon.getPokemonBattleStats(components, enemyTeam[0]);
    console.log("enemy pokemon HP: ", stats2.HP);
    nextPokemon = LibBattle.getBattleNextOrder(components, battleID);
    console.log("next pokemon: ", nextPokemon);

    // Forth attack, alice attack wild pokemon
    console.log("------ First Round: Attack 2: Alice Attack NPC; resolve  ------");
    doAct(aliceTeam[0], enemyTeam[0], action, alice);
    stats1 = LibPokemon.getPokemonBattleStats(components, aliceTeam[0]);
    console.log("alice pokemon HP: ", stats1.HP);
    stats2 = LibPokemon.getPokemonBattleStats(components, enemyTeam[0]);
    console.log("enemy pokemon HP: ", stats2.HP);
    bool isBattleOrder = LibBattle.isBattleOrderExist(components, battleID);
    console.log("next pokemon: ", isBattleOrder);

        // assertTrue(LibBattle.checkBattleOrderExist(components, battleID) == false);
    // third attack, alice attack wild pokemon
    console.log("------ Second Round: Attack 1: NPC Attack Alice; precommit ------");
    doAct(aliceTeam[0], enemyTeam[0], action, alice);
    stats1 = LibPokemon.getPokemonBattleStats(components, aliceTeam[0]);
    console.log("alice pokemon HP: ", stats1.HP);
    stats2 = LibPokemon.getPokemonBattleStats(components, enemyTeam[0]);
    console.log("enemy pokemon HP: ", stats2.HP);
    nextPokemon = LibBattle.getBattleNextOrder(components, battleID);
    console.log("next pokemon: ", nextPokemon);

    // Forth attack, alice attack wild pokemon
    console.log("------ Second Round: Attack 1: NPC Attack Alice; resolve ------");
    doAct(aliceTeam[0], enemyTeam[0], action, alice);
    stats1 = LibPokemon.getPokemonBattleStats(components, aliceTeam[0]);
    console.log("alice pokemon HP: ", stats1.HP);
    stats2 = LibPokemon.getPokemonBattleStats(components, enemyTeam[0]);
    console.log("enemy pokemon HP: ", stats2.HP);
    nextPokemon = LibBattle.getBattleNextOrder(components, battleID);
    console.log("next pokemon: ", nextPokemon);

    // uint8 moveNumber = 1;
    // attack(pokemonID1, pokemonID2, moveNumber);

    // PokemonStats memory stats2_after = LibPokemon.getPokemonBattleStats(components, pokemonID2);
    // console.log("pokemonID2 ATK: ", stats2_after.ATK);

    // moveNumber = 0;
    // attackByBattleSystem(pokemonID2, pokemonID1, moveNumber);
    // PokemonStats memory stats1_after = LibPokemon.getPokemonBattleStats(components, pokemonID1);
    // console.log("pokemonID2 HP: ", stats1_after.HP);
  }

  // function testAttackFromWrong

  function doAct(uint256 pokemonID, uint256 targetID, BattleActionType action, address player) prank(player) internal {
    battleSystem.executeTyped(pokemonID, targetID, action);
  }

  function crawlTo(Coord memory coord) prank(alice) internal {
    CrawlSystem crawlS = CrawlSystem(system(CrawlSystemID));
    crawlS.executeTyped(coord);
  }

  function setupBattle() internal {
    battleSystem = BattleSystem(system(BattleSystemID));
  }

  
}