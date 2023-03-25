// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";

// used for base stats, effort value (EV), individual value (IV)
// we stick with the original game where one byte (uint8) is used to store each value

struct PokemonStats {
    uint16 HP; // max health; H
    uint16 ATK; // attack; A
    uint16 DEF; // defence; B
    uint16 SPATK; // special attack; C
    uint16 SPDEF; // special defence; D
    uint16 SPD; // speed; S
}

contract PokemonStatsComponent is Component {
  constructor(address world, uint256 ID) Component(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](6);
    values = new LibTypes.SchemaValue[](6);

    keys[0] = "HP";
    values[0] = LibTypes.SchemaValue.UINT16;

    keys[1] = "ATK";
    values[1] = LibTypes.SchemaValue.UINT16;

    keys[2] = "DEF";
    values[2] = LibTypes.SchemaValue.UINT16;

    keys[3] = "SPATK";
    values[3] = LibTypes.SchemaValue.UINT16;

    keys[4] = "SPDEF";
    values[4] = LibTypes.SchemaValue.UINT16;

    keys[5] = "SPD";
    values[5] = LibTypes.SchemaValue.UINT16;
  }

  function set(uint256 entity, PokemonStats calldata stats) public virtual {
    set(entity, abi.encode(stats));
  }

  function getValue(uint256 entity) public view virtual returns (PokemonStats memory stats) {
    stats = abi.decode(getRawValue(entity), (PokemonStats));
  }
}