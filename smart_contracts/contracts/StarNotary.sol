pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

contract StarNotary is ERC721 {

    struct Coordinator {
        string ra;
        string dec;
        string mag;
        string cent;
    }

    struct Star {
        string name;
        Coordinator coordinator;
        string story;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;
    mapping(uint256 => bool) public coordinatorTaken;

    function createStar(string _name, string _story, string _ra, string _dec, string _mag, string _cent, uint256 _tokenId) public {
        require(checkIfStarExist(_tokenId) == false, "Star is already exist");

        Coordinator memory newCoordinator = Coordinator(_ra, _dec, _mag, _cent);
        Star memory newStar = Star(_name, newCoordinator, _story);

        tokenIdToStarInfo[_tokenId] = newStar;
        coordinatorTaken[uint256(keccak256(_ra, _dec, _mag, _cent))] = true;

        _mint(msg.sender, _tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(this.ownerOf(_tokenId) == msg.sender);

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0);

        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);
        require(msg.value >= starCost);

        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);

        starOwner.transfer(starCost);

        if (msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
    }

    function checkIfStarExist(uint256 _tokenId) private returns (bool){
        Coordinator memory coordinator = tokenIdToStarInfo[_tokenId].coordinator;
        return coordinatorTaken[uint256(keccak256(coordinator.ra, coordinator.dec, coordinator.mag, coordinator.cent))];
    }

    function starsForSale(uint256 _tokenId) public view returns(uint256){
        return starsForSale[_tokenId];
    }

    function tokenIdToStarInfo(uint256 _tokenId) public view returns (string, string, string, string, string){
        return (tokenIdToStarInfo[_tokenId].name, tokenIdToStarInfo[_tokenId].story, tokenIdToStarInfo[_tokenId].coordinator.ra, tokenIdToStarInfo[_tokenId].coordinator.dec, tokenIdToStarInfo[_tokenId].coordinator.mag);
    }

}