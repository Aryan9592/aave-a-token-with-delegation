// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {ATokenWithDelegation, IATokenWithDelegation, IGovernancePowerDelegationToken} from '../src/contracts/ATokenWithDelegation.sol';
import {DelegationBaseTest} from './DelegationBaseTest.sol';

contract ATokenWithDelegationTest is DelegationBaseTest {
  address constant USER_1 = address(123);
  address constant USER_2 = address(1234);

  function testGovernancePowerTransferByTypeVoting()
    public
    mintAmount(USER_2)
    validateUserTokenBalance(USER_2)
  {
    // TODO: not working
    // adding some previous delegation
    _delegatedBalances[USER_2].delegatedVotingBalance = uint72(20);

    uint104 impactOnDelegationBefore = uint104(5 ether);
    uint104 impactOnDelegationAfter = uint104(10 ether);

    uint104 delegationVotingPowerBefore = _getDelegationBalanceByType(
      USER_2,
      IGovernancePowerDelegationToken.GovernancePowerType.VOTING
    );

    _governancePowerTransferByType(
      impactOnDelegationBefore,
      impactOnDelegationAfter,
      USER_2,
      IGovernancePowerDelegationToken.GovernancePowerType.VOTING
    );

    uint104 delegationVotingPowerAfter = _getDelegationBalanceByType(
      USER_2,
      IGovernancePowerDelegationToken.GovernancePowerType.VOTING
    );

    uint72 impact = uint72(impactOnDelegationBefore / POWER_SCALE_FACTOR) +
      uint72(impactOnDelegationAfter / POWER_SCALE_FACTOR);

    assertEq(delegationVotingPowerAfter, delegationVotingPowerBefore - impact);
  }

  function testGovernancePowerTransferByTypeWhenDelegationReceiverIsAddress0()
    public
    validateNoChanges(address(0), IGovernancePowerDelegationToken.GovernancePowerType.VOTING)
  {
    uint104 impactOnDelegationBefore = uint104(1 ether);
    uint104 impactOnDelegationAfter = uint104(12 ether);
    _governancePowerTransferByType(
      impactOnDelegationBefore,
      impactOnDelegationAfter,
      address(0),
      IGovernancePowerDelegationToken.GovernancePowerType.VOTING
    );
  }

  function testGovernancePowerTransferByTypeWhenSameImpact()
    public
    mintAmount(USER_2)
    validateNoChanges(USER_2, IGovernancePowerDelegationToken.GovernancePowerType.VOTING)
    validateUserTokenBalance(USER_2)
  {
    uint104 impactOnDelegationBefore = uint104(12 ether);
    uint104 impactOnDelegationAfter = uint104(12 ether);
    _governancePowerTransferByType(
      impactOnDelegationBefore,
      impactOnDelegationAfter,
      USER_2,
      IGovernancePowerDelegationToken.GovernancePowerType.VOTING
    );
  }

  function testDelegateTypeVotingPowerToUser()
    public
    mintAmount(USER_1)
    validateDelegationPower(
      USER_1,
      USER_2,
      IGovernancePowerDelegationToken.GovernancePowerType.VOTING
    )
    validateDelegationState(USER_1, USER_2, DelegationType.VOTING)
    validateDelegationReceiver(
      USER_1,
      USER_2,
      IGovernancePowerDelegationToken.GovernancePowerType.VOTING
    )
    validateUserTokenBalance(USER_1)
    validateUserTokenBalance(USER_2)
  {
    _delegateByType(USER_1, USER_2, IGovernancePowerDelegationToken.GovernancePowerType.VOTING);
  }
}
