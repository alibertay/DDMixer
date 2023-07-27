from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/popup', methods=['POST'])
def popup():
    name = request.form['name']
    return jsonify({'name': name})

@app.route('/get_message', methods=['POST'])
def get_message():
    name = request.form['name']
    message = hashWithKeccak(name)
    return jsonify({'message': message})

def hashWithKeccak(name):
    from web3 import Web3
    from web3.middleware import geth_poa_middleware

    bsc_testnet_url = 'https://data-seed-prebsc-1-s1.binance.org:8545/'
    contract_address = '0xBB222923D7faB47657B61ED697e0F55A97B2dcd4'
    contract_abi = [
	{
		"inputs": [],
		"name": "commision",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "_toWalletHash",
				"type": "bytes32"
			}
		],
		"name": "deposit",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "_armyHash",
				"type": "bytes32"
			}
		],
		"name": "withdraw",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"stateMutability": "payable",
		"type": "receive"
	},
	{
		"inputs": [
			{
				"internalType": "bool",
				"name": "isDeposit",
				"type": "bool"
			}
		],
		"name": "getLastBlockDigit",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address[]",
				"name": "addresses",
				"type": "address[]"
			}
		],
		"name": "hashAddressList",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "value1",
				"type": "bytes32"
			},
			{
				"internalType": "bytes32",
				"name": "value2",
				"type": "bytes32"
			}
		],
		"name": "hashValues",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	}
]

    web3 = Web3(Web3.HTTPProvider(bsc_testnet_url))

    web3.middleware_onion.inject(geth_poa_middleware, layer=0)

    contract = web3.eth.contract(address=contract_address, abi=contract_abi)

    addressAsList = [str(web3.to_checksum_address(name))]
    result = contract.functions.hashAddressList(addressAsList).call()

    result = bytes32_to_string(result)
    return f"To Wallet Hash: {result}"

def bytes32_to_string(bytes32_value):
    hex_string = f"0x{str(bytes32_value.hex())}"

    return hex_string

if __name__ == '__main__':
    app.run(debug=True)