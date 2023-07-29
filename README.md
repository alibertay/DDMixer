# Litepaper: DD Mixer - Privacy-Preserving BSC Testnet Token Mixer

# Abstract:
DD Mixer is a decentralized token mixer deployed on the Binance Smart Chain (BSC) Testnet. It aims to enhance the privacy and fungibility of tokens by breaking the on-chain transaction history and making it difficult to trace funds' origins. DD Mixer utilizes a queuing mechanism with multiple soldiers to mix tokens effectively. The smart contract is designed to ensure the secure and trustless mixing of tokens while keeping the gas costs as low as possible.

# 1. Introduction:
DD Mixer is a trustless and decentralized token mixing service deployed on the BSC Testnet. It provides users with a way to improve the privacy and anonymity of their BSC Testnet tokens. Traditional blockchain networks are transparent, which means that all transaction details, including sender and receiver addresses, are publicly visible. By using DD Mixer, users can break the link between the source and destination addresses, adding an extra layer of privacy to their transactions.

# 2. How DD Mixer Works:
# 2.1 Deposit:
    1. Users initiate the deposit process by sending 0.01 BNB (Testnet BNB) to the DD Mixer smart contract with a specified destination wallet hash.
    2. The deposited BNB is then divided into multiple portions based on the last digit of the current block number to determine the queuing limit (QueLimit).
    3. The BNB portions are distributed equally among a fixed number of soldiers (ActiveSoldiers). Each soldier represents a different address.
    4. The soldiers collectively form an "army" with a unique hash (AllHash) that includes their addresses and the specified destination wallet hash.
    5. The army hash is stored in the Army mapping for future reference.
# 2.2 Mixing:
    1. As new deposits are made, additional soldiers are added to the army until the queuing limit (QueLimit) is reached.
    2. Once the queuing limit is reached, soldiers start withdrawing funds from the DD Mixer smart contract in a specific order to prevent traceability.
    3. The withdrawn BNB is then forwarded to a designated Commission Wallet, and the Commission Ratio (set during contract deployment) is taken as the commission for the mixing service.
    4. The remaining BNB is equally distributed among the soldiers and sent to the destination address specified during the deposit.
# 2.3 Withdrawal:
    1. Users can initiate a withdrawal by providing the hash of the army they wish to withdraw from.
    2. The smart contract verifies the sender's authenticity and allows the withdrawal only to the original deposit sender.
    3. The contract then transfers the proportional BNB amount from the specified army to the user's wallet.
    4. If the withdrawal is attempted by any other address, the contract rejects the request and maintains the privacy of the original depositor.
# 3. How DD Mixer Differs from Other Mixers:
DD Mixer stands out from other token mixers due to the following unique features:
    • Dynamic Queuing: DD Mixer employs a queuing mechanism with a dynamically adjustable queuing limit based on the last digit of the current block number. This ensures optimal mixing efficiency and adapts to the network's load.
    • Multiple Soldiers: Unlike some mixers that use a single intermediary address, DD Mixer utilizes multiple soldiers (ActiveSoldiers) to ensure a higher level of privacy. Each soldier has a distinct address, adding complexity to the mixing process.
    • Commission Mechanism: DD Mixer includes a commission mechanism that allows the mixer operator to charge a commission for the mixing service. This commission is taken from the total amount deposited, ensuring incentives for maintaining the mixer's operation.
    • Gas Efficiency: The queuing mechanism reduces gas costs for users during the deposit and mixing phases, making DD Mixer a cost-effective solution for token mixing.
# 4. Security Considerations:
DD Mixer is designed with security in mind. However, it's essential for users to take some precautions:
    • Ensure that you're interacting with the correct DD Mixer contract address.
    • Double-check the destination wallet hash during the deposit to avoid accidental losses.
    • Verify the army hash before initiating a withdrawal to ensure you are withdrawing from the correct army.
# 5. Conclusion:
DD Mixer offers a reliable and privacy-preserving token mixing solution for users on the BSC Testnet. By leveraging a queuing mechanism and multiple soldiers, DD Mixer provides an efficient way to enhance the privacy and fungibility of BSC Testnet tokens. Users can trust the process to work without the need for intermediaries or compromising security. Please note that DD Mixer is currently deployed on the BSC Testnet and should be used for testing purposes only. It's crucial to exercise caution and use real funds only on the mainnet version (if available).
