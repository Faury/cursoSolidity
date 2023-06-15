// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

//Construir um contrato de aluguel que armazene:
//- nome do locador
//- nome do locatário
//- array com o valor do aluguel por 36 meses
contract Aluguel {
    uint8 public constant MAXIMO_NUMERO_PARCELAS = 36;
    ContratoAluguel public contratoAluguel;
    bytes32 internal passCode;

    struct ContratoAluguel {
        address locador;
        address locatario;
        uint256[MAXIMO_NUMERO_PARCELAS] valorAluguel;
    }

    //O nome das partes, locador e locatário, e o valor inicial de cada aluguel deve ser informado no momento da publicação do contrato.
    constructor(
        address _locatario,
        uint256 valorInicialAluguel,
        string memory _passCode
    ) {
        uint256[MAXIMO_NUMERO_PARCELAS] memory valoresAluguel;
        for (uint8 i = 0; i < valoresAluguel.length; i++) {
            valoresAluguel[i] = valorInicialAluguel;
        }

        contratoAluguel.locador = msg.sender;
        contratoAluguel.locatario = _locatario;
        contratoAluguel.valorAluguel = valoresAluguel;

        passCode = keccak256(bytes(_passCode));
    }

    modifier validateOperation(string memory _passCode) {
        require(
            contratoAluguel.locador == msg.sender,
            "Somente o locador pode alterar o contrato"
        );
        require(
            passCode == keccak256(bytes(_passCode)),
            "Passcode nao corresponde ao informado na criacao do contrato!"
        );
        _;
    }

    modifier somenteMesValido(uint8 _numeroMes) {
        require(_numeroMes < MAXIMO_NUMERO_PARCELAS, "Mes invalido");
        _;
    }

    //- funcao que recebe o numero do mes e retorna o valor do aluguel daquele mes
    function retornaValorAluguelMes(uint8 _numeroMes)
        public
        view
        somenteMesValido(_numeroMes)
        returns (uint256)
    {
        return contratoAluguel.valorAluguel[_numeroMes - 1];
    }

    //- funcao que retorna o nome do locador e do locatario
    function retornaLocadorLocatario()
        public
        view
        returns (address nomeLocador, address nomeLocatario)
    {
        return (contratoAluguel.locador, contratoAluguel.locatario);
    }

    //- funcao que altera o nome do locador se você passar o tipoPessoa 1 e alterna o nome do locatario se voce passar o tipoPessoa 2
    function alteraPessoa(
        address pessoa,
        uint8 tipoPessoa,
        string memory _passCode
    ) public validateOperation(_passCode) returns (bool) {
        if (tipoPessoa == 1) {
            contratoAluguel.locador = pessoa;
        } else if (tipoPessoa == 2) {
            contratoAluguel.locatario = pessoa;
        } else {
            revert(
                "Tipo de pessoa invalido, deve ser 1 para locador e 2 para locatario"
            );
        }

        return true;
    }

    //- funcao que reajusta os valores dos alugueis após de um determinado mes.
    //Exemplo: soma 100 aos alugueis depois do mes 15
    function alteraValorAluguel(
        uint8 _numeroMes,
        uint256 _valorNovoAluguel,
        string memory _passCode
    )
        public
        validateOperation(_passCode)
        somenteMesValido(_numeroMes)
        returns (bool)
    {
        require(_valorNovoAluguel > 0, "O novo valor deve ser preenchido!");

        for (
            uint8 i = _numeroMes - 1;
            i < contratoAluguel.valorAluguel.length;
            i++
        ) {
            contratoAluguel.valorAluguel[i] = _valorNovoAluguel;
        }

        return true;
    }
}

contract AluguelMobiliado is Aluguel {
    Mobilia internal mobilia;

    struct Mobilia {
        string[] items;
        mapping(string => string) descricaoItem;
    }

    constructor(
        address _locatario,
        uint256 valorInicialAluguel,
        string memory _passCode
    ) Aluguel(_locatario, valorInicialAluguel, _passCode) {}

    modifier somenteMobiliaPresente(string memory _itemMobilia) {
        bool found;
        for (uint256 i = 0; i < mobilia.items.length; i++) {
            if (
                keccak256(abi.encodePacked(mobilia.items[i])) ==
                keccak256(abi.encodePacked(_itemMobilia))
            ) {
                found = true;
                break;
            }
        }
        if (!found) {
            revert("Mobilia nao presente");
        }
        _;
    }

    modifier somenteMobiliaNaoPresente(string memory _itemMobilia) {
        bool found;
        for (uint256 i = 0; i < mobilia.items.length; i++) {
            if (
                keccak256(abi.encodePacked(mobilia.items[i])) ==
                keccak256(abi.encodePacked(_itemMobilia))
            ) {
                found = true;
                break;
            }
        }
        if (found) {
            revert("Mobilia ja cadastrada");
        }
        _;
    }

    //adiciona Mobilia
    function adicionaMobilia(
        string memory _itemMobilia,
        string memory _descricaoItem,
        string memory _passCode
    )
        public
        validateOperation(_passCode)
        somenteMobiliaNaoPresente(_itemMobilia)
        returns (bool)
    {
        mobilia.items.push(_itemMobilia);
        mobilia.descricaoItem[_itemMobilia] = _descricaoItem;

        return true;
    }

    //retorna Mobilia
    function retornaMobilia() public view returns (string[] memory) {
        return mobilia.items;
    }

    //retorna estadoMobilia
    function retornaEstadoMobilia(string memory _itemMobilia)
        public
        view
        somenteMobiliaPresente(_itemMobilia)
        returns (string memory)
    {
        return mobilia.descricaoItem[_itemMobilia];
    }
}
