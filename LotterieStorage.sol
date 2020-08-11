pragma solidity ^0.5.11;

contract LotterieStorage{
    
    address[] public lotteries;
    address storageDir;
    
    constructor() public {
    }
    
    function addLotterie(address _lot) public {
        lotteries.push(_lot);
    }
    
    function getLotteries() public view returns(address[] memory){
        return lotteries;
    }
    
    function getDir() public view returns(address _dir){
        return address(this);
    }
}
