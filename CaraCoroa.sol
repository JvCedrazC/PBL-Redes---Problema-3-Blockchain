// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ApostaCaraCoroa {
    address public dono; // Endereço do criador do contrato
    uint256 public valorAposta; // Valor fixo para cada aposta
    address[] public apostadoresCara; // Lista de apostadores cara
    address[] public apostadoresCoroa; // Lista de apostadores coroa
    bool public resultadoDefinido; // Indica se o resultado foi definido
    string public resultado; //cara ou coroa

    // Construtor: define o dono e o valor da aposta
    constructor(uint256 _valorAposta) {
        dono = msg.sender;
        valorAposta = _valorAposta;
    }

    // Função para apostar
    function apostar(string memory escolha) public payable {
        require(msg.value == valorAposta, "Valor da aposta incorreto");
        require(!resultadoDefinido, "O evento ja foi finalizado");
        require(
            keccak256(abi.encodePacked(escolha)) == keccak256("cara") ||
            keccak256(abi.encodePacked(escolha)) == keccak256("coroa"),
            "Escolha invalida"
        );

        if (keccak256(abi.encodePacked(escolha)) == keccak256("cara")) {
            apostadoresCara.push(msg.sender);
        } else {
            apostadoresCoroa.push(msg.sender);
        }
    }

    // Função para definir o resultado (somente pelo dono)
    function definirResultado(string memory _resultado) public {
        require(msg.sender == dono, "Apenas o dono pode definir o resultado");
        require(
            keccak256(abi.encodePacked(_resultado)) == keccak256("cara") ||
            keccak256(abi.encodePacked(_resultado)) == keccak256("coroa"),
            "Resultado invalido"
        );
        require(!resultadoDefinido, "O resultado ja foi definido");

        resultado = _resultado;
        resultadoDefinido = true;

        // Distribui os prêmios
        distribuirPremios();
    }

    // Função para distribuir os prêmios
    function distribuirPremios() private {
        address[] memory vencedores;
        if (keccak256(abi.encodePacked(resultado)) == keccak256("cara")) {
            vencedores = apostadoresCara;
        } else {
            vencedores = apostadoresCoroa;
        }

        uint256 premioTotal = address(this).balance;
        uint256 premioPorVencedor = premioTotal / vencedores.length;

        for (uint256 i = 0; i < vencedores.length; i++) {
            payable(vencedores[i]).transfer(premioPorVencedor);
        }
    }

    // Função para verificar o saldo do contrato
    function saldoContrato() public view returns (uint256) {
        return address(this).balance;
    }
}
