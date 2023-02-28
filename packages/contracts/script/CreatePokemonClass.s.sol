pragma solidity ^0.8.13;

import "../lib/forge-std/src/Script.sol";
import { PokemonStats } from "../src/components/PokemonStatsComponent.sol";
import { PokemonType } from "../src/PokemonType.sol";
import { LevelRate } from "../src/LevelRate.sol";

// source .env
// forge script script/CreatePokemonClass.s.sol:CreatePokemonClassScript --rpc-url http://localhost:8545 --broadcast

contract CreatePokemonClassScript is Script {

  address world = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
  address CreatePokemonClassSystem = 0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82;
  
  PokemonStats[3] bsArray;
  PokemonStats[3] evArray;
  uint32[3] crArray;
  uint32[3] iArray;
  PokemonType[3] type1Array;
  PokemonType[3] type2Array;
  LevelRate[3] lrArray;

  function run() public {
    // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

    bsArray[0] = PokemonStats(45,49,49,65,65,45);
    bsArray[1] = PokemonStats(60,62,63,80,80,60);
    bsArray[2] = PokemonStats(80,82,83,100,100,80);

    evArray[0] = PokemonStats(0,0,0,1,0,0);
    evArray[1] = PokemonStats(0,0,0,1,1,0);
    evArray[2] = PokemonStats(0,0,0,2,1,0);

    crArray = [45, 45, 45];
    iArray = [1,2,3];
    type1Array = [PokemonType.Grass, PokemonType.Grass, PokemonType.Grass];
    type2Array = [PokemonType.Poison, PokemonType.Poison, PokemonType.Poison];
    lrArray = [LevelRate.MediumSlow, LevelRate.MediumSlow, LevelRate.MediumSlow];

    for(uint i=0; i<bsArray.length; i++) {
      ICreatePokemonClassSystem(CreatePokemonClassSystem).executeTyped(
        bsArray[i], evArray[i], crArray[i], iArray[i], 
        type1Array[i], type2Array[i], lrArray[i]);
    }

    vm.stopBroadcast();



  }
}

interface ICreatePokemonClassSystem {
  function executeTyped(PokemonStats memory bs, PokemonStats memory ev, uint32 cr, uint32 i, 
  PokemonType type1, PokemonType type2, LevelRate lr) external returns (bytes memory);
}

interface IWorld {
  function getUniqueEntityId() external view returns (uint256);
}
