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




### Deployment
```sh
forge script script/DeployTicketFactory.s.sol:DeployFactoryScript --rpc-url $SCROLL_RPC_URL --broadcast -vvvv --ffi --verify
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
