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
                safeTransferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2), decodeAsUint(3), 0xa4)
            }
            case 0x2eb2c2d6 /* "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)" */ {
                safeBatchTransferFrom(decodeAsAddress(0), decodeAsAddress(1), 0xa4, add(calldataload(0x64), 4), add(calldataload(0x84), 4))
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
                mint(decodeAsAddress(0), decodeAsUint(1), decodeAsUint(2), 0x84)
            }
            case 0x862440e2 /* "setURI(uint256,string)" */ {
                setURI(decodeAsUint(0), 0x44)
            }
            case 0x1aa347dc /* "getURI(uint256)" */ {
                getURI(decodeAsUint(0))
            }
            default {
                revert(0, 0)
            }

            /* -------- ERC1155 Logic ---------- */
            function safeTransferFrom(from, to, id, amount, dataLenOffset) {
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
                let dataLen := calldataload(dataLenOffset)
                mstore(0x20, 0xf23a6e61)
                mstore(0x40, caller())
                mstore(0x60, from)
                mstore(0x80, id)
                mstore(0xa0, amount)
                mstore(0xc0, 0xa0)
                mstore(0xe0, dataLen)
                calldatacopy(0x100, 0xc4, dataLen)
                if iszero(call(gas(), to, 0, 0x3c, add(196, dataLen), 0, 4)) {revert(0,0)}
                if iszero(eq(0xf23a6e61, shr(0xe0, mload(0)))) {revert(0, 0)}
            }
            function safeBatchTransferFrom(from, to, idsLenOffset, amountsLenOffset, dataLenOffset) {
                if iszero(or(eq(caller(), from), isApprovedForAll(from, caller()))) {revert(0, 0)}

                let idsLen := calldataload(idsLenOffset)
                let amountsLen := calldataload(amountsLenOffset)

                if iszero(eq(idsLen, amountsLen)) {revert(0,0)}

                let nextIdPos := add(idsLenOffset, 0x20)
                let nextAmountPos := add(amountsLenOffset, 0x20)

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

                    nextIdPos := add(nextIdPos, 0x20)
                    nextAmountPos := add(nextAmountPos, 0x20)
                }

                let diff := mul(add(idsLen, 1), 32)
                let arraySizeBytes := mul(idsLen, 0x20)
                let eventDataMemStart := add(calldatasize(), 0x40)
                // let eventIdsLenMemOffset := add(eventDataMemStart, 0x40)
                mstore(eventDataMemStart, 0x40)
                mstore(add(eventDataMemStart, 0x20), add(0x40, diff))
                mstore(add(eventDataMemStart, 0x40), idsLen)
                calldatacopy(add(eventDataMemStart, 0x60), add(idsLenOffset, 0x20), arraySizeBytes)
                mstore(add(add(eventDataMemStart, 0x40), diff), amountsLen)
                calldatacopy(add(add(eventDataMemStart, 0x60), diff), add(amountsLenOffset, 0x20), arraySizeBytes)
                // emit TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
                log4(eventDataMemStart, mul(add(idsLen, 2), 64), 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb, caller(), from, to)
                // verify recipient
                if iszero(extcodesize(to)) {
                    if iszero(to) {revert(0, 0)}
                    leave
                }
                let amountsOffset := add(0xa0, diff)
                let dataOffset := add(amountsOffset, diff)
                mstore(0x20, 0xbc197c81)
                mstore(0x40, caller())
                mstore(0x60, from)
                mstore(0x80, 0xa0) // ids offset
                mstore(0xa0, amountsOffset)
                mstore(0xc0, dataOffset)
                mstore(0xe0, idsLen)
                calldatacopy(0x100, 0xc4, arraySizeBytes) // copying ids to memory
                mstore(add(0xe0, diff), amountsLen) // storing amounts len
                // let amountsStartMemOffset := add(0x100, diff)
                calldatacopy(add(0x100, diff), add(amountsOffset, 0x24), arraySizeBytes) // copying amounts to memory
                mstore(add(add(0xe0, diff), diff),  calldataload(dataLenOffset)) // storing data len
                calldatacopy(add(add(0x100, diff), diff), add(dataOffset, 0x24),  calldataload(dataLenOffset)) // storing actual data
                if iszero(call(gas(), to, 0, 0x3c, calldatasize(), 0, 4)) {revert(0,0)}
                if iszero(eq(0xbc197c81, shr(0xe0, mload(0)))) {revert(0, 0)}
            }
            function balanceOf(owner, id) -> bal {
                bal := sload(balanceStorageOffset(owner, id))
            }
            function balanceOfBatch(ownersLenOffset, idsLenOffset) {
                let ownersLen := calldataload(ownersLenOffset)
                let idsLen := calldataload(idsLenOffset)
                
                if iszero(eq(ownersLen, idsLen)) {revert(0,0)}

                let nextOwnerPos := add(ownersLenOffset, 0x20)
                let nextIdPos := add(idsLenOffset, 0x20)

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
            function mint(to, id, amount, dataLenOffset) {
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
                let dataLen := calldataload(dataLenOffset)
                mstore(0x20, 0xf23a6e61)
                mstore(0x40, caller())
                mstore(0x60, 0x0000000000000000000000000000000000000000)
                mstore(0x80, id)
                mstore(0xa0, amount)
                mstore(0xc0, 0xa0)
                mstore(0xe0, dataLen)
                calldatacopy(0x100, 0xa4, dataLen)
                if iszero(call(gas(), to, 0, 0x3c, add(196, dataLen), 0, 4)) {revert(0,0)}
                if iszero(eq(0xf23a6e61, shr(0xe0, mload(0)))) {revert(0, 0)}
            }
            function setURI(id, lenOffset) {
                let uriOffset := getURIOffset(id)
                let length := calldataload(lenOffset)

                let readptr := 0x64

                switch gt(length, 31)
                case 0x00 {
                    //store the short string
                    //lowest byte = LLLLLLL0 - where L bits store the length
                    let lowestbyte := shl(1, length)
                    let strbytes := calldataload(readptr)
                    //strbytes is where S contain bytes of the string.  L is the lowest byte containing encoded length and flag.
                    //SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS0
                    //0000000000000000000000000000000L
                    //bitwise or
                    //SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSL

                    let data := or(strbytes, lowestbyte)
                    sstore(uriOffset, data)
                }
                case 0x01 {
                    // Length and the flag are stored in the slot
                    // the lowest bit is the flag and is set to 1 for a long string.
                    sstore(uriOffset, add(shl(1, length), 1))

                    //find the slot to store the first word string data
                    mstore(0x00, uriOffset)
                    let sslot := keccak256(0x00, 0x20)

                    let s := 0
                    for {} gt(length, mul(s, 0x20)) {} {
                        sstore(add(sslot, s), calldataload(readptr))
                        s := add(s, 1)
                        readptr := add(readptr, 0x20)
                    }
                }

                // emit event URI(string value, uint256 indexed id);
                //abi offset
                mstore(0x80, 0x20)
                //abi length
                mstore(0xa0, length)
                //string data
                //calldatacopy the string to memory
                calldatacopy(0xc0, 0x64, length)
                //round up to next multiple of 32 bytes for abi encoding
                let slen := mul(add(div(length,0x20),1),0x20)
                log2(0x80, add(0x40,slen), 0x6bb7ff708619ba0610cba295a58592e0451dee2622938c8755667688daf3529b, id)    
            }
            function getURI(id) {
                let uriOffset := getURIOffset(id)

                let u := sload(uriOffset)

                //convert from solidity encoded string to abi encoded string

                //check the lowest order byte for a 1 .
                let isLongString := and(u, 0x1)

                //offset is the first word in abi encoding
                mstore(0x80, 0x20)

                switch isLongString
                case 0x00 {
                    //. stored in the lowest word as 2x length
                    let lowestbyte := and(u, 0xFF)
                    //shift right by 1 bit to divide by 2.
                    let length := shr(0x01, lowestbyte)
                    //at the offset, we store the length
                    mstore(0xa0, length)
                    //store the string bytes immediately following length
                    mstore(0xc0, shl(8, shr(8, u)))
                    return(0x80, 0x60)
                }
                default {
                    //find the slot containing the first word of string data
                    mstore(0x00, uriOffset)
                    let slot := keccak256(0x00, 0x20)

                    //get the length. stored as 2x length
                    let length := shr(0x01, u)
                    mstore(0xa0, length)
                    //start writing the bytes at the next word after length
                    let next := 0xc0
                    let s := 0
                    //loop until we have encoded the total length
                    //the final word is padded with 0s for abi encoding so
                    for {} gt(length, mul(s, 0x20)) { s := add(s, 1) } {
                        //load from storage and write to memory
                        mstore(next, sload(add(slot, s)))

                        //move write pointer forward one word
                        next := add(next, 0x20)
                    }
                    return(0x80, add(0x40, mul(s, 0x20)))
                }
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
            function getURIOffset(id) -> offset {
                mstore(0, id)
                offset := keccak256(0, 0x20)
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