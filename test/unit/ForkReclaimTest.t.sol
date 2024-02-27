// import { YonkTest } from "../YonkTest.t.sol";

// import { Yonk } from "codegen/index.sol";
// import { IWorld } from "codegen/world/IWorld.sol";
// import { console } from "forge-std/console.sol";

// contract ForkTest is YonkTest {
//     function test_Reclaim55And60() public {
//         string memory BASE_SEPOLIA_RPC_URL = vm.envString("BASE_SEPOLIA_RPC_URL");
//         uint256 baseSepoliaFork = vm.createFork(BASE_SEPOLIA_RPC_URL);
//         vm.selectFork(baseSepoliaFork);
//         vm.rollFork(6_626_268);

//         IWorld world = IWorld(address(0x0C9eb54fFC8a711f842948404E48EfAEF05FD34f));

//         vm.prank(address(0x40eA15Daf3370dB0b1dB40d695711987A7cAe2Bd));
//         console.log(Yonk.get(55).reclaimed);
//         console.log(Yonk.get(60).reclaimed);
//         console.log(Yonk.get(95).reclaimed);

//         // uint64[]  memory yonkIds = new uint64[](2);
//         // yonkIds[0] = 55;
//         // yonkIds[1] = 60;
//         world.reclaim(95);
//     }
// }
