// This file holds function that gets all the ticket owners from blockchain events



export const getEventsFromBlockToBlockWithAddress = async (
    contract,
    eventName,
    fromBlock,
    toBlock,
    address
) => {
    const filter = contract.filters[eventName](address);
    const events = await contract.queryFilter(filter, fromBlock, toBlock);
    return events.map((event) => event.decode(event.data, event.topics));
}
