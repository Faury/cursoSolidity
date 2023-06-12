 // SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

//Construir um contrato de aluguel que armazene:
//- nome do locador
//- nome do locatário
//- array com o valor do aluguel por 36 meses
contract Aluguel {

    uint8 constant public MAXIMO_NUMERO_PARCELAS = 36;
    ContratoAluguel private contratoAluguel;

    struct ContratoAluguel {
        string locador;
        string locatario;
        uint256[MAXIMO_NUMERO_PARCELAS] valorAluguel;
        string[] mobilia;
        mapping(string => string) estadoMobilia; 
    }

    //O nome das partes, locador e locatário, e o valor inicial de cada aluguel deve ser informado no momento da publicação do contrato.
    constructor(string memory _locador, string memory _locatario, uint256 valorInicialAluguel) {

        uint256[MAXIMO_NUMERO_PARCELAS] memory valoresAluguel;
        for (uint8 i=0; i<valoresAluguel.length; i++) {
            valoresAluguel[i] = valorInicialAluguel;
        }

        contratoAluguel.locador =  _locador;
        contratoAluguel.locatario = _locatario;
        contratoAluguel.valorAluguel = valoresAluguel;
    }

    modifier somenteMesValido(uint8 _numeroMes) {
        require(_numeroMes < MAXIMO_NUMERO_PARCELAS, "Mes invalido");
        _;
    }

//- funcao que recebe o numero do mes e retorna o valor do aluguel daquele mes
    function retornaValorAluguelMes(uint8 _numeroMes) public view somenteMesValido(_numeroMes) returns (uint256) {
        return contratoAluguel.valorAluguel[_numeroMes-1];
    }

//- funcao que retorna o nome do locador e do locatario
    function retornaLocadorLocatario() public view returns (string memory nomeLocador, string memory nomeLocatario) {
        return (contratoAluguel.locador, contratoAluguel.locatario);
    }

//- funcao que altera o nome do locador se você passar o tipoPessoa 1 e alterna o nome do locatario se voce passar o tipoPessoa 2
    function alteraPessoa(string memory pessoa, uint8 tipoPessoa) public returns (bool) {
        
        if (tipoPessoa == 1) {
            contratoAluguel.locador = pessoa;
        } else if (tipoPessoa == 2) {
            contratoAluguel.locatario = pessoa;
        } else {
            revert("Tipo de pessoa invalido, deve ser 1 para locador e 2 para locatario");
        }

        return true;
    }

//- funcao que reajusta os valores dos alugueis após de um determinado mes. 
//Exemplo: soma 100 aos alugueis depois do mes 15
    function alteraValorAluguel(uint8 _numeroMes, uint256 _valorNovoAluguel) public somenteMesValido(_numeroMes) returns (bool) {
        require(_valorNovoAluguel>0, "O novo valor deve ser preenchido!");
        
        for (uint8 i=_numeroMes-1; i < contratoAluguel.valorAluguel.length; i++) {
            contratoAluguel.valorAluguel[i] = _valorNovoAluguel;
        }

        return true;
    }

    //adiciona Mobilia
    function adicionaMobilia(string memory _itemMobilia, string memory _estadoItem) public returns (bool) {
        
        contratoAluguel.mobilia.push(_itemMobilia);
        contratoAluguel.estadoMobilia[_itemMobilia] = _estadoItem;

        return true;
    }

    //retorna Mobilia
    function retornaMobilia() public view returns (string[] memory) {
        return contratoAluguel.mobilia;
    }

    //retorna estadoMobilia
    function retornaEstadoMobilia(string memory _mobilia) public view returns (string memory) {
        bool found;
        for (uint i=0;i<contratoAluguel.mobilia.length;i++) {
            if (keccak256(abi.encodePacked(contratoAluguel.mobilia[i])) == keccak256(abi.encodePacked(_mobilia))) {
                found = true;
                break;
            }
        }
        if (!found) {
            revert("Mobilia nao presente");
        }
        
        return contratoAluguel.estadoMobilia[_mobilia];
    }
}

//https://sepolia.etherscan.io/address/0xD1778c44E2f804DaD77B0cE628434105Fe17f0B0
