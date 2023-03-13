// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import { Deploy } from "./Deploy.sol";
import "std-contracts/test/MudTest.t.sol";
import { getAddressById, addressToEntity } from "solecs/utils.sol";


import { PokemonStats } from "../components/PokemonStatsComponent.sol";
import { PokemonType } from "../PokemonType.sol";
import { MoveCategory } from "../MoveCategory.sol";
import { LevelRate } from "../LevelRate.sol";
import { PokemonClassInfo } from "../components/PokemonClassInfoComponent.sol";
import { MoveInfo } from "../components/MoveInfoComponent.sol";
import { MoveEffect } from "../components/MoveEffectComponent.sol";
import { MoveTarget } from "../MoveTarget.sol";
import { StatusCondition } from "../StatusCondition.sol"; 
import { Parcel, parcelWidth, parcelHeight } from "../components/ParcelComponent.sol";
import { TerrainType } from "../TerrainType.sol";

import { CreatePokemonClassSystem, ID as CreatePokemonClassSystemID } from "../systems/CreatePokemonClassSystem.sol";
import { SpawnPlayerSystem, ID as SpawnPlayerSystemID } from "../systems/SpawnPlayerSystem.sol";
import { CreateMoveClassSystem, ID as CreateMoveClassSystemID } from "../systems/CreateMoveClassSystem.sol";
import { ConnectPokemonMovesSystem, ID as ConnectPokemonMovesSystemID } from "../systems/ConnectPokemonMovesSystem.sol";
import { SpawnPokemonSystem, ID as SpawnPokemonSystemID } from "../systems/SpawnPokemonSystem.sol";
import { ObtainFirstPokemonSystem, ID as ObtainFirstPokemonSystemID } from "../systems/ObtainFirstPokemonSystem.sol";
import { ObtainFirstPokemonSystem, ID as ObtainFirstPokemonSystemID } from "../systems/ObtainFirstPokemonSystem.sol";
import { CreateParcelSystem, ID as CreateParcelSystemID } from "../systems/CreateParcelSystem.sol";

import { MoveNameComponent, ID as MoveNameComponentID } from "../components/MoveNameComponent.sol";
import { PokemonIndexComponent, ID as PokemonIndexComponentID } from "../components/PokemonIndexComponent.sol";
import { TeamComponent, ID as TeamComponentID } from "../components/TeamComponent.sol";
import { TeamPokemonsComponent, ID as TeamPokemonsComponentID, TeamPokemons } from "../components/TeamPokemonsComponent.sol";

