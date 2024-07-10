## Event Ticketing System
---------------------------
This is an event ticketing system built with decentralization in view.

**Project contains**
1. `TicketFactory`
2. `Ticket`
3. `TicketWithWhitelist`

##### TicketFactory
This smart contract is used to develop `Ticket` or `TicketWithWhitelist`. This is to an extent the pillar event management system.

##### Ticket
This smart contract represent and Event ticket, in this system, Event can be of different Classes. `Vip`, `Regular` and so on.

##### TicketWithWhitelist
This smart contract simiar to `Ticket` represent an Event ticket, but however this one is `Whitelisted` and the white list is hanlded by the admim.




### Deployment (development)
```sh
forge script script/MockDeployTicketFactory.s.sol:DeployFactoryScript --rpc-url $SCROLL_RPC_URL --broadcast -vvvv --ffi --verify   
```


## Deployment (Production)

#### Build

```bash
forge build
```

### Run Tests
```bash
forge test
```

### Create .env file
Using the `.env-example` format, create a `.emv` file containing the correct details. 

```text
PRIVATE_KEY=
ETHERSCAN_API_KEY=
SCROLL_RPC_URL=

FACTORY_OWNER=
FACTORY_TRUSTED_FORWARDER=
TICKET_TRUSTED_FORWARDER=
```

Overview of `.env` variables 
1. PRIVATE_KEY: This is the deployment private key, this is the address having gas fees on scroll to be used to pay for the gas needed for deployment. This account does not have an admin right. 
2. ETHERSCAN_API_KEY: this is just used for verifying the smart contracts.
3. SCROLL_RPC_URL: This is the RPC endpoint for SCROLL
4. FACTORY_OWNER: This is the address managing the Ticket factory contract admin rights.
5. FACTORY_TRUSTED_FORWARDER:  This is the Trusted Forwarder for the Event factory. This plays a very important role in gas-less transactions.
6. TICKET_TRUSTED_FORWARDER: This is very similar to `FACTORY_TRUSTED_FORWARDER` for for the `Ticket` contract this time.

### Running Deployment scripts

1. **Bring `.env` into terminal scope**: 
```bash
source .env
```
2. **Run Deployment Script**: 
```bash
forge script script/DeployScript.s.sol:DeployScript --rpc-url $SCROLL_RPC_URL --broadcast -vvvv --ffi --verify  
```

