object "ERC1155" {
    code {
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime" {
        code {
            let selector := shr(0xe0, calldataload(0))

            switch selector
            case 0xf242432a /* "safeTransferFrom(address,address,uint256,uint256,bytes)" */ {
                safeTransferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2), decodeAsUint(3), 0x00)
            }
            case 0x2eb2c2d6 /* "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)" */ {
                safeBatchTransferFrom(decodeAsAddress(0), decodeAsAddress(1), 0xa4, add(calldataload(0x64), 4), 0x00)
            }
            case 0x00fdd58e /* "balanceOf(address,uint256)" */ {
                returnUint(balanceOf(decodeAsAddress(0), decodeAsUint(1)))
            }
            case 0x4e1273f4 /* "balanceOfBatch(address[],uint256[])" */ {
                balanceOfBatch(0x44, add(calldataload(0x24), 4))
            }
            case 0xa22cb465 /* "setApprovalForAll(address,bool)" */ {
                setApprovalForAll(decodeAsAddress(0), decodeAsUint(1))
            }
            case 0xe985e9c5 /* "isApprovedForAll(address,address)" */ {
                returnUint(isApprovedForAll(decodeAsAddress(0), decodeAsAddress(1)))
            }
            case 0x731133e9 /* "mint(address,uint256,uint256,bytes)" */ {
                mint(decodeAsAddress(0), decodeAsUint(1), decodeAsUint(2), 0x00)
            }
            default {
                revert(0, 0)
            }

