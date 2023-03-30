// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { QueryType } from "solecs/interfaces/Query.sol";
import { IWorld, WorldQueryFragment } from "solecs/World.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { ParcelCoordComponent, ID as ParcelCoordComponentID, Coord } from "../components/ParcelCoordComponent.sol";
import { PokemonStats } from "../components/PokemonStatsComponent.sol";
import { MoveTarget } from "../MoveTarget.sol";
import { LibPokemon } from "./LibPokemon.sol";
import { LibPokemonClass } from "./LibPokemonClass.sol";
import { LibTeam } from "./LibTeam.sol";
import { LibBattle } from "./LibBattle.sol";

import { BattleStats } from "../components/PokemonBattleStatsComponent.sol";

import { OwnedByComponent, ID as OwnedByComponentID } from "../components/OwnedByComponent.sol";
import { PokemonClassIDComponent, ID as PokemonClassIDComponentID } from "../components/PokemonClassIDComponent.sol";

import { ID as EncounterTriggerComponentID } from "../components/EncounterTriggerComponent.sol";
import { ID as PositionComponentID, Coord } from "../components/PositionComponent.sol";
import { ID as PlayerComponentID } from "../components/PlayerComponent.sol";

library LibOwnedBy { 
  function entityIDToOwnerID(IUint256Component components, uint256 entityID) internal view returns(uint256 ownerID) {
    return OwnedByComponent(getAddressById(components, OwnedByComponentID)).getValue(entityID);
  }

  function setOwner(IUint256Component components, uint256 entityID, uint256 playerID) internal returns(bool) {
    OwnedByComponent(getAddressById(components, OwnedByComponentID)).set(
      entityID, playerID
    );
  } 

  function isOwnedBy(IUint256Component components, uint256 entityID, uint256 playerID) internal view returns(bool) {
    OwnedByComponent ownedByComp = OwnedByComponent(getAddressById(components, OwnedByComponentID));
    if (!ownedByComp.has(entityID)) return false;
    return ownedByComp.getValue(entityID) == playerID ? true : false;
  }

  function isParcelOwneByPlayer(IWorld world, Coord memory coord, uint256 playerID) internal view returns (bool) {
    WorldQueryFragment[] memory fragments = new WorldQueryFragment[](2);
    fragments[0] = WorldQueryFragment(QueryType.HasValue, ParcelCoordComponentID, abi.encode(coord));
    fragments[1] = WorldQueryFragment(QueryType.HasValue, OwnedByComponentID, abi.encode(playerID));
    return world.query(fragments).length == 0 ? false : true;
  }

  function getOwnedPokemon(IWorld world, uint256 playerID) internal view returns(uint256[] memory){
    WorldQueryFragment[] memory fragments = new WorldQueryFragment[](2);
    fragments[0] = WorldQueryFragment(QueryType.HasValue, OwnedByComponentID, abi.encode(playerID));
    fragments[1] = WorldQueryFragment(QueryType.Has, PokemonClassIDComponentID, new bytes(0));
    return world.query(fragments); 
  }
}
