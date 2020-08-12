pragma solidity ^0.5.11;

/**
* @title LotterieStorage
* @dev El contrato LotterieStorage implementa la parte del almacenamiento de las loterias
* Sus funciones permiten modificar la lista de loterias, devolver la misma y proporciona un
* un mecanismo para que solo la ultima version de lotterieFactory use el LotterieStorage.
*/

contract LotterieStorage{
    
    address[] public lotteries;
    address factoryAddress;
    
    // Eventos
    event FactoryChanged(address indexed previousOwner, address indexed newOwner);
    event LotterieStorageCreated(address indexed lotterieFactory, address indexed lotterieStorage);
    
    constructor() public {
        factoryAddress = msg.sender;
        emit LotterieStorageCreated(factoryAddress, address(this));
    }
    
    modifier onlyFactory() {
        require(msg.sender == factoryAddress, 'Only last factory version');
        _;
    }
    
    function addLotterie(address _lot) onlyFactory public {
        lotteries.push(_lot);
    }
    
    function getLotteries() public view onlyFactory returns(address[] memory){
        return lotteries;
    }
    
    function getDir() public view onlyFactory returns(address _dir){
        return address(this);
    }
    
    function changeFactory(address newFactory) public onlyFactory {
        _changeFactory(newFactory); 
    }
    
    function _changeFactory(address newFactory) internal {
        require(factoryAddress != address(0), "Ownable: new owner is the zero address"); emit FactoryChanged(factoryAddress, newFactory);
        factoryAddress = newFactory;
    }
    
    // Fallback function
    function() external payable{
        require(msg.value == 0, 'Este contrato no acepta Ether');
    }
    
}