            /* -------- ERC1155 Logic ---------- */
            function safeTransferFrom(from, to, id, amount, _data) {
                if iszero(or(eq(caller(), from), isApprovedForAll(from, caller()))) {revert(0, 0)}

                // reducing from's balance
                let offset := balanceStorageOffset(from, id)
                let bal := sload(offset)
                if gt(amount, bal) {revert(0, 0)}
                sstore(offset, sub(bal, amount))
                
                // increasing to's balance
                offset := balanceStorageOffset(to, id)
                sstore(offset, safeAdd(sload(offset), amount))

                // emit TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
                mstore(0, id)
                mstore(0x20, amount)
                log4(0, 0x40, 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62, caller(), from, to)

                // verify recipient
                if iszero(extcodesize(to)) {
                    if iszero(to) {revert(0, 0)}
                    leave
                }
                mstore(0, 0xf23a6e61)
                mstore(0x20, caller())
                mstore(0x40, from)
                mstore(0x60, id)
                mstore(0x80, amount)
                mstore(0xa0, 0xa0)
                mstore(0xc0, 0)
                if iszero(call(gas(), to, 0, 28, 0xc4, 0xe0, 4)) {revert(0,0)}
                if iszero(eq(0xf23a6e61, shr(0xe0, mload(0xe0)))) {revert(0, 0)}
            }
            function safeBatchTransferFrom(from, to, idsPos, amountsPos, _data) {
                if iszero(or(eq(caller(), from), isApprovedForAll(from, caller()))) {revert(0, 0)}

                let idsLen := calldataload(idsPos)
                let amountsLen := calldataload(amountsPos)

                if iszero(eq(idsLen, amountsLen)) {revert(0,0)}

                let nextIdPos := add(idsPos, 0x20)
                let nextAmountPos := add(amountsPos, 0x20)

                // prepping for emitting the event
                let diff := mul(add(idsLen, 1), 32)
                mstore(0xa0, 0x40)
                mstore(0xc0, add(0x40, diff))
                mstore(0xe0, idsLen)
                mstore(add(0xe0, diff), amountsLen)
                let idsMemStart := 0x100
                let amountsMemStart := add(0x100, diff)

                for {let i := 0} lt(i, idsLen) {i := add(i, 1)} {
                    let id := calldataload(nextIdPos)
                    let amount := calldataload(nextAmountPos)

                    // reducing from's balance
                    let offset := balanceStorageOffset(from, id)
                    let bal := sload(offset)
                    if gt(amount, bal) {revert(0, 0)}
                    sstore(offset, sub(bal, amount))
                    
                    // increasing to's balance
                    offset := balanceStorageOffset(to, id)
                    sstore(offset, safeAdd(sload(offset), amount))

                    // for event
                    mstore(idsMemStart, id)
                    mstore(amountsMemStart, amount)
                    idsMemStart := add(idsMemStart, 32)
                    amountsMemStart := add(amountsMemStart, 32)

                    nextIdPos := add(nextIdPos, 0x20)
                    nextAmountPos := add(nextAmountPos, 0x20)
                }

                // emit TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
                log4(0xa0, mul(add(idsLen, 2), 64), 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb, caller(), from, to)
                // verify recipient
                if iszero(extcodesize(to)) {
                    if iszero(to) {revert(0, 0)}
                    leave
                }
                let amountsOffset := add(0xa0, diff)
                mstore(0x20, 0xbc197c81)
                mstore(0x40, caller())
                mstore(0x60, from)
                mstore(0x80, 0xa0)
                mstore(0xa0, amountsOffset)
                mstore(0xc0, add(amountsOffset, diff))
                if iszero(call(gas(), to, 0, 0x3c, add(196, mul(diff,2)), 0, 4)) {revert(0,0)}
                if iszero(eq(0xbc197c81, shr(0xe0, mload(0)))) {revert(0, 0)}
            }
            function balanceOf(owner, id) -> bal {
                bal := sload(balanceStorageOffset(owner, id))
            }
            function balanceOfBatch(ownersPos, idsPos) {
                let ownersLen := calldataload(ownersPos)
                let idsLen := calldataload(idsPos)
                
                if iszero(eq(ownersLen, idsLen)) {revert(0,0)}

                let nextOwnerPos := add(ownersPos, 0x20)
                let nextIdPos := add(idsPos, 0x20)

                mstore(0x40, 0x20)
                mstore(0x60, ownersLen)
                let nextMemPos := 0x80

                for {let i := 0} lt(i, ownersLen) {i := add(i, 1)} {
                    mstore(nextMemPos, balanceOf(calldataload(nextOwnerPos), calldataload(nextIdPos)))
                    nextOwnerPos := add(nextOwnerPos, 0x20)
                    nextIdPos := add(nextIdPos, 0x20)
                    nextMemPos := add(nextMemPos, 0x20)
                }

                return(0x40, add(mul(ownersLen, 0x20), 0x40))
            }
            function setApprovalForAll(operator, approved) {
                sstore(approvalStorageOffset(caller(), operator), approved)
                
                // emit ApprovalForAll(address indexed owner, address indexed operator, bool approved);
                mstore(0, approved)
                log3(0, 0x20, 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31, caller(), operator)
            }
            function isApprovedForAll(owner, operator) -> approved {
                approved := sload(approvalStorageOffset(owner, operator))
            }
            function mint(to, id, amount, _data) {
                let offset := balanceStorageOffset(to, id)
                sstore(offset, safeAdd(sload(offset), amount))

                // emit TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
                mstore(0, id)
                mstore(0x20, amount)
                log4(0, 0x40, 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62, caller(), 0x0000000000000000000000000000000000000000, to)

                // verify recipient
                if iszero(extcodesize(to)) {
                    if iszero(to) {revert(0, 0)}
                    leave
                }
                mstore(0, 0xf23a6e61)
                mstore(0x20, caller())
                mstore(0x40, 0x0000000000000000000000000000000000000000)
                mstore(0x60, id)
                mstore(0x80, amount)
                mstore(0xa0, 0xa0)
                mstore(0xc0, 0)
                if iszero(call(gas(), to, 0, 28, 0xc4, 0xe0, 4)) {revert(0,0)}
                if iszero(eq(0xf23a6e61, shr(0xe0, mload(0xe0)))) {revert(0, 0)}
            }

            /* -------- storage layout ---------- */
            function balanceStorageOffset(owner, id) -> offset {
                mstore(0, owner)
                mstore(0x20, id)
                offset := add(id, keccak256(0, 0x40))
            }
            function approvalStorageOffset(owner, operator) -> offset {
                mstore(0, owner)
                mstore(0x20, operator)
                offset := keccak256(0, 0x40)
            }
            /* ---------- calldata encoding functions ---------- */
            function returnUint(v) {
                mstore(0, v)
                return(0, 0x20)
            }
            /* ---------- calldata decoding functions ----------- */
            function decodeAsAddress(offset) -> v {
                v := decodeAsUint(offset)
                if iszero(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
                    revert(0, 0)
                }
            }
            function decodeAsUint(offset) -> v {
                let pos := add(4, mul(offset, 0x20))
                if lt(calldatasize(), add(pos, 0x20)) {
                    revert(0, 0)
                }
                v := calldataload(pos)
            }
            /* ---------- utility functions ---------- */
            function safeAdd(a, b) -> r {
                r := add(a, b)
                if or(lt(r, a), lt(r, b)) { revert(0, 0) }
            }
        }
    }
}