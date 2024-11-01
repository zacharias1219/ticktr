// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketingSystem {
    address public owner;
    uint256 public eventCount = 0;
    uint256 public maxTransfers = 3; // Adjustable max transfer count

    struct Event {
        uint256 id;
        address organizer;
        string name;
        uint256 date;
        uint256 ticketPrice;
        uint256 ticketCount;
        uint256 ticketsSold;
        bool isActive;
    }

    struct Ticket {
        uint256 eventId;
        address owner;
        uint256 transferCount;
    }

    mapping(uint256 => Event) public events;
    mapping(uint256 => mapping(uint256 => Ticket)) public tickets; // eventId => ticketId => Ticket
    mapping(address => mapping(uint256 => uint256)) public ticketsOwned; // user => eventId => ticketCount

    event EventCreated(uint256 eventId, address organizer, string name, uint256 date, uint256 ticketPrice, uint256 ticketCount);
    event TicketPurchased(uint256 eventId, uint256 ticketId, address buyer);
    event TicketTransferred(uint256 eventId, uint256 ticketId, address from, address to);
    event TicketRefunded(uint256 eventId, uint256 ticketId, address buyer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyOrganizer(uint256 eventId) {
        require(events[eventId].organizer == msg.sender, "Only organizer can manage this event");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setMaxTransfers(uint256 _maxTransfers) public onlyOwner {
        maxTransfers = _maxTransfers;
    }

    function createEvent(
        string memory _name,
        uint256 _date,
        uint256 _ticketPrice,
        uint256 _ticketCount
    ) public {
        require(_date > block.timestamp, "Event date must be in the future");
        require(_ticketPrice > 0, "Ticket price must be greater than zero");
        require(_ticketCount > 0, "Ticket count must be greater than zero");

        eventCount++;
        events[eventCount] = Event(
            eventCount,
            msg.sender,
            _name,
            _date,
            _ticketPrice,
            _ticketCount,
            0,
            true
        );

        emit EventCreated(eventCount, msg.sender, _name, _date, _ticketPrice, _ticketCount);
    }

    function purchaseTicket(uint256 _eventId) public payable {
        require(_eventId <= eventCount && _eventId > 0, "Event does not exist");
        Event storage myEvent = events[_eventId];
        require(myEvent.isActive, "Event is not active");
        require(block.timestamp < myEvent.date, "Event has already occurred");
        require(myEvent.ticketsSold < myEvent.ticketCount, "All tickets sold");
        require(msg.value == myEvent.ticketPrice, "Incorrect payment amount");

        myEvent.ticketsSold++;
        tickets[_eventId][myEvent.ticketsSold] = Ticket(_eventId, msg.sender, 0);
        ticketsOwned[msg.sender][_eventId]++;

        emit TicketPurchased(_eventId, myEvent.ticketsSold, msg.sender);
    }

    function transferTicket(
        uint256 _eventId,
        uint256 _ticketId,
        address _to
    ) public {
        require(_eventId <= eventCount && _eventId > 0, "Event does not exist");
        Ticket storage ticket = tickets[_eventId][_ticketId];
        require(ticket.owner == msg.sender, "You are not the owner of this ticket");
        require(_to != address(0), "Cannot transfer to the zero address");
        require(ticket.transferCount < maxTransfers, "Transfer limit reached");

        ticket.owner = _to;
        ticket.transferCount++;
        ticketsOwned[msg.sender][_eventId]--;
        ticketsOwned[_to][_eventId]++;

        emit TicketTransferred(_eventId, _ticketId, msg.sender, _to);
    }

    function validateTicket(uint256 _eventId, uint256 _ticketId) public view returns (bool) {
        Ticket memory ticket = tickets[_eventId][_ticketId];
        return ticket.owner != address(0);
    }

    function cancelEvent(uint256 _eventId) public onlyOrganizer(_eventId) {
        Event storage myEvent = events[_eventId];
        require(myEvent.isActive, "Event is already canceled");
        require(myEvent.date > block.timestamp + 1 days, "Cannot cancel event within 24 hours of start time");

        myEvent.isActive = false;

        for (uint256 i = 1; i <= myEvent.ticketsSold; i++) {
            Ticket storage ticket = tickets[_eventId][i];
            if (ticket.owner != address(0)) {
                address ticketOwner = ticket.owner;
                ticket.owner = address(0); // Mark ticket as refunded
                payable(ticketOwner).transfer(myEvent.ticketPrice);
                emit TicketRefunded(_eventId, i, ticketOwner);
            }
        }
    }

    function refundTicket(uint256 _eventId, uint256 _ticketId) public {
        Event storage myEvent = events[_eventId];
        Ticket storage ticket = tickets[_eventId][_ticketId];
        require(!myEvent.isActive, "Event is still active");
        require(ticket.owner == msg.sender, "Only ticket owner can request refund");

        ticket.owner = address(0); // Mark ticket as refunded
        ticketsOwned[msg.sender][_eventId]--; // Update ticket count for user
        payable(msg.sender).transfer(myEvent.ticketPrice);

        emit TicketRefunded(_eventId, _ticketId, msg.sender);
    }

    function getActiveEvents(uint256 _start, uint256 _limit) public view returns (Event[] memory) {
        uint256 activeCount = 0;
        uint256 index = 0;

        // Count active events from the specified start index
        for (uint256 i = _start; i <= eventCount && activeCount < _limit; i++) {
            if (events[i].isActive) {
                activeCount++;
            }
        }

        Event[] memory activeEvents = new Event[](activeCount);
        for (uint256 i = _start; i <= eventCount && index < activeCount; i++) {
            if (events[i].isActive) {
                activeEvents[index] = events[i];
                index++;
            }
        }

        return activeEvents;
    }

    function getTicketsOwnedByUser(uint256 _eventId, address _user) public view returns (uint256) {
        return ticketsOwned[_user][_eventId];
    }

    function withdrawEventRevenue(uint256 _eventId) public onlyOrganizer(_eventId) {
        Event storage myEvent = events[_eventId];
        require(!myEvent.isActive, "Event is still active");

        uint256 revenue = myEvent.ticketPrice * myEvent.ticketsSold;
        myEvent.ticketsSold = 0; // Reset ticket count to prevent double withdrawal
        payable(myEvent.organizer).transfer(revenue);
    }
}
