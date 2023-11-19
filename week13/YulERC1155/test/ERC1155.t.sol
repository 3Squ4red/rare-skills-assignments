// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "./lib/YulDeployer.sol";

abstract contract ERC1155TokenReceiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}

contract ERC1155Recipient is ERC1155TokenReceiver {
    address public operator;
    address public from;
    uint256 public id;
    uint256 public amount;
    bytes public mintData;

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    ) public override returns (bytes4) {
        operator = _operator;
        from = _from;
        id = _id;
        amount = _amount;
        mintData = _data;

        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    address public batchOperator;
    address public batchFrom;
    uint256[] internal _batchIds;
    uint256[] internal _batchAmounts;
    bytes public batchData;

    function batchIds() external view returns (uint256[] memory) {
        return _batchIds;
    }

    function batchAmounts() external view returns (uint256[] memory) {
        return _batchAmounts;
    }

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes calldata _data
    ) external override returns (bytes4) {
        batchOperator = _operator;
        batchFrom = _from;
        _batchIds = _ids;
        _batchAmounts = _amounts;
        batchData = _data;

        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}

contract RevertingERC1155Recipient is ERC1155TokenReceiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) public pure override returns (bytes4) {
        revert(
            string(
                abi.encodePacked(
                    ERC1155TokenReceiver.onERC1155Received.selector
                )
            )
        );
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        revert(
            string(
                abi.encodePacked(
                    ERC1155TokenReceiver.onERC1155BatchReceived.selector
                )
            )
        );
    }
}

contract WrongReturnDataERC1155Recipient is ERC1155TokenReceiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) public pure override returns (bytes4) {
        return 0xCAFEBEEF;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return 0xCAFEBEEF;
    }
}

contract NonERC1155Recipient {}

interface IERC1155 {
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external;

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external;

    function balanceOf(
        address _owner,
        uint256 _id
    ) external view returns (uint256);

    function balanceOfBatch(
        address[] calldata _owners,
        uint256[] calldata _ids
    ) external view returns (uint256[] memory);

    function setApprovalForAll(address _operator, bool _approved) external;

    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view returns (bool);

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function setURI(uint256 id, string memory uri) external;

    function getURI(uint256 id) external view returns (string memory);

    function EmitURI(string memory uri, uint256 id) external;
}

