// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Uint256Component } from "std-contracts/components/Uint256Component.sol";

uint256 constant ID = uint256(keccak256("component.BattleOfferTimestamp"));

uint256 constant OFFER_DURATION = 120;

// offerorID -> timestamp
contract BattleOfferTimestampComponent is Uint256Component {
  constructor(address world) Uint256Component(world, ID) {}
}
