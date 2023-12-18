import { resolveTableId } from "@latticexyz/config";
import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
    systems: {
        ClaimSystem: {
            openAccess: true
        },
        GetIdSystem: {
            openAccess: false,
            accessList: ["RegisterSystem", "YellSystem"]
        },
        RegisterSystem: {
            openAccess: true,
        },
        YellSystem: {
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
        Yell: {
            keySchema: { id: "uint64" },
            valueSchema: {
                dataCommitment: "uint256",
                startValue: "uint256",
                endValue: "uint256",
                lifeSeconds: "uint256",
                startTimestamp: "uint256",
                from: "uint64",
                to: "uint64",
                claimed: "bool"
            },
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