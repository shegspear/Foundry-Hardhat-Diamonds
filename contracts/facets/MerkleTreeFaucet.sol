import {LibDiamond} from "../libraries/LibDiamond.sol";
import {MerkleProof} from "../libraries/MerkleProof.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {CustomErrors} from "../libraries/CustomErrors.sol";
import {CustomEvents} from "../libraries/CustomEvents.sol";

contract MerkleTreeFaucet {

    function verify(
        bytes32[] memory proof,
        uint256 _amount
    )
        public
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if(msg.sender == address(0)) {
            revert CustomErrors.VillagePeopleOOO();
        }

        if(_amount == 0) {
            revert CustomErrors.HowBrokeAreYou();
        }

        // bytes32 computedHash = keccak256(abi.encodePacked(msg.sender, _amount));
        bytes32 computedHash = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, _amount))));

        bool valid = MerkleProof.verify(proof, ds.merkleRoot, computedHash);

        if(valid == true) {
            ds.approvedUsers[msg.sender] = true;
            ds.users[msg.sender] = _amount;
            emit CustomEvents.YouQualify(msg.sender);
        } else {
            emit CustomEvents.YouDontQualify(msg.sender);
        }
    }

    function claimAirdrop() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        if(msg.sender == address(0)) {
            revert CustomErrors.VillagePeopleOOO();
        }

        if(ds.approvedUsers[msg.sender] == false) {
            revert CustomErrors.YouAreNotEligible();
        }

        if(ds.paymentLedger[msg.sender] == true) {
            revert CustomErrors.RewardAlreadyClaimed();
        }


        IERC20(ds.tokenAddress).transfer(msg.sender, ds.users[msg.sender]);

        ds.paymentLedger[msg.sender] == true;

        emit CustomEvents.RewardClaimed(msg.sender, ds.users[msg.sender]);
    }

    function updateMerkleTree(bytes32 _merkleTree) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        if(msg.sender == address(0)) {
            revert CustomErrors.VillagePeopleOOO();
        }

        if(msg.sender == ds.contractOwner) {
            revert CustomErrors.YourFather();
        }

        ds.merkleRoot = _merkleTree;
    }

    function collectRemainingAirdrop() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        if(msg.sender == address(0)) {
            revert CustomErrors.VillagePeopleOOO();
        }

        if(msg.sender == ds.contractOwner) {
            revert CustomErrors.YourFather();
        }

        uint256 balance = IERC20(ds.tokenAddress).balanceOf(address(this));

        IERC20(ds.tokenAddress).transfer(msg.sender, balance);
    }
}