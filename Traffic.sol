// pragma solidity 0.8.19;

// contract TrafficLight {
//     struct Pole {
//         uint id;
//         string signal;
//         uint lastUpdated;
//     }

//     mapping(uint => Pole) public poles;
//     uint public poleCount = 0; // Tracks the total number of poles ever created
//     uint public activePoleCount = 0; // Tracks the number of active poles
//     uint[] public availableIds; // Stores the IDs of deleted poles for reuse

//     event PoleAdded(uint id, string signal, uint lastUpdated);
//     event SignalChanged(uint id, string newSignal, uint lastUpdated);
//     event PoleDeleted(uint id, uint lastUpdated);

//     function addPole() public {
//         uint newId;

//         // If there are any available IDs from deleted poles, reuse them
//         if (availableIds.length > 0) {
//             newId = availableIds[availableIds.length - 1]; // Get the last available ID
//             availableIds.pop(); // Remove the reused ID from the list
//         } else {
//             poleCount++; // Increment poleCount if no IDs are available for reuse
//             newId = poleCount;
//         }

//         poles[newId] = Pole(newId, "Red", block.timestamp);
//         activePoleCount++; // Increase active pole count
//         emit PoleAdded(newId, "Red", block.timestamp);
//     }

//     function changeSignal(uint _id, string memory _signal) public {
//         Pole storage pole = poles[_id];
//         require(pole.id != 0, "Pole ID does not exist"); // Check if the pole exists
//         pole.signal = _signal;
//         pole.lastUpdated = block.timestamp;
//         emit SignalChanged(_id, _signal, block.timestamp);
//     }

//     function deletePole(uint _id) public {
//         Pole storage pole = poles[_id];
//         require(pole.id != 0, "Pole ID does not exist"); // Ensure the pole exists

//         // Mark the pole as deleted by removing it from active management
//         delete poles[_id];
//         availableIds.push(_id); // Add the deleted ID to the list of available IDs
//         activePoleCount--; // Decrease active pole count

//         emit PoleDeleted(_id, block.timestamp);
//     }
// }


pragma solidity ^0.8.18;

contract TrafficLight {
    struct Pole {
        uint256 id;
        uint256 lastUpdated;
        string signal;
    }

    uint256 private _nextPoleId = 1;
    mapping(uint256 => Pole) public poles;
    uint256[] public availableIds;

    // Events for tracking changes
    event PoleAdded(uint256 indexed id, string signal);
    event SignalChanged(uint256 indexed id, string newSignal);
    event PoleDeleted(uint256 indexed id);

    // Modifier for checking if a pole exists
    modifier poleExists(uint256 _id) {
        require(poles[_id].id != 0, "Pole ID does not exist");
        _;
    }

    // Add a new pole
    function addPole() external {
        uint256 id = _getAvailableId();
        poles[id] = Pole({
            id: id,
            lastUpdated: block.timestamp,
            signal: "Red"
        });

        emit PoleAdded(id, "Red");
    }

    // Change the signal of a pole
    function changeSignal(uint256 _id, string calldata _newSignal) external poleExists(_id) {
        Pole storage pole = poles[_id]; // Cache state variable in memory
        pole.signal = _newSignal;
        pole.lastUpdated = block.timestamp;

        emit SignalChanged(_id, _newSignal);
    }

    // Delete a pole
    function deletePole(uint256 _id) external poleExists(_id) {
        delete poles[_id];
        availableIds.push(_id); // Make the ID available for reuse
        emit PoleDeleted(_id);
    }

    // Helper to get available pole ID or the next in sequence
    function _getAvailableId() private returns (uint256) {
        if (availableIds.length > 0) {
            uint256 id = availableIds[availableIds.length - 1];
            availableIds.pop();
            return id;
        }
        return _nextPoleId++;
    }

    // Get available pole IDs count
    function getAvailableIdsCount() external view returns (uint256) {
        return availableIds.length;
    }
}
