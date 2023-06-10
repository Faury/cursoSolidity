 // SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

//Construir um contrato de aluguel que armazene:
//- nome do locador
//- nome do locatário
//- array com o valor do aluguel por 36 meses
contract Aluguel {

    string public locador;
    string public locatario;
    uint256[36] public valorAluguel;

    //O nome das partes, locador e locatário, e o valor inicial de cada aluguel deve ser informado no momento da publicação do contrato.
    constructor(string memory _locador, string memory _locatario, uint256 valorInicialAluguel) {
        locador = _locador;
        locatario = _locatario;

        for (uint8 i=0; i<valorAluguel.length; i++) {
            valorAluguel[i] = valorInicialAluguel;
        }
    }

//O contrato também deve ter:

//- funcao que recebe o numero do mes e retorna o valor do aluguel daquele mes
    function retornaValorAluguelMes(uint256 numeroMes) public view returns (uint256) {
        if (numeroMes > 36) {
            return 0;
        }
        
        return valorAluguel[numeroMes-1];
    }

//- funcao que retorna o nome do locador e do locatario
    function retornaLocadorLocatario() public view returns (string memory nomeLocador, string memory nomeLocatario) {
        return (locador, locatario);
    }

//- funcao que altera o nome do locador se você passar o tipoPessoa 1 e alterna o nome do locatario se voce passar o tipoPessoa 2
    function alteraPessoa(string memory pessoa, uint8 tipoPessoa) public returns (bool) {
        
        if (tipoPessoa == 1) {
            locador = pessoa;
        } else if (tipoPessoa == 2) {
            locatario = pessoa;
        } else {
            return false;
        }

        return true;
    }

//- funcao que reajusta os valores dos alugueis após de um determinado mes. 
//Exemplo: soma 100 aos alugueis depois do mes 15
    function alteraValorAluguel(uint8 numeroMes, uint256 valorNovoAluguel) public returns (bool) {
        if (numeroMes > 36) {
            return false;
        }
        
        for (uint8 i=numeroMes-1; i < valorAluguel.length; i++) {
            valorAluguel[i] = valorNovoAluguel;
        }

        return true;
    }


}

//https://sepolia.etherscan.io/address/0x3F5Bee678C541437F789465FEE265478B11e5B9d
