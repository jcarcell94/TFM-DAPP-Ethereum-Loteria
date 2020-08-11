pragma solidity ^0.5.11;

contract Loteria {
    // Dirección de la loteria
    address public loteriaDir;
    //Parametros loteria
    address payable public creador; //Creador de la Loteria, tambien sirve para identificar la loteria
    address payable public ganador; //Ganador de la Loteria
    uint public maxPart; // Numero maximo de participantes
    uint public precioParti; // Precio de participacion en wei
    uint public boteRec; // Bote a recaudar en la Loteria
    uint public premio; // Premio que obtendra el ganador de la Loteria
    
    // Estado actual de la Loteria
    uint public  partiAct; // Numero de participantes actuales
    uint public boteAct; // Bote recaudado hasta el momento
    enum Estado {Creada, Activa, Fallida, Finalizada, Terminada} // Enumeración de estados
    Estado public estado = Estado.Creada;
    
    
    // Lista dinamica de participantes
    address payable [] public participantes;
    
    // Struct participantes
    struct Participante{
        bool participa;
        uint balance;
    }
    // Mapping de las direcciones a balances
    mapping (address => Participante) public Participantes;
    
    
    // Eventos
    event LotteryActive(address _creador, address _loteria);
    event LotteryFailed(address _loteria);
    event LotteryFinished(address _loteria);
    event LotteryTerminated(address _loteria, address _ganador);
    
    // Creacion de la Loteria
    constructor (uint _maxPart, uint _precioParti, uint _boteRec, uint _premio) public{
    require((_premio < _maxPart*_precioParti || _premio < _boteRec) && _maxPart > 0 && _precioParti > 0 && _boteRec > 0 && _premio > 0, 'Parametros invalidos. El premio debe ser menor que el bote a recaudar y los parametros positivos.'); // COndicion de control
        loteriaDir = address(this);
        creador = tx.origin;
        maxPart = _maxPart;
        precioParti = _precioParti;
        boteRec = _boteRec;
        premio = _premio;
        partiAct = 0;
        boteAct = 0;
        estado = Estado.Activa;
        emit LotteryActive(creador, loteriaDir);
    }
    
    // Modificadores 
    modifier condition(bool _condition) {
        require(_condition);
        _;
    }
    
    modifier soloCreador() {
        require(tx.origin == creador, 'Solo el creador de la loteria puede acceder a esta funcíión.');
        _;
    }

    modifier soloParticipanteNuevo() {
        require(Participantes[tx.origin].participa == false, 'Solo se admiten nuevos participantes.');
        _;
    }
    
    modifier soloParticipanteExistente() {
        require(Participantes[tx.origin].participa == true, 'Usted no puede reclamar o ya ha reclamado.');
        _;
    }

    modifier inState(Estado _estado) {
        require(estado == _estado, 'Loteria en estado invalido.');
        _;
    }
    
    // Participar en la loteria
    function  participar() soloParticipanteNuevo inState(Estado.Activa) public payable {
        // Si las condiciones se cumplen añado al participante y modifico el estado de la loteria
        require(msg.value == precioParti,'Fondos insuficientes');
        participantes.push(tx.origin);
        partiAct ++;
        boteAct += precioParti;
        Participantes[tx.origin].balance = precioParti;
        Participantes[tx.origin].participa = true;
        // Control del estado de la loteria tras añadir un participante
        // Si se ha alcanzado el numero maximo de participantes pero no se ha llegado al bote a recaudar
        if (partiAct == maxPart && boteAct < boteRec) {
            estado = Estado.Fallida;
            emit LotteryFailed(loteriaDir);
        }
        // Si se llega al bote que se queria recaudar
        else if(boteAct >= boteRec){
            estado = Estado.Finalizada;
            emit LotteryFinished(loteriaDir);
        }
    }
    
    // Obtener un numero random
    function random() internal view returns (uint8) {
       require(participantes.length > 0);
       return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%(participantes.length));
   }
    
    // Sortear la Loteria
    function sortear() soloCreador inState(Estado.Finalizada) public payable{
        estado = Estado.Terminada;
        uint8 randomNum = random();
        ganador = participantes[randomNum];
        emit LotteryTerminated(loteriaDir, ganador);
        ganador.transfer(premio);
        creador.transfer(address(this).balance);
    }
    
    // Reclamar participacion 
    function reclamar() soloParticipanteExistente inState(Estado.Fallida) public payable {
        // Usando el patron ChecksEffectsInteractions
        // Primero chequeo
        require(Participantes[tx.origin].balance >= precioParti);
        // Efecto positivo anticipado
        Participantes[tx.origin].balance -= precioParti;
        // Por ultimo interaccion
        tx.origin.transfer(precioParti);
        partiAct --;
    }
    
    // Obtener el Estado
    function getStatus() public view returns (string memory) {
        if (estado == Estado.Activa){
            return "Activa en espera a participantes";
        }
        else if(estado == Estado.Fallida){
            return "Loteria fallida, los participantes pueden reclamar su participación.";
        }
        else if(estado == Estado.Finalizada){
            return "Loteria finalizada. No se admiten más participantes, pronto sera sorteada.";
        }
        else if(estado == Estado.Terminada){
            return "Loteria terminada.";
        }
        else {
            return "Lotería inexistente.";
        }
    }
    
    // Obtener lista de participantes
    function getParticipantes() public view returns (address payable [] memory) {
        return participantes;
    }
    
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
    
     function getLoteria() public view returns ( address _loteriaDir, address payable _creador, address payable _ganador, uint _maxPart, uint _precioParti, uint _boteRec, uint _boteAct) {
        return ( loteriaDir, creador, ganador, maxPart, precioParti, boteRec, boteAct);
    }
}
