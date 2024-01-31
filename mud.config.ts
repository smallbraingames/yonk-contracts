import { resolveTableId } from "@latticexyz/config";
import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
    systems: {
        ClaimSystem: {
            openAccess: true
        },
        GetIdSystem: {
            openAccess: false,
            accessList: ["RegisterSystem", "YonkSystem"]
        },
        HelperSystem: {
            openAccess: true,
        },
        RegisterSystem: {
        openAccess: true,
        },
        YonkSystem: {
            openAccess: true,
        },
    },
    tables: {
        Id: {
            keySchema: {},
            valueSchema: {
                value: "uint64",
            },
        },
        Registration: {
            keySchema: { id: "uint64" },
            valueSchema: {
                devicePublicKeyX: "uint256",
                devicePublicKeyY: "uint256",
            },
        },
        RegisteredAddress: {
            keySchema: { id: "uint64" },
            valueSchema: {
                value: "address",
            },
        },
        Yonk: {
            keySchema: { id: "uint64" },
            valueSchema: {
                dataCommitment: "bytes32",
                startValue: "uint256",
                endValue: "uint256",
                lifeSeconds: "uint256",
                startTimestamp: "uint256",
                from: "uint64",
                to: "uint64",
                claimed: "bool"
            },
        },
        ClaimEvent: {
            keySchema: {id : "uint64"},
            valueSchema: {
                claimedValue: "uint256",
                returnedValue: "uint256",
                timestamp: "uint256",
            },
            offchainOnly: true,
        }
    },
    modules: [
        {
            name: "KeysWithValueModule",
            root: true,
            args: [resolveTableId("RegisteredAddress")],
        },
    ],
});