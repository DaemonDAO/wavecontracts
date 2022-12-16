/*     +%%#-                           ##.        =+.    .+#%#+:       *%%#:    .**+-      =+
 *   .%@@*#*:                          @@: *%-   #%*=  .*@@=.  =%.   .%@@*%*   +@@=+=%   .%##
 *  .%@@- -=+                         *@% :@@-  #@=#  -@@*     +@-  :@@@: ==* -%%. ***   #@=*
 *  %@@:  -.*  :.                    +@@-.#@#  =@%#.   :.     -@*  :@@@.  -:# .%. *@#   *@#*
 * *%@-   +++ +@#.-- .*%*. .#@@*@#  %@@%*#@@: .@@=-.         -%-   #%@:   +*-   =*@*   -@%=:
 * @@%   =##  +@@#-..%%:%.-@@=-@@+  ..   +@%  #@#*+@:      .*=     @@%   =#*   -*. +#. %@#+*@
 * @@#  +@*   #@#  +@@. -+@@+#*@% =#:    #@= :@@-.%#      -=.  :   @@# .*@*  =@=  :*@:=@@-:@+
 * -#%+@#-  :@#@@+%++@*@*:=%+..%%#=      *@  *@++##.    =%@%@%%#-  =#%+@#-   :*+**+=: %%++%*
 *
 * @title: IMAX721.sol
 * @author: Max Flow O2 -> @MaxFlowO2 on bird app/GitHub
 * @notice: Interface for UX/UI
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

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IMAX721 is IERC165 {

  // @dev will return status of Minter
  // @return - bool of active or not
  function minterStatus() 
    external
    view
    returns (bool);

  // @dev will return minting fees
  // @return - uint of mint costs in wei
  function minterFees()
    external
    view
    returns (uint);

  // @dev will return maximum mint capacity
  // @return - uint of maximum mints allowed
  function minterCapacity()
    external
    view
    returns (uint);

  // @dev will return maximum mint capacity
  // @return - uint of maximum mints allowed
  function minterMinted()
    external
    view
    returns (uint);

  // @dev will return maximum "team minting" capacity
  // @return - uint of maximum airdrops or team mints allowed
  function minterTeamMintsCapacity()
    external
    view
    returns (uint);


  // @dev will return "team mints" count
  // @return - uint of airdrops or team mints done
  function minterTeamMintsMinted()
    external
    view
    returns (uint);

  // @dev: will return total supply for mint
  // @return: uint for this mint
  function totalSupply()
    external
    view
    returns (uint256);
}

