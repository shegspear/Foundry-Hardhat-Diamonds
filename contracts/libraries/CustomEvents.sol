library CustomEvents {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event YouQualify(address _account);
    event YouDontQualify(address _account);
    event RewardClaimed(address _account, uint256 _amount);
}