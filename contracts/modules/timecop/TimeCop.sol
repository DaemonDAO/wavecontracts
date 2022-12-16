/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   +@@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  -@@*     +@-  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    +@@-.#@#  =@%#.   :.     -@*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ +@#.-- .*%*. .#@@*@#  %@@%*#@@: .@@=-.         -%-   #%@:   +*-   =*@*   -@%=:
 * @@%   =##  +@@#-..%%:%.-@@=-@@+  ..   +@%  #@#*+@:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  +@*   #@#  +@@. -+@@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  =@=  :*@:=@@-:@+
 * -#%+@#-  :@#@@+%++@*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%+@#-   :*+**+=: %%++%*
 *
 * @title: TimeCop.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Time based mechanism for Solidity
 * @custom:error-code TC:E1 State not set
 * @custom:change-log added custom error code
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

import "./ITimeCop.sol";
import "../../access/MaxAccess.sol";

abstract contract TimeCop is MaxAccess {

  uint internal startSale;

  event SaleSet(uint start, uint length);

  function setStartTime(
    uint time
  ) external
    onlyDev() {
    startSale = time;
    emit SaleSet(time, duration);
  }

  function showStart()
    external
    view
    virtual
    returns (uint) {
    return startSale;
  }

  modifier onlySale() {
    if (block.timestamp < startSale) {
      revert TooSoonJunior({
        yourTime: block.timestamp
      , hitTime: startSale
      });
    }
    if (startPresale == 0) {
      revert MaxSplaining({
        reason: "TC:E1"
      });
    }
    _;
  }
}
