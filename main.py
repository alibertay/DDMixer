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
    contract_address = '0xeC3c03fB8bF1e9EF58C35e98C3db4aFC8df9Ad4a'
    contract_abi = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_CommisionWallet",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_CommisionRatio",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
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
		"name": "getLastBlockDigit",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
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
	}
]

    web3 = Web3(Web3.HTTPProvider(bsc_testnet_url))

    web3.middleware_onion.inject(geth_poa_middleware, layer=0)

    contract = web3.eth.contract(address=contract_address, abi=contract_abi)

    addressAsList = [str(name)]
    result = contract.functions.hashAddressList(addressAsList).call()

    print("sıkıntı")
    return f"To Wallet Hash: {result}"

if __name__ == '__main__':
    app.run(debug=True)