contract ERC1155Test is Test, ERC1155TokenReceiver {
    YulDeployer yulDeployer = new YulDeployer();

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );
    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );
    event URI(string _value, uint256 indexed _id);

    mapping(address => mapping(uint256 => uint256)) public userMintAmounts;
    mapping(address => mapping(uint256 => uint256))
        public userTransferOrBurnAmounts;

    IERC1155 token;

    function setUp() public {
        token = IERC1155(yulDeployer.deployContract("ERC1155"));
    }

    function testApproveAll(address to, bool approved) public {
        vm.expectEmit(true, true, false, true, address(token));
        emit ApprovalForAll(address(this), to, approved);

        token.setApprovalForAll(to, approved);

        assertEq(token.isApprovedForAll(address(this), to), approved);
    }

    function testBatchBalanceOf(
        address[] memory tos,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory mintData
    ) public {
        uint256 minLength = min3(tos.length, ids.length, amounts.length);

        address[] memory normalizedTos = new address[](minLength);
        uint256[] memory normalizedIds = new uint256[](minLength);

        for (uint256 i = 0; i < minLength; i++) {
            uint256 id = ids[i];
            address to = tos[i] == address(0) || tos[i].code.length > 0
                ? address(0xBEEF)
                : tos[i];

            uint256 remainingMintAmountForId = type(uint256).max -
                userMintAmounts[to][id];

            normalizedTos[i] = to;
            normalizedIds[i] = id;

            uint256 mintAmount = bound(amounts[i], 0, remainingMintAmountForId);

            token.mint(to, id, mintAmount, mintData);

            userMintAmounts[to][id] += mintAmount;
        }

        uint256[] memory balances = token.balanceOfBatch(
            normalizedTos,
            normalizedIds
        );

        for (uint256 i = 0; i < normalizedTos.length; i++) {
            assertEq(
                balances[i],
                token.balanceOf(normalizedTos[i], normalizedIds[i])
            );
        }
    }

    /* -------- safeTransferFrom ---------- */

    function testSafeTransferFromToEOA(
        uint256 id,
        uint256 mintAmount,
        bytes memory mintData,
        uint256 transferAmount,
        address to,
        bytes memory transferData
    ) public {
        if (to == address(0)) to = address(0xBEEF);

        if (uint256(uint160(to)) <= 18 || to.code.length > 0) return;

        transferAmount = bound(transferAmount, 0, mintAmount);

        address from = address(0xABCD);

        token.mint(from, id, mintAmount, mintData);

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        vm.expectEmit(true, true, true, true, address(token));
        emit TransferSingle(address(this), from, to, id, transferAmount);

        token.safeTransferFrom(from, to, id, transferAmount, transferData);

        assertEq(token.balanceOf(to, id), transferAmount);
        assertEq(token.balanceOf(from, id), mintAmount - transferAmount);
    }

    function testSafeTransferFromToERC1155Recipient(
        uint256 id,
        uint256 mintAmount,
        bytes memory mintData,
        uint256 transferAmount,
        bytes memory transferData
    ) public {
        ERC1155Recipient to = new ERC1155Recipient();

        address from = address(0xABCD);

        transferAmount = bound(transferAmount, 0, mintAmount);

        token.mint(from, id, mintAmount, mintData);

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeTransferFrom(
            from,
            address(to),
            id,
            transferAmount,
            transferData
        );

        assertEq(to.operator(), address(this));
        assertEq(to.from(), from);
        assertEq(to.id(), id);
        assertEq(to.mintData(), transferData);

        assertEq(token.balanceOf(address(to), id), transferAmount);
        assertEq(token.balanceOf(from, id), mintAmount - transferAmount);
    }

    function testSafeTransferFromSelf(
        uint256 id,
        uint256 mintAmount,
        bytes memory mintData,
        uint256 transferAmount,
        address to,
        bytes memory transferData
    ) public {
        if (to == address(0)) to = address(0xBEEF);

        if (uint256(uint160(to)) <= 18 || to.code.length > 0) return;

        transferAmount = bound(transferAmount, 0, mintAmount);

        token.mint(address(this), id, mintAmount, mintData);

        token.safeTransferFrom(
            address(this),
            to,
            id,
            transferAmount,
            transferData
        );

        assertEq(token.balanceOf(to, id), transferAmount);
        assertEq(
            token.balanceOf(address(this), id),
            mintAmount - transferAmount
        );
    }

    /* -------- safeTransferFrom fails ---------- */

    function testFailSafeTransferFromInsufficientBalance(
        address to,
        uint256 id,
        uint256 mintAmount,
        uint256 transferAmount,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        address from = address(0xABCD);

        transferAmount = bound(
            transferAmount,
            mintAmount + 1,
            type(uint256).max
        );

        token.mint(from, id, mintAmount, mintData);

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeTransferFrom(from, to, id, transferAmount, transferData);
    }

    function testFailSafeTransferFromSelfInsufficientBalance(
        address to,
        uint256 id,
        uint256 mintAmount,
        uint256 transferAmount,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        transferAmount = bound(
            transferAmount,
            mintAmount + 1,
            type(uint256).max
        );

        token.mint(address(this), id, mintAmount, mintData);
        token.safeTransferFrom(
            address(this),
            to,
            id,
            transferAmount,
            transferData
        );
    }

    function testFailSafeTransferFromToZero(
        uint256 id,
        uint256 mintAmount,
        uint256 transferAmount,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        transferAmount = bound(transferAmount, 0, mintAmount);

        token.mint(address(this), id, mintAmount, mintData);
        token.safeTransferFrom(
            address(this),
            address(0),
            id,
            transferAmount,
            transferData
        );
    }

    function testFailSafeTransferFromToNonERC155Recipient(
        uint256 id,
        uint256 mintAmount,
        uint256 transferAmount,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        transferAmount = bound(transferAmount, 0, mintAmount);

        token.mint(address(this), id, mintAmount, mintData);
        token.safeTransferFrom(
            address(this),
            address(new NonERC1155Recipient()),
            id,
            transferAmount,
            transferData
        );
    }

    function testFailSafeTransferFromToRevertingERC1155Recipient(
        uint256 id,
        uint256 mintAmount,
        uint256 transferAmount,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        transferAmount = bound(transferAmount, 0, mintAmount);

        token.mint(address(this), id, mintAmount, mintData);
        token.safeTransferFrom(
            address(this),
            address(new RevertingERC1155Recipient()),
            id,
            transferAmount,
            transferData
        );
    }

    function testFailSafeTransferFromToWrongReturnDataERC1155Recipient(
        uint256 id,
        uint256 mintAmount,
        uint256 transferAmount,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        transferAmount = bound(transferAmount, 0, mintAmount);

        token.mint(address(this), id, mintAmount, mintData);
        token.safeTransferFrom(
            address(this),
            address(new WrongReturnDataERC1155Recipient()),
            id,
            transferAmount,
            transferData
        );
    }

    /* -------- safeBatchTransferFrom ---------- */

    function testSafeBatchTransferFromToEOA(
        address to,
        uint256[] memory ids,
        uint256[] memory mintAmounts,
        uint256[] memory transferAmounts,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        if (to == address(0)) to = address(0xBEEF);

        if (uint256(uint160(to)) <= 18 || to.code.length > 0) return;

        address from = address(0xABCD);

        uint256 minLength = min3(
            ids.length,
            mintAmounts.length,
            transferAmounts.length
        );

        uint256[] memory normalizedIds = new uint256[](minLength);
        uint256[] memory normalizedMintAmounts = new uint256[](minLength);
        uint256[] memory normalizedTransferAmounts = new uint256[](minLength);

        for (uint256 i = 0; i < minLength; i++) {
            uint256 id = ids[i];

            uint256 remainingMintAmountForId = type(uint256).max -
                userMintAmounts[from][id];

            uint256 mintAmount = bound(
                mintAmounts[i],
                0,
                remainingMintAmountForId
            );
            uint256 transferAmount = bound(transferAmounts[i], 0, mintAmount);

            normalizedIds[i] = id;
            normalizedMintAmounts[i] = mintAmount;
            normalizedTransferAmounts[i] = transferAmount;

            userMintAmounts[from][id] += mintAmount;
            userTransferOrBurnAmounts[from][id] += transferAmount;

            token.mint(from, id, mintAmount, mintData);
        }

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        vm.expectEmit(true, true, true, true, address(token));
        emit TransferBatch(
            address(this),
            from,
            to,
            normalizedIds,
            normalizedTransferAmounts
        );

        token.safeBatchTransferFrom(
            from,
            to,
            normalizedIds,
            normalizedTransferAmounts,
            transferData
        );

        for (uint256 i = 0; i < normalizedIds.length; i++) {
            uint256 id = normalizedIds[i];

            assertEq(
                token.balanceOf(address(to), id),
                userTransferOrBurnAmounts[from][id]
            );
            assertEq(
                token.balanceOf(from, id),
                userMintAmounts[from][id] - userTransferOrBurnAmounts[from][id]
            );
        }
    }

    function testSafeBatchTransferFromToERC1155Recipient(
        uint256[] memory ids,
        uint256[] memory mintAmounts,
        uint256[] memory transferAmounts,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        address from = address(0xABCD);

        ERC1155Recipient to = new ERC1155Recipient();

        uint256 minLength = min3(
            ids.length,
            mintAmounts.length,
            transferAmounts.length
        );

        uint256[] memory normalizedIds = new uint256[](minLength);
        uint256[] memory normalizedMintAmounts = new uint256[](minLength);
        uint256[] memory normalizedTransferAmounts = new uint256[](minLength);

        for (uint256 i = 0; i < minLength; i++) {
            uint256 id = ids[i];

            uint256 remainingMintAmountForId = type(uint256).max -
                userMintAmounts[from][id];

            uint256 mintAmount = bound(
                mintAmounts[i],
                0,
                remainingMintAmountForId
            );
            uint256 transferAmount = bound(transferAmounts[i], 0, mintAmount);

            normalizedIds[i] = id;
            normalizedMintAmounts[i] = mintAmount;
            normalizedTransferAmounts[i] = transferAmount;

            userMintAmounts[from][id] += mintAmount;
            userTransferOrBurnAmounts[from][id] += transferAmount;

            token.mint(from, id, mintAmount, mintData);
        }

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeBatchTransferFrom(
            from,
            address(to),
            normalizedIds,
            normalizedTransferAmounts,
            transferData
        );

        assertEq(to.batchOperator(), address(this));
        assertEq(to.batchFrom(), from);
        assertEq(to.batchIds(), normalizedIds);
        assertEq(to.batchAmounts(), normalizedTransferAmounts);
        assertEq(to.batchData(), transferData);

        for (uint256 i = 0; i < normalizedIds.length; i++) {
            uint256 id = normalizedIds[i];
            uint256 transferAmount = userTransferOrBurnAmounts[from][id];

            assertEq(token.balanceOf(address(to), id), transferAmount);
            assertEq(
                token.balanceOf(from, id),
                userMintAmounts[from][id] - transferAmount
            );
        }
    }

    /* -------- safeBatchTransferFrom fails ---------- */

    function testFailSafeBatchTransferInsufficientBalance(
        address to,
        uint256[] memory ids,
        uint256[] memory mintAmounts,
        uint256[] memory transferAmounts,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        address from = address(0xABCD);

        uint256 minLength = min3(
            ids.length,
            mintAmounts.length,
            transferAmounts.length
        );

        if (minLength == 0) revert();

        uint256[] memory normalizedIds = new uint256[](minLength);
        uint256[] memory normalizedMintAmounts = new uint256[](minLength);
        uint256[] memory normalizedTransferAmounts = new uint256[](minLength);

        for (uint256 i = 0; i < minLength; i++) {
            uint256 id = ids[i];

            uint256 remainingMintAmountForId = type(uint256).max -
                userMintAmounts[from][id];

            uint256 mintAmount = bound(
                mintAmounts[i],
                0,
                remainingMintAmountForId
            );
            uint256 transferAmount = bound(
                transferAmounts[i],
                mintAmount + 1,
                type(uint256).max
            );

            normalizedIds[i] = id;
            normalizedMintAmounts[i] = mintAmount;
            normalizedTransferAmounts[i] = transferAmount;

            userMintAmounts[from][id] += mintAmount;

            token.mint(from, id, mintAmount, mintData);
        }

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeBatchTransferFrom(
            from,
            to,
            normalizedIds,
            normalizedTransferAmounts,
            transferData
        );
    }

    function testFailSafeBatchTransferFromToZero(
        uint256[] memory ids,
        uint256[] memory mintAmounts,
        uint256[] memory transferAmounts,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        address from = address(0xABCD);

        uint256 minLength = min3(
            ids.length,
            mintAmounts.length,
            transferAmounts.length
        );

        uint256[] memory normalizedIds = new uint256[](minLength);
        uint256[] memory normalizedMintAmounts = new uint256[](minLength);
        uint256[] memory normalizedTransferAmounts = new uint256[](minLength);

        for (uint256 i = 0; i < minLength; i++) {
            uint256 id = ids[i];

            uint256 remainingMintAmountForId = type(uint256).max -
                userMintAmounts[from][id];

            uint256 mintAmount = bound(
                mintAmounts[i],
                0,
                remainingMintAmountForId
            );
            uint256 transferAmount = bound(transferAmounts[i], 0, mintAmount);

            normalizedIds[i] = id;
            normalizedMintAmounts[i] = mintAmount;
            normalizedTransferAmounts[i] = transferAmount;

            userMintAmounts[from][id] += mintAmount;

            token.mint(from, id, mintAmount, mintData);
        }

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeBatchTransferFrom(
            from,
            address(0),
            normalizedIds,
            normalizedTransferAmounts,
            transferData
        );
    }

    function testFailSafeBatchTransferFromToNonERC1155Recipient(
        uint256[] memory ids,
        uint256[] memory mintAmounts,
        uint256[] memory transferAmounts,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        address from = address(0xABCD);

        uint256 minLength = min3(
            ids.length,
            mintAmounts.length,
            transferAmounts.length
        );

        uint256[] memory normalizedIds = new uint256[](minLength);
        uint256[] memory normalizedMintAmounts = new uint256[](minLength);
        uint256[] memory normalizedTransferAmounts = new uint256[](minLength);

        for (uint256 i = 0; i < minLength; i++) {
            uint256 id = ids[i];

            uint256 remainingMintAmountForId = type(uint256).max -
                userMintAmounts[from][id];

            uint256 mintAmount = bound(
                mintAmounts[i],
                0,
                remainingMintAmountForId
            );
            uint256 transferAmount = bound(transferAmounts[i], 0, mintAmount);

            normalizedIds[i] = id;
            normalizedMintAmounts[i] = mintAmount;
            normalizedTransferAmounts[i] = transferAmount;

            userMintAmounts[from][id] += mintAmount;

            token.mint(from, id, mintAmount, mintData);
        }

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeBatchTransferFrom(
            from,
            address(new NonERC1155Recipient()),
            normalizedIds,
            normalizedTransferAmounts,
            transferData
        );
    }

    function testFailSafeBatchTransferFromToRevertingERC1155Recipient(
        uint256[] memory ids,
        uint256[] memory mintAmounts,
        uint256[] memory transferAmounts,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        address from = address(0xABCD);

        uint256 minLength = min3(
            ids.length,
            mintAmounts.length,
            transferAmounts.length
        );

        uint256[] memory normalizedIds = new uint256[](minLength);
        uint256[] memory normalizedMintAmounts = new uint256[](minLength);
        uint256[] memory normalizedTransferAmounts = new uint256[](minLength);

        for (uint256 i = 0; i < minLength; i++) {
            uint256 id = ids[i];

            uint256 remainingMintAmountForId = type(uint256).max -
                userMintAmounts[from][id];

            uint256 mintAmount = bound(
                mintAmounts[i],
                0,
                remainingMintAmountForId
            );
            uint256 transferAmount = bound(transferAmounts[i], 0, mintAmount);

            normalizedIds[i] = id;
            normalizedMintAmounts[i] = mintAmount;
            normalizedTransferAmounts[i] = transferAmount;

            userMintAmounts[from][id] += mintAmount;

            token.mint(from, id, mintAmount, mintData);
        }

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeBatchTransferFrom(
            from,
            address(new RevertingERC1155Recipient()),
            normalizedIds,
            normalizedTransferAmounts,
            transferData
        );
    }

    function testFailSafeBatchTransferFromToWrongReturnDataERC1155Recipient(
        uint256[] memory ids,
        uint256[] memory mintAmounts,
        uint256[] memory transferAmounts,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        address from = address(0xABCD);

        uint256 minLength = min3(
            ids.length,
            mintAmounts.length,
            transferAmounts.length
        );

        uint256[] memory normalizedIds = new uint256[](minLength);
        uint256[] memory normalizedMintAmounts = new uint256[](minLength);
        uint256[] memory normalizedTransferAmounts = new uint256[](minLength);

        for (uint256 i = 0; i < minLength; i++) {
            uint256 id = ids[i];

            uint256 remainingMintAmountForId = type(uint256).max -
                userMintAmounts[from][id];

            uint256 mintAmount = bound(
                mintAmounts[i],
                0,
                remainingMintAmountForId
            );
            uint256 transferAmount = bound(transferAmounts[i], 0, mintAmount);

            normalizedIds[i] = id;
            normalizedMintAmounts[i] = mintAmount;
            normalizedTransferAmounts[i] = transferAmount;

            userMintAmounts[from][id] += mintAmount;

            token.mint(from, id, mintAmount, mintData);
        }

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeBatchTransferFrom(
            from,
            address(new WrongReturnDataERC1155Recipient()),
            normalizedIds,
            normalizedTransferAmounts,
            transferData
        );
    }

    function testFailSafeBatchTransferFromWithArrayLengthMismatch(
        address to,
        uint256[] memory ids,
        uint256[] memory mintAmounts,
        uint256[] memory transferAmounts,
        bytes memory mintData,
        bytes memory transferData
    ) public {
        address from = address(0xABCD);

        if (ids.length == transferAmounts.length) revert();

        uint idsLen = ids.length;
        uint mintAmountLen = mintAmounts.length;
        uint len = idsLen < mintAmountLen ? idsLen : mintAmountLen;
        for (uint256 i = 0; i < len; i++) {
            token.mint(from, ids[i], mintAmounts[i], mintData);
        }

        vm.prank(from);
        token.setApprovalForAll(address(this), true);

        token.safeBatchTransferFrom(
            from,
            to,
            ids,
            transferAmounts,
            transferData
        );
    }

    /* -------- mint ---------- */

    function testMintToEOA(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory mintData
    ) public {
        if (to == address(0)) to = address(0xBEEF);

        if (uint256(uint160(to)) <= 18 || to.code.length > 0) return;

        vm.expectEmit(true, true, true, true, address(token));
        emit TransferSingle(address(this), address(0), to, id, amount);

        token.mint(to, id, amount, mintData);

        assertEq(token.balanceOf(to, id), amount);
    }

    function testMintToERC1155Recipient(
        uint256 id,
        uint256 amount,
        bytes memory mintData
    ) public {
        ERC1155Recipient to = new ERC1155Recipient();

        token.mint(address(to), id, amount, mintData);

        assertEq(token.balanceOf(address(to), id), amount);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), address(0));
        assertEq(to.id(), id);
        assertEq(to.mintData(), mintData);
    }

    /* -------- mint fails ---------- */

    function testFailMintToZero(
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        token.mint(address(0), id, amount, data);
    }

    function testFailMintToNonERC155Recipient(
        uint256 id,
        uint256 mintAmount,
        bytes memory mintData
    ) public {
        token.mint(
            address(new NonERC1155Recipient()),
            id,
            mintAmount,
            mintData
        );
    }

    function testFailMintToRevertingERC155Recipient(
        uint256 id,
        uint256 mintAmount,
        bytes memory mintData
    ) public {
        token.mint(
            address(new RevertingERC1155Recipient()),
            id,
            mintAmount,
            mintData
        );
    }

    function testFailMintToWrongReturnDataERC155Recipient(
        uint256 id,
        uint256 mintAmount,
        bytes memory mintData
    ) public {
        token.mint(
            address(new RevertingERC1155Recipient()),
            id,
            mintAmount,
            mintData
        );
    }

    /* -------- setURI/getURI ---------- */

    function testSetGetURI() public {
        string memory uri = "https://example.com";
        uint id = 343;

        vm.expectEmit(true, false, false, true, address(token));
        emit URI(uri, id);

        token.setURI(id, uri);

        assertEq(token.getURI(id), uri);
    }

    /* -------- helper functions ---------- */

    function min3(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256) {
        return a > b ? (b > c ? c : b) : (a > c ? c : a);
    }
}
