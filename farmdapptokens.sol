// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract farming {		
	using SafeERC20 for IERC20;
	IERC20 private dappToken;
	IERC20 public daiToken;

    
	

	uint256 month = 2629743;

	struct Staker {
        uint256 amount;
        uint256 timestamp;
    }
	mapping(address => Staker) public stakes;


	constructor(address _dappToken, address _daiToken) {
        dappToken = IERC20 (_dappToken);
		daiToken = IERC20 (_daiToken);
		
	}

	event Stake(address indexed owner, uint256 amount, uint256 time);
    event UnStake(address indexed owner, uint256 amount, uint256 time, uint256 rewardTokens);

	
	function calculateRate() private view returns(uint8) {
        uint256 time = stakes[msg.sender].timestamp;
        if(block.timestamp - time < month) {
            return 0;
        } else if(block.timestamp - time <  month * 6 ) {
            return 20;
        } else if(block.timestamp - time < 12 * month) {
            return 40;
        } else {
            return 60;
        }
    }
	
	
	function stakeToken( uint256 _amount) public  {
       require(daiToken.balanceOf(msg.sender) >= _amount,'you dont have enough balance');
        
        stakes[msg.sender] = Staker( _amount, block.timestamp);
        
        daiToken.safeTransferFrom(msg.sender, address(this), _amount);  
        
        emit Stake (msg.sender, _amount, block.timestamp);

        
    }

	
	function unStakeToken( uint256 _amount) public {
        stakes[msg.sender].amount -= _amount;
        daiToken.safeTransferFrom( address(this), msg.sender, _amount);


        uint256 time = block.timestamp - stakes[msg.sender].timestamp;
        uint256 reward =  calculateRate() * time * _amount * 10 ** 18 / month * 12   ;

        dappToken.safeTransfer( msg.sender, reward);

        emit UnStake(msg.sender, _amount,  block.timestamp, reward);
    }

}
