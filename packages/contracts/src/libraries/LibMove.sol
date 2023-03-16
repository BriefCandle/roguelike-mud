// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { PokemonStats } from "../components/PokemonStatsComponent.sol";
import { MoveTarget } from "../MoveTarget.sol";
import {LibPokemon} from "./LibPokemon.sol";


import { MoveEffectComponent, ID as MoveEffectComponentID, MoveEffect } from "../components/MoveEffectComponent.sol";
import { MoveInfoComponent, ID as MoveInfoComponentID, MoveInfo } from "../components/MoveInfoComponent.sol";
import { PokemonInstanceComponent, ID as PokemonInstanceComponentID, PokemonInstance} from "../components/PokemonInstanceComponent.sol";
import { PokemonClassInfoComponent, ID as PokemonClassInfoComponentID, PokemonClassInfo } from "../components/PokemonClassInfoComponent.sol";

import { ID as EncounterTriggerComponentID } from "../components/EncounterTriggerComponent.sol";
import { ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { ID as ObstructionComponentID } from "../components/ObstructionComponent.sol";
import { ID as PlayerComponentID } from "../components/PlayerComponent.sol";

library LibMove {

      /**
   * NOTE: this is NOT an gas efficient way to calculate move effect
   * @param components: registry address of components
   * @param pokemonID: pokemonID of attacking pokemon
   * @param targetID: pokemonID of defending pokemon
   * @param moveID: moveID used by attacking pokemon
   * @param randomNumber: used to calculate crit
   */
  function calculateMoveEffectOnPokemons(
    IUint256Component components, uint256 pokemonID, uint256 targetID, uint256 moveID, 
    uint256 randomNumber) internal view returns (PokemonInstance memory, PokemonInstance memory) {
    // pokemon 
    PokemonStats memory attackPokemon = LibPokemon.getPokemonBattleStats(components, pokemonID);
    PokemonStats memory defendPokemon = LibPokemon.getPokemonBattleStats(components, targetID);
    PokemonInstance memory attackPokemonI = LibPokemon.getPokemonInstance(components, pokemonID);
    PokemonInstance memory defendPokemonI = LibPokemon.getPokemonInstance(components, targetID);
    PokemonClassInfo memory defendClass = LibPokemon.getPokemonClassInfo(components, targetID);
    // move info and effect
    MoveEffect memory moveEffect = LibMove.getMoveEffect(components, moveID);
    MoveInfo memory moveInfo = LibMove.getMoveInfo(components, moveID);
    // type effect
    uint8 effectValue = LibPokemon.getTotalEffectValue(moveInfo.TYP, defendClass.type1, defendClass.type2);
    // TODO: implement crt with randomness
    bool isCrit = checkCritical(attackPokemon.SPD, moveEffect.CRT, randomNumber);
    uint32 critEffect = isCrit ? 2 : 1;
    // TODO: implement special attack type to check special defence
    // TODO: implement evasion check; when true return unchanged pokemon instace, attackPokemonI...
    // HP & DMG
    uint32 DMG = ((2 * uint32(attackPokemonI.level) / 5 + 2) * uint32(moveInfo.PWR) * 
      uint32(attackPokemon.ATK) / uint32(defendPokemon.DEF) / 50 + 2) * uint32(effectValue) * critEffect;
    defendPokemonI.currentHP = defendPokemonI.currentHP > DMG ? defendPokemonI.currentHP - DMG : 0;
    // other stats in instance
    if (moveEffect.target == MoveTarget.Foe) {
      defendPokemonI.ATK = defendPokemonI.ATK + moveEffect.ATK;
      defendPokemonI.DEF = defendPokemonI.DEF + moveEffect.DEF;
      defendPokemonI.SPATK = defendPokemonI.SPATK + moveEffect.SPATK;
      defendPokemonI.SPDEF = defendPokemonI.SPDEF + moveEffect.SPDEF;
      defendPokemonI.SPD = defendPokemonI.SPD + moveEffect.SPD;
    } else {
      attackPokemonI.ATK = attackPokemonI.ATK + moveEffect.ATK;
      attackPokemonI.DEF = attackPokemonI.DEF + moveEffect.DEF;
      attackPokemonI.SPATK = attackPokemonI.SPATK + moveEffect.SPATK;
      attackPokemonI.SPDEF = attackPokemonI.SPDEF + moveEffect.SPDEF;
      attackPokemonI.SPD = attackPokemonI.SPD + moveEffect.SPD;
    }
    return (attackPokemonI, defendPokemonI);
  }

  // complicated to calculate crit chance for gen II onward
  // https://bulbapedia.bulbagarden.net/wiki/Critical_hit
  // use gen I for now
  function checkCritical(uint8 SPD, int8 CRT, uint256 randomNumber) internal pure returns (bool) {
    uint32 multiplier = LibPokemon.getStatsMultipled(CRT, 1);
    uint256 threshold = randomNumber % 256;
    return multiplier * SPD / 2 > threshold ? true : false;
  }

  function getMoveEffect(IUint256Component components, uint256 moveID) internal view returns (MoveEffect memory) {
    MoveEffectComponent moveEffect = MoveEffectComponent(getAddressById(components, MoveEffectComponentID));
    return moveEffect.getValue(moveID);
  }

  function getMoveInfo(IUint256Component components, uint256 moveID) internal view returns (MoveInfo memory) {
    MoveInfoComponent moveInfo = MoveInfoComponent(getAddressById(components, MoveInfoComponentID));
    return moveInfo.getValue(moveID);
  }
}