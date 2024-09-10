deploy-anvil:
	forge script script/FundEth.s.sol --rpc-url http://127.0.0.1:8545 --account LOCALKEY --broadcast

deploy-alchemy-sepolia:
	forge script script/FundEth.s.sol --rpc-url https://eth-sepolia.g.alchemy.com/v2/2--p6ZDtk8xsVORFeHhkI0sddVWSQ_YM --account TESTNETKEY --broadcast $(EXTRA_ARGS)

deploy-infura-sepolia:
	forge script script/FundEth.s.sol --rpc-url https://sepolia.infura.io/v3/2cd230906a824872a924bfff7ec92ecc --account TESTNETKEY --broadcast $(EXTRA_ARGS)

verify-contract:
	forge verify-contract $(CONTRACT_ADDRESS) $(CONTRACT_PATH) --etherscan-api-key $(API_KEY)

test-alchemy-sepolia:
	forge test --fork-url https://eth-sepolia.g.alchemy.com/v2/2--p6ZDtk8xsVORFeHhkI0sddVWSQ_YM $(EXTRA_ARGS)

test-infura-sepolia:
	forge test --fork-url https://sepolia.infura.io/v3/2cd230906a824872a924bfff7ec92ecc $(EXTRA_ARGS)

