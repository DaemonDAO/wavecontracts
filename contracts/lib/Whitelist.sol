/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   +@@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  -@@*     +@-  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    +@@-.#@#  =@%#.   :.     -@*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ +@#.-- .*%*. .#@@*@#  %@@%*#@@: .@@=-.         -%-   #%@:   +*-   =*@*   -@%=:
 * @@%   =##  +@@#-..%%:%.-@@=-@@+  ..   +@%  #@#*+@:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  +@*   #@#  +@@. -+@@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  =@=  :*@:=@@-:@+
 * -#%+@#-  :@#@@+%++@*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%+@#-   :*+**+=: %%++%*
 *
 * @title: Whitelist.sol
 * @author: @MaxFlowO2 on bird app/GitHub
 * @notice: Provides a whitelist capability that can be added to and removed easily.
 *
 * Include with 'using Whitelist for Whitelist.List;'
 */

// SPDX-License-Identifier: Apache-2.0

/******************************************************************************
 * Copyright 2022 Max Flow O2                                                 *
 *                                                                            *
 * Licensed under the Apache License, Version 2.0 (the "License");            *
 * you may not use this file except in compliance with the License.           *
 * You may obtain a copy of the License at                                    *
 *                                                                            *
 *     http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                            *
 * Unless required by applicable law or agreed to in writing, software        *
 * distributed under the License is distributed on an "AS IS" BASIS,          *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   *
 * See the License for the specific language governing permissions and        *
 * limitations under the License.                                             *
 ******************************************************************************/

pragma solidity >=0.8.0 <0.9.0;

import "./CountersV2.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

library Whitelist {
  using CountersV2 for CountersV2.Counter;

  event WhiteListEndChanged(uint _old, uint _new);
  event WhiteListChanged(bool _old, bool _new, address _address);
  event WhiteListStatus(bool _old, bool _new);

  // @dev: this is MaxSplaining(), giving you a reason, aka require(param, "reason")
  // @param reason: Use the "Contract name: error"
  // @notice: 0x0661b792 bytes4 of this
  error MaxSplaining(
    string reason
  );

  struct List {
    // These variables should never be directly accessed by users of the library: interactions must be restr>
    // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to>
    // this feature: see https://github.com/ethereum/solidity/issues/4637
    bool enabled; //default is false,
    CountersV2.Counter _added; // default 0, no need to _added.set(uint)
    CountersV2.Counter _removed; // default 0, no need to _removed.set(uint)
    uint end; // default 0, this can be time or quant
    mapping(address => bool) _list; // all values default to false
  }


  function add(List storage list, address _address) internal {
    if (list._list[_address]) {
      revert  MaxSplaining({
        reason : "WL1:1"
      });
    }
    // since now all previous values are false no need for another variable
    // and add them to the list!
    list._list[_address] = true;
    // increment counter
    list._added.increment();
    // emit event
    emit WhiteListChanged(false, list._list[_address], _address);
  }

  function remove(List storage list, address _address) internal {
    if (!list._list[_address]) {
      revert  MaxSplaining({
        reason : "WL1:2"
      });
    }
    // since now all previous values are true no need for another variable
    // and remove them from the list!
    list._list[_address] = false;
    // increment counter
    list._removed.increment();
    // emit event
    emit WhiteListChanged(true, list._list[_address], _address);
  }

  function enable(List storage list) internal {
    if (list.enabled) {
      revert  MaxSplaining({
        reason : "WL1:3"
      });
    }
    list.enabled = true;
    emit WhiteListStatus(false, list.enabled);
  }

  function disable(List storage list) internal {
    if (!list.enabled) {
      revert  MaxSplaining({
        reason : "WL1:4"
      });
    }
    list.enabled = false;
    emit WhiteListStatus(true, list.enabled);
  }

  function setEnd(List storage list, uint newEnd) internal {
    if (list.end == newEnd) {
      revert  MaxSplaining({
        reason : "WL1:5"
      });
    }
    uint old = list.end;
    list.end = newEnd;
    emit WhiteListEndChanged(old, list.end);
  }

  function status(List storage list) internal view returns (bool) {
    return list.enabled;
  }

  function totalAdded(List storage list) internal view returns (uint) {
    return list._added.current();
  }

  function totalRemoved(List storage list) internal view returns (uint) {
    return list._removed.current();
  }

  function onList(List storage list, address _address) internal view returns (bool) {
    return list._list[_address];
  }

  function showEnd(List storage list) internal view returns (uint) {
    return list.end;
  }
}