contract PokemonTest is MudTest {
  // when inherit: constructor() PokemonTest(new Deploy()) {}
  constructor(IDeploy deploy) MudTest(deploy) {}
  // constructor() MudTest(new Deploy()) {}


  bytes zero = abi.encode(0);

  modifier prank(address prankster) {
    vm.startPrank(prankster);
    _;
    vm.stopPrank();
  }

  // -------------- SETUP POKEMON CLASS, MOVE, AND STUFF --------------

  function createPokemonClass(PokemonStats memory baseStats, PokemonStats memory eV, PokemonClassInfo memory classInfo, uint32 index) internal {
    CreatePokemonClassSystem createPokemonClassS = CreatePokemonClassSystem(system(CreatePokemonClassSystemID));
    createPokemonClassS.executeTyped(baseStats, eV, classInfo, index);
  }

  function createMoveClass(string memory name, MoveInfo memory info, MoveEffect memory effect) internal {
    CreateMoveClassSystem createMoveS = CreateMoveClassSystem(system(CreateMoveClassSystemID));
    createMoveS.executeTyped(name, info, effect);
  }

  function connectPokemonMoves(uint256 pokemonID, uint256[] memory moves) internal {
    ConnectPokemonMovesSystem connectS = ConnectPokemonMovesSystem(system(ConnectPokemonMovesSystemID));
    connectS.executeTyped(pokemonID, moves);
  }

  function getMoveIDFromName(string memory name) internal view returns (uint256 moveID) {
    moveID = MoveNameComponent(getAddressById(components, MoveNameComponentID)).
      getEntitiesWithValue(abi.encode(name))[0];
  }

  function getPokemonClassIDFromIndex(uint32 index) internal view returns (uint256 pokemonID) {
    pokemonID = PokemonIndexComponent(getAddressById(components, PokemonIndexComponentID)).
      getEntitiesWithValue(abi.encode(index))[0];
  }


  function setupPokemon() internal {
    // create bulbasaur pokemon class
    PokemonStats memory baseStats = PokemonStats(45,49,49,65,65,45);
    PokemonStats memory eV = PokemonStats(0,0,0,1,0,0);
    PokemonClassInfo memory classInfo = PokemonClassInfo(45,PokemonType.Grass,PokemonType.Poison,LevelRate.MediumSlow);
    uint32 index = 1; 
    createPokemonClass(baseStats, eV, classInfo, index);
    
    // create tackle move class
    string memory name = 'Tackle';
    MoveInfo memory info = MoveInfo(PokemonType.Normal, MoveCategory.Physical, 35, 40, 100);
    MoveEffect memory effect = MoveEffect(0,0,0,0,0,0,0,0,0,0,0,MoveTarget.Foe,StatusCondition.None);
    createMoveClass(name, info, effect);

    string memory name2 = 'Growl';
    MoveInfo memory info2 = MoveInfo(PokemonType.Grass, MoveCategory.Status, 40, 0, 100);
    MoveEffect memory effect2 = MoveEffect(0,-1,0,0,0,0,0,0,0,0,0,MoveTarget.Foe, StatusCondition.None);
    createMoveClass(name2, info2, effect2);
    
    // connect Tackle & Growl with bulbasaur
    uint256 pokemonClassID = getPokemonClassIDFromIndex(index);
    uint256 moveID = getMoveIDFromName(name);
    uint256 moveID2 = getMoveIDFromName(name2);
    uint256[] memory moves = new uint256[](2);
    moves[0] = moveID;
    moves[1] = moveID2;
    connectPokemonMoves(pokemonClassID, moves);
  }


  // -------------- SETUP POKEMON CLASS, MOVE, AND STUFF --------------

  function obtainFirstPokemon() prank(alice) internal {
    // get classID of bulbasaur of index = 1
    console.log("first pokemon", msg.sender);
    uint32 index = 1;
    uint256 pokemonClassID = getPokemonClassIDFromIndex(index);
    ObtainFirstPokemonSystem obtainFirstS = ObtainFirstPokemonSystem(system(ObtainFirstPokemonSystemID));
    obtainFirstS.executeTyped(pokemonClassID);
  }

  function spawnPlayer() prank(alice) internal {
    SpawnPlayerSystem spawnPlayerS = SpawnPlayerSystem(system(SpawnPlayerSystemID));
    spawnPlayerS.execute(zero);
  }

  function setupPlayer() internal {
    spawnPlayer();
    obtainFirstPokemon();
  }

  // -------------- SETUP PARCEL AND ENCOUNTERABLE --------------

  // create an all-tall-grass parcel that is encounterable
  function createParcel() internal {
    int32 x_p = 0;
    int32 y_p = 0;
    TerrainType L = TerrainType.GrassTall;
    TerrainType[parcelHeight][parcelWidth] memory map = [
      [L, L, L, L, L],
      [L, L, L, L, L],
      [L, L, L, L, L],
      [L, L, L, L, L],
      [L, L, L, L, L]
    ];
    bytes memory terrain = new bytes(parcelWidth * parcelHeight);
    for (uint32 j=0; j<parcelHeight; j++) {
      for (uint32 i=0; i<parcelWidth; i++) {
        TerrainType terrainType = map[j][i];
        terrain[(j * parcelWidth) + i] = bytes1(uint8(terrainType));
      }
    }
    CreateParcelSystem createParcelS = CreateParcelSystem(system(CreateParcelSystemID));
    createParcelS.executeTyped(x_p,y_p,terrain);
  }

  // -------------- SETUP POKEMON CLASS, MOVE, AND STUFF --------------

  function setup() internal {
    setupPokemon();
    setupPlayer();
    createParcel();
  }

}