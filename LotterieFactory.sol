pragma solidity ^0.5.11;

import './Loteria.sol';
import './LotterieStorage.sol';

contract LotterieFactory {
   
   LotterieStorage public lotterieStorage;
   
   constructor() public{
      lotterieStorage = new LotterieStorage();
   }
    
    // Crear una nueva loteria y añadir la dirección
    function createLottery( uint _maxPart, uint _precioParti, uint _boteRec, uint _premio) public{
        Loteria newLottery = new Loteria( msg.sender, _maxPart,  _precioParti,  _boteRec,  _premio);
        lotterieStorage.addLotterie(address(newLottery));
    }
    
    // Devuelve una lista de las direcciones de las loterias
    function getLotteries() public view returns (address[] memory){
        return lotterieStorage.getLotteries();
    }
    
    // Devuelve la información de la loteria
    function getLottery(address lotteryAddress) public view returns (address _loteriaDir, address payable _creator, address payable _winner, uint _maxPart, uint _precioParti, uint _boteRec, uint _boteAct){
        Loteria lottery = Loteria(lotteryAddress);
        return lottery.getLoteria();
    }
    
    // Devuelve el estado de una loteria
    function getStatus(address lotteryAddress) public view returns(string memory){
        Loteria lottery = Loteria(lotteryAddress);
        return lottery.getStatus();
    }
    
    // Lista de los participantes
    function getParticipants(address lotteryAddress) public view returns (address payable [] memory){
        Loteria lottery = Loteria(lotteryAddress);
        return lottery.getParticipantes();
    }
    
    // Añadir participante a una Loteria
    function addParticipant(address lotteryAddress) public payable{
        Loteria lottery = Loteria(lotteryAddress);
        lottery.participar.value(msg.value)(msg.sender);
    }
    
    // Retirar participación
    function withdrawParticipation(address lotteryAddress) public payable{
        Loteria lottery = Loteria(lotteryAddress);
        lottery.reclamar(msg.sender);
    }
    
    // Rifar la Loteria
    function raffle(address lotteryAddress) public payable{
        Loteria lottery = Loteria(lotteryAddress);
        lottery.sortear(msg.sender);
    }
    
}
