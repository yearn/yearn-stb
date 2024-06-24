// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.18 ^0.8.20;

// lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// lib/openzeppelin-contracts/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

// lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// lib/tokenized-strategy-periphery/src/utils/Clonable.sol

contract Clonable {
    /// @notice Set to the address to auto clone from.
    address public original;

    /**
     * @notice Clone the contracts default `original` contract.
     * @return Address of the new Minimal Proxy clone.
     */
    function _clone() internal virtual returns (address) {
        return _clone(original);
    }

    /**
     * @notice Clone any `_original` contract.
     * @return _newContract Address of the new Minimal Proxy clone.
     */
    function _clone(
        address _original
    ) internal virtual returns (address _newContract) {
        // Copied from https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactory.sol
        bytes20 addressBytes = bytes20(_original);
        assembly {
            // EIP-1167 bytecode
            let clone_code := mload(0x40)
            mstore(
                clone_code,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone_code, 0x14), addressBytes)
            mstore(
                add(clone_code, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            _newContract := create(0, clone_code, 0x37)
        }
    }
}

// lib/tokenized-strategy-periphery/src/utils/Governance.sol

contract Governance {
    /// @notice Emitted when the governance address is updated.
    event GovernanceTransferred(
        address indexed previousGovernance,
        address indexed newGovernance
    );

    modifier onlyGovernance() {
        _checkGovernance();
        _;
    }

    /// @notice Checks if the msg sender is the governance.
    function _checkGovernance() internal view virtual {
        require(governance == msg.sender, "!governance");
    }

    /// @notice Address that can set the default base fee and provider
    address public governance;

    constructor(address _governance) {
        governance = _governance;

        emit GovernanceTransferred(address(0), _governance);
    }

    /**
     * @notice Sets a new address as the governance of the contract.
     * @dev Throws if the caller is not current governance.
     * @param _newGovernance The new governance address.
     */
    function transferGovernance(
        address _newGovernance
    ) external virtual onlyGovernance {
        require(_newGovernance != address(0), "ZERO ADDRESS");
        address oldGovernance = governance;
        governance = _newGovernance;

        emit GovernanceTransferred(oldGovernance, _newGovernance);
    }
}

// lib/yearn-vaults-v3/contracts/interfaces/Roles.sol

// prettier-ignore
library Roles {
    uint256 internal constant ADD_STRATEGY_MANAGER             = 1;
    uint256 internal constant REVOKE_STRATEGY_MANAGER          = 2;
    uint256 internal constant FORCE_REVOKE_MANAGER             = 4;
    uint256 internal constant ACCOUNTANT_MANAGER               = 8;
    uint256 internal constant QUEUE_MANAGER                   = 16;
    uint256 internal constant REPORTING_MANAGER               = 32;
    uint256 internal constant DEBT_MANAGER                    = 64;
    uint256 internal constant MAX_DEBT_MANAGER               = 128;
    uint256 internal constant DEPOSIT_LIMIT_MANAGER          = 256;
    uint256 internal constant WITHDRAW_LIMIT_MANAGER         = 512;
    uint256 internal constant MINIMUM_IDLE_MANAGER          = 1024;
    uint256 internal constant PROFIT_UNLOCK_MANAGER         = 2048;
    uint256 internal constant DEBT_PURCHASER                = 4096;
    uint256 internal constant EMERGENCY_MANAGER             = 8192;
    uint256 internal constant ALL                          = 16383;
}

// src/Positions.sol

contract Positions {
    /// @notice Emitted when a new address is set for a position.
    event UpdatePositionHolder(
        bytes32 indexed position,
        address indexed newAddress
    );

    /// @notice Emitted when a new set of roles is set for a position
    event UpdatePositionRoles(bytes32 indexed position, uint256 newRoles);

    /// @notice Position struct
    struct Position {
        address holder;
        uint96 roles;
    }

    /// @notice Only allow position holder to call.
    modifier onlyPositionHolder(bytes32 _positionId) {
        _isPositionHolder(_positionId);
        _;
    }

    /// @notice Check if the msg sender is specified position holder.
    function _isPositionHolder(bytes32 _positionId) internal view virtual {
        require(msg.sender == getPositionHolder(_positionId), "!allowed");
    }

    /// @notice Mapping of position ID to position information.
    mapping(bytes32 => Position) internal _positions;

    /**
     * @notice Setter function for updating a positions holder.
     */
    function _setPositionHolder(
        bytes32 _position,
        address _newHolder
    ) internal virtual {
        _positions[_position].holder = _newHolder;

        emit UpdatePositionHolder(_position, _newHolder);
    }

    /**
     * @notice Setter function for updating a positions roles.
     */
    function _setPositionRoles(
        bytes32 _position,
        uint256 _newRoles
    ) internal virtual {
        _positions[_position].roles = uint96(_newRoles);

        emit UpdatePositionRoles(_position, _newRoles);
    }

    /**
     * @notice Get the address and roles given to a specific position.
     * @param _positionId The position identifier.
     * @return The address that holds that position.
     * @return The roles given to the specified position.
     */
    function getPosition(
        bytes32 _positionId
    ) public view virtual returns (address, uint256) {
        Position memory _position = _positions[_positionId];
        return (_position.holder, uint256(_position.roles));
    }

    /**
     * @notice Get the current address assigned to a specific position.
     * @param _positionId The position identifier.
     * @return The current address assigned to the specified position.
     */
    function getPositionHolder(
        bytes32 _positionId
    ) public view virtual returns (address) {
        return _positions[_positionId].holder;
    }

    /**
     * @notice Get the current roles given to a specific position ID.
     * @param _positionId The position identifier.
     * @return The current roles given to the specified position ID.
     */
    function getPositionRoles(
        bytes32 _positionId
    ) public view virtual returns (uint256) {
        return uint256(_positions[_positionId].roles);
    }
}

// src/interfaces/Yearn/IAccountant.sol

/// @title IAccountant.
interface IAccountant {
    /// @notice An event emitted when a vault is added or removed.
    event VaultChanged(address indexed vault, ChangeType change);

    /// @notice An event emitted when the default fee configuration is updated.
    event UpdateDefaultFeeConfig(Fee defaultFeeConfig);

    /// @notice An event emitted when the future fee manager is set.
    event SetFutureFeeManager(address indexed futureFeeManager);

    /// @notice An event emitted when a new fee manager is accepted.
    event NewFeeManager(address indexed feeManager);

    /// @notice An event emitted when a new vault manager is set.
    event UpdateVaultManager(address indexed newVaultManager);

    /// @notice An event emitted when the fee recipient is updated.
    event UpdateFeeRecipient(
        address indexed oldFeeRecipient,
        address indexed newFeeRecipient
    );

    /// @notice An event emitted when a custom fee configuration is updated.
    event UpdateCustomFeeConfig(address indexed vault, Fee custom_config);

    /// @notice An event emitted when a custom fee configuration is removed.
    event RemovedCustomFeeConfig(address indexed vault);

    /// @notice An event emitted when the `maxLoss` parameter is updated.
    event UpdateMaxLoss(uint256 maxLoss);

    /// @notice An event emitted when rewards are distributed.
    event DistributeRewards(address indexed token, uint256 rewards);

    /// @notice Enum defining change types (added or removed).
    enum ChangeType {
        NULL,
        ADDED,
        REMOVED
    }

    /// @notice Struct representing fee details.
    struct Fee {
        uint16 managementFee; // Annual management fee to charge.
        uint16 performanceFee; // Performance fee to charge.
        uint16 refundRatio; // Refund ratio to give back on losses.
        uint16 maxFee; // Max fee allowed as a percent of gain.
        uint16 maxGain; // Max percent gain a strategy can report.
        uint16 maxLoss; // Max percent loss a strategy can report.
        bool custom; // Flag to set for custom configs.
    }

    /// @notice The amount of max loss to use when redeeming from vaults.
    function maxLoss() external view returns (uint256);

    /// @notice The address of the fee manager.
    function feeManager() external view returns (address);

    /// @notice The address of the fee recipient.
    function feeRecipient() external view returns (address);

    /// @notice An address that can add or remove vaults.
    function vaultManager() external view returns (address);

    /// @notice The address of the future fee manager.
    function futureFeeManager() external view returns (address);

    /// @notice The default fee configuration.
    function defaultConfig() external view returns (Fee memory);

    /// @notice Mapping to track added vaults.
    function vaults(address) external view returns (bool);

    /// @notice Mapping vault => custom Fee config if any.
    function customConfig(address) external view returns (Fee memory);

    /// @notice Mapping vault => strategy => flag for one time healthcheck skips.
    function skipHealthCheck(address, address) external view returns (bool);

    /**
     * @notice Called by a vault when a `strategy` is reporting.
     * @dev The msg.sender must have been added to the `vaults` mapping.
     * @param strategy Address of the strategy reporting.
     * @param gain Amount of the gain if any.
     * @param loss Amount of the loss if any.
     * @return totalFees if any to charge.
     * @return totalRefunds if any for the vault to pull.
     */
    function report(
        address strategy,
        uint256 gain,
        uint256 loss
    ) external returns (uint256 totalFees, uint256 totalRefunds);

    /**
     * @notice Function to add a new vault for this accountant to charge fees for.
     * @dev This is not used to set any of the fees for the specific vault or strategy. Each fee will be set separately.
     * @param vault The address of a vault to allow to use this accountant.
     */
    function addVault(address vault) external;

    /**
     * @notice Function to remove a vault from this accountant's fee charging list.
     * @param vault The address of the vault to be removed from this accountant.
     */
    function removeVault(address vault) external;
    /**
     * @notice Function to update the default fee configuration used for 
        all strategies that don't have a custom config set.
     * @param defaultManagement Default annual management fee to charge.
     * @param defaultPerformance Default performance fee to charge.
     * @param defaultRefund Default refund ratio to give back on losses.
     * @param defaultMaxFee Default max fee to allow as a percent of gain.
     * @param defaultMaxGain Default max percent gain a strategy can report.
     * @param defaultMaxLoss Default max percent loss a strategy can report.
     */
    function updateDefaultConfig(
        uint16 defaultManagement,
        uint16 defaultPerformance,
        uint16 defaultRefund,
        uint16 defaultMaxFee,
        uint16 defaultMaxGain,
        uint16 defaultMaxLoss
    ) external;

    /**
     * @notice Function to set a custom fee configuration for a specific vault.
     * @param vault The vault the strategy is hooked up to.
     * @param customManagement Custom annual management fee to charge.
     * @param customPerformance Custom performance fee to charge.
     * @param customRefund Custom refund ratio to give back on losses.
     * @param customMaxFee Custom max fee to allow as a percent of gain.
     * @param customMaxGain Custom max percent gain a strategy can report.
     * @param customMaxLoss Custom max percent loss a strategy can report.
     */
    function setCustomConfig(
        address vault,
        uint16 customManagement,
        uint16 customPerformance,
        uint16 customRefund,
        uint16 customMaxFee,
        uint16 customMaxGain,
        uint16 customMaxLoss
    ) external;

    /**
     * @notice Function to remove a previously set custom fee configuration for a vault.
     * @param vault The vault to remove custom setting for.
     */
    function removeCustomConfig(address vault) external;

    /**
     * @notice Turn off the health check for a specific `vault` `strategy` combo.
     * @dev This will only last for one report and get automatically turned back on.
     * @param vault Address of the vault.
     * @param strategy Address of the strategy.
     */
    function turnOffHealthCheck(address vault, address strategy) external;

    /**
     * @notice Public getter to check for custom setting.
     * @dev We use uint256 for the flag since its cheaper so this
     *   will convert it to a bool for easy view functions.
     *
     * @param vault Address of the vault.
     * @return If a custom fee config is set.
     */
    function useCustomConfig(address vault) external view returns (bool);

    /**
     * @notice Get the full config used for a specific `vault`.
     * @param vault Address of the vault.
     * @return fee The config that would be used during the report.
     */
    function getVaultConfig(
        address vault
    ) external view returns (Fee memory fee);

    /**
     * @notice Function to redeem the underlying asset from a vault.
     * @dev Will default to using the full balance of the vault.
     * @param vault The vault to redeem from.
     */
    function redeemUnderlying(address vault) external;

    /**
     * @notice Function to redeem the underlying asset from a vault.
     * @param vault The vault to redeem from.
     * @param amount The amount in vault shares to redeem.
     */
    function redeemUnderlying(address vault, uint256 amount) external;

    /**
     * @notice Sets the `maxLoss` parameter to be used on redeems.
     * @param _maxLoss The amount in basis points to set as the maximum loss.
     */
    function setMaxLoss(uint256 _maxLoss) external;

    /**
     * @notice Function to distribute all accumulated fees to the designated recipient.
     * @param token The token to distribute.
     */
    function distribute(address token) external;

    /**
     * @notice Function to distribute accumulated fees to the designated recipient.
     * @param token The token to distribute.
     * @param amount amount of token to distribute.
     */
    function distribute(address token, uint256 amount) external;

    /**
     * @notice Function to set a future fee manager address.
     * @param _futureFeeManager The address to set as the future fee manager.
     */
    function setFutureFeeManager(address _futureFeeManager) external;

    /**
     * @notice Function to accept the role change and become the new fee manager.
     * @dev This function allows the future fee manager to accept the role change and become the new fee manager.
     */
    function acceptFeeManager() external;
    /**
     * @notice Function to set a new vault manager.
     * @param newVaultManager Address to add or remove vaults.
     */
    function setVaultManager(address newVaultManager) external;

    /**
     * @notice Function to set a new address to receive distributed rewards.
     * @param newFeeRecipient Address to receive distributed fees.
     */
    function setFeeRecipient(address newFeeRecipient) external;
}

// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// lib/vault-periphery/contracts/registry/ReleaseRegistry.sol

interface IFactory {
    function apiVersion() external view returns (string memory);
}

/**
 * @title YearnV3 Release Registry
 * @author yearn.finance
 * @notice
 *  Used by Yearn Governance to track on chain all
 *  releases of the V3 vaults by API Version.
 */
contract ReleaseRegistry is Governance {
    event NewRelease(
        uint256 indexed releaseId,
        address indexed factory,
        string apiVersion
    );

    string public constant name = "Yearn V3 Release Registry";

    // The total number of releases that have been deployed
    uint256 public numReleases;

    // Mapping of release id starting at 0 to the address
    // of the corresponding factory for that release.
    mapping(uint256 => address) public factories;

    // Mapping of the API version for a specific release to the
    // place in the order it was released.
    mapping(string => uint256) public releaseTargets;

    constructor(address _governance) Governance(_governance) {}

    /**
     * @notice Returns the latest factory.
     * @dev Throws if no releases are registered yet.
     * @return The address of the factory for the latest release.
     */
    function latestFactory() external view virtual returns (address) {
        return factories[numReleases - 1];
    }

    /**
     * @notice Returns the api version of the latest release.
     * @dev Throws if no releases are registered yet.
     * @return The api version of the latest release.
     */
    function latestRelease() external view virtual returns (string memory) {
        return IFactory(factories[numReleases - 1]).apiVersion(); // dev: no release
    }

    /**
     * @notice Issue a new release using a deployed factory.
     * @dev Stores the factory address in `factories` and the release
     * target in `releaseTargets` with its associated API version.
     *
     *   Throws if caller isn't `governance`.
     *   Throws if the api version is the same as the previous release.
     *   Emits a `NewRelease` event.
     *
     * @param _factory The factory that will be used create new vaults.
     */
    function newRelease(address _factory) external virtual onlyGovernance {
        // Check if the release is different from the current one
        uint256 releaseId = numReleases;

        string memory apiVersion = IFactory(_factory).apiVersion();

        if (releaseId > 0) {
            // Make sure this isn't the same as the last one
            require(
                keccak256(
                    bytes(IFactory(factories[releaseId - 1]).apiVersion())
                ) != keccak256(bytes(apiVersion)),
                "ReleaseRegistry: same api version"
            );
        }

        // Update latest release.
        factories[releaseId] = _factory;

        // Set the api to the target.
        releaseTargets[apiVersion] = releaseId;

        // Increase our number of releases.
        numReleases = releaseId + 1;

        // Log the release for external listeners
        emit NewRelease(releaseId, _factory, apiVersion);
    }
}

// lib/openzeppelin-contracts/contracts/interfaces/IERC4626.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC4626.sol)

/**
 * @dev Interface of the ERC4626 "Tokenized Vault Standard", as defined in
 * https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 */
interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    /**
     * @dev Returns the address of the underlying token used for the Vault for accounting, depositing, and withdrawing.
     *
     * - MUST be an ERC-20 token contract.
     * - MUST NOT revert.
     */
    function asset() external view returns (address assetTokenAddress);

    /**
     * @dev Returns the total amount of the underlying asset that is “managed” by Vault.
     *
     * - SHOULD include any compounding that occurs from yield.
     * - MUST be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT revert.
     */
    function totalAssets() external view returns (uint256 totalManagedAssets);

    /**
     * @dev Returns the amount of shares that the Vault would exchange for the amount of assets provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToShares(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Returns the amount of assets that the Vault would exchange for the amount of shares provided, in an ideal
     * scenario where all the conditions are met.
     *
     * - MUST NOT be inclusive of any fees that are charged against assets in the Vault.
     * - MUST NOT show any variations depending on the caller.
     * - MUST NOT reflect slippage or other on-chain conditions, when performing the actual exchange.
     * - MUST NOT revert.
     *
     * NOTE: This calculation MAY NOT reflect the “per-user” price-per-share, and instead should reflect the
     * “average-user’s” price-per-share, meaning what the average user should expect to see when exchanging to and
     * from.
     */
    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be deposited into the Vault for the receiver,
     * through a deposit call.
     *
     * - MUST return a limited value if receiver is subject to some deposit limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of assets that may be deposited.
     * - MUST NOT revert.
     */
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their deposit at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of Vault shares that would be minted in a deposit
     *   call in the same transaction. I.e. deposit should return the same or more shares as previewDeposit if called
     *   in the same transaction.
     * - MUST NOT account for deposit limits like those returned from maxDeposit and should always act as though the
     *   deposit would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewDeposit SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Mints shares Vault shares to receiver by depositing exactly amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   deposit execution, and are accounted for during deposit.
     * - MUST revert if all of assets cannot be deposited (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of the Vault shares that can be minted for the receiver, through a mint call.
     * - MUST return a limited value if receiver is subject to some mint limit.
     * - MUST return 2 ** 256 - 1 if there is no limit on the maximum amount of shares that may be minted.
     * - MUST NOT revert.
     */
    function maxMint(address receiver) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their mint at the current block, given
     * current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of assets that would be deposited in a mint call
     *   in the same transaction. I.e. mint should return the same or fewer assets as previewMint if called in the
     *   same transaction.
     * - MUST NOT account for mint limits like those returned from maxMint and should always act as though the mint
     *   would be accepted, regardless if the user has enough tokens approved, etc.
     * - MUST be inclusive of deposit fees. Integrators should be aware of the existence of deposit fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewMint SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by minting.
     */
    function previewMint(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Mints exactly shares Vault shares to receiver by depositing amount of underlying tokens.
     *
     * - MUST emit the Deposit event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the mint
     *   execution, and are accounted for during mint.
     * - MUST revert if all of shares cannot be minted (due to deposit limit being reached, slippage, the user not
     *   approving enough underlying tokens to the Vault contract, etc).
     *
     * NOTE: most implementations will require pre-approval of the Vault with the Vault’s underlying asset token.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @dev Returns the maximum amount of the underlying asset that can be withdrawn from the owner balance in the
     * Vault, through a withdraw call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their withdrawal at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no fewer than the exact amount of Vault shares that would be burned in a withdraw
     *   call in the same transaction. I.e. withdraw should return the same or fewer shares as previewWithdraw if
     *   called
     *   in the same transaction.
     * - MUST NOT account for withdrawal limits like those returned from maxWithdraw and should always act as though
     *   the withdrawal would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToShares and previewWithdraw SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by depositing.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    /**
     * @dev Burns shares from owner and sends exactly assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   withdraw execution, and are accounted for during withdraw.
     * - MUST revert if all of assets cannot be withdrawn (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * Note that some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /**
     * @dev Returns the maximum amount of Vault shares that can be redeemed from the owner balance in the Vault,
     * through a redeem call.
     *
     * - MUST return a limited value if owner is subject to some withdrawal limit or timelock.
     * - MUST return balanceOf(owner) if owner is not subject to any withdrawal limit or timelock.
     * - MUST NOT revert.
     */
    function maxRedeem(address owner) external view returns (uint256 maxShares);

    /**
     * @dev Allows an on-chain or off-chain user to simulate the effects of their redeemption at the current block,
     * given current on-chain conditions.
     *
     * - MUST return as close to and no more than the exact amount of assets that would be withdrawn in a redeem call
     *   in the same transaction. I.e. redeem should return the same or more assets as previewRedeem if called in the
     *   same transaction.
     * - MUST NOT account for redemption limits like those returned from maxRedeem and should always act as though the
     *   redemption would be accepted, regardless if the user has enough shares, etc.
     * - MUST be inclusive of withdrawal fees. Integrators should be aware of the existence of withdrawal fees.
     * - MUST NOT revert.
     *
     * NOTE: any unfavorable discrepancy between convertToAssets and previewRedeem SHOULD be considered slippage in
     * share price or some other type of condition, meaning the depositor will lose assets by redeeming.
     */
    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    /**
     * @dev Burns exactly shares from owner and sends assets of underlying tokens to receiver.
     *
     * - MUST emit the Withdraw event.
     * - MAY support an additional flow in which the underlying tokens are owned by the Vault contract before the
     *   redeem execution, and are accounted for during redeem.
     * - MUST revert if all of shares cannot be redeemed (due to withdrawal limit being reached, slippage, the owner
     *   not having enough shares, etc).
     *
     * NOTE: some implementations will require pre-requesting to the Vault before a withdrawal may be performed.
     * Those methods should be performed separately.
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}

// lib/openzeppelin-contracts/contracts/utils/Strings.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

// lib/yearn-vaults-v3/contracts/interfaces/IVault.sol

interface IVault is IERC4626 {
    // STRATEGY EVENTS
    event StrategyChanged(address indexed strategy, uint256 change_type);
    event StrategyReported(
        address indexed strategy,
        uint256 gain,
        uint256 loss,
        uint256 current_debt,
        uint256 protocol_fees,
        uint256 total_fees,
        uint256 total_refunds
    );
    // DEBT MANAGEMENT EVENTS
    event DebtUpdated(
        address indexed strategy,
        uint256 current_debt,
        uint256 new_debt
    );
    // ROLE UPDATES
    event RoleSet(address indexed account, uint256 role);
    event UpdateRoleManager(address indexed role_manager);

    event UpdateAccountant(address indexed accountant);
    event UpdateDefaultQueue(address[] new_default_queue);
    event UpdateUseDefaultQueue(bool use_default_queue);
    event UpdatedMaxDebtForStrategy(
        address indexed sender,
        address indexed strategy,
        uint256 new_debt
    );
    event UpdateDepositLimit(uint256 deposit_limit);
    event UpdateMinimumTotalIdle(uint256 minimum_total_idle);
    event UpdateProfitMaxUnlockTime(uint256 profit_max_unlock_time);
    event DebtPurchased(address indexed strategy, uint256 amount);
    event Shutdown();

    struct StrategyParams {
        uint256 activation;
        uint256 last_report;
        uint256 current_debt;
        uint256 max_debt;
    }

    function FACTORY() external view returns (uint256);

    function strategies(address) external view returns (StrategyParams memory);

    function default_queue(uint256) external view returns (address);

    function use_default_queue() external view returns (bool);

    function minimum_total_idle() external view returns (uint256);

    function deposit_limit() external view returns (uint256);

    function deposit_limit_module() external view returns (address);

    function withdraw_limit_module() external view returns (address);

    function accountant() external view returns (address);

    function roles(address) external view returns (uint256);

    function role_manager() external view returns (address);

    function future_role_manager() external view returns (address);

    function isShutdown() external view returns (bool);

    function nonces(address) external view returns (uint256);

    function initialize(
        address,
        string memory,
        string memory,
        address,
        uint256
    ) external;

    function set_accountant(address new_accountant) external;

    function set_default_queue(address[] memory new_default_queue) external;

    function set_use_default_queue(bool) external;

    function set_deposit_limit(uint256 deposit_limit) external;

    function set_deposit_limit(
        uint256 deposit_limit,
        bool should_override
    ) external;

    function set_deposit_limit_module(
        address new_deposit_limit_module
    ) external;

    function set_deposit_limit_module(
        address new_deposit_limit_module,
        bool should_override
    ) external;

    function set_withdraw_limit_module(
        address new_withdraw_limit_module
    ) external;

    function set_minimum_total_idle(uint256 minimum_total_idle) external;

    function setProfitMaxUnlockTime(
        uint256 new_profit_max_unlock_time
    ) external;

    function set_role(address account, uint256 role) external;

    function add_role(address account, uint256 role) external;

    function remove_role(address account, uint256 role) external;

    function transfer_role_manager(address role_manager) external;

    function accept_role_manager() external;

    function unlockedShares() external view returns (uint256);

    function pricePerShare() external view returns (uint256);

    function get_default_queue() external view returns (address[] memory);

    function process_report(
        address strategy
    ) external returns (uint256, uint256);

    function buy_debt(address strategy, uint256 amount) external;

    function add_strategy(address new_strategy) external;

    function revoke_strategy(address strategy) external;

    function force_revoke_strategy(address strategy) external;

    function update_max_debt_for_strategy(
        address strategy,
        uint256 new_max_debt
    ) external;

    function update_debt(
        address strategy,
        uint256 target_debt
    ) external returns (uint256);

    function update_debt(
        address strategy,
        uint256 target_debt,
        uint256 max_loss
    ) external returns (uint256);

    function shutdown_vault() external;

    function totalIdle() external view returns (uint256);

    function totalDebt() external view returns (uint256);

    function apiVersion() external view returns (string memory);

    function assess_share_of_unrealised_losses(
        address strategy,
        uint256 assets_needed
    ) external view returns (uint256);

    function profitMaxUnlockTime() external view returns (uint256);

    function fullProfitUnlockDate() external view returns (uint256);

    function profitUnlockingRate() external view returns (uint256);

    function lastProfitUpdate() external view returns (uint256);

    //// NON-STANDARD ERC-4626 FUNCTIONS \\\\

    function withdraw(
        uint256 assets,
        address receiver,
        address owner,
        uint256 max_loss
    ) external returns (uint256);

    function withdraw(
        uint256 assets,
        address receiver,
        address owner,
        uint256 max_loss,
        address[] memory strategies
    ) external returns (uint256);

    function redeem(
        uint256 shares,
        address receiver,
        address owner,
        uint256 max_loss
    ) external returns (uint256);

    function redeem(
        uint256 shares,
        address receiver,
        address owner,
        uint256 max_loss,
        address[] memory strategies
    ) external returns (uint256);

    function maxWithdraw(
        address owner,
        uint256 max_loss
    ) external view returns (uint256);

    function maxWithdraw(
        address owner,
        uint256 max_loss,
        address[] memory strategies
    ) external view returns (uint256);

    function maxRedeem(
        address owner,
        uint256 max_loss
    ) external view returns (uint256);

    function maxRedeem(
        address owner,
        uint256 max_loss,
        address[] memory strategies
    ) external view returns (uint256);

    //// NON-STANDARD ERC-20 FUNCTIONS \\\\

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// lib/vault-periphery/contracts/registry/Registry.sol

interface IVaultFactory {
    function deploy_new_vault(
        address asset,
        string memory name,
        string memory symbol,
        address role_manager,
        uint256 profit_max_unlock_time
    ) external returns (address);

    function apiVersion() external view returns (string memory);
}

/**
 * @title YearnV3 Registry
 * @author yearn.finance
 * @notice
 *  Serves as an on chain registry to track any Yearn
 *  vaults and strategies that a certain party wants to
 *  endorse.
 *
 *  Can also be used to deploy new vaults of any specific
 *  API version.
 */
contract Registry is Governance {
    /// @notice Emitted when a new vault is deployed or added.
    event NewEndorsedVault(
        address indexed vault,
        address indexed asset,
        uint256 releaseVersion,
        uint256 vaultType
    );

    /// @notice Emitted when a vault is removed.
    event RemovedVault(
        address indexed vault,
        address indexed asset,
        uint256 releaseVersion,
        uint256 vaultType
    );

    /// @notice Emitted when a vault is tagged which a string.
    event VaultTagged(address indexed vault);

    /// @notice Emitted when gov adds ore removes a `tagger`.
    event UpdateTagger(address indexed account, bool status);

    /// @notice Emitted when gov adds ore removes a `endorser`.
    event UpdateEndorser(address indexed account, bool status);

    /// @notice Can only be gov or an `endorser`.
    modifier onlyEndorsers() {
        _isEndorser();
        _;
    }

    /// @notice Can only be gov or a `tagger`.
    modifier onlyTaggers() {
        _isTagger();
        _;
    }

    /// @notice Check is gov or an `endorser`.
    function _isEndorser() internal view {
        require(msg.sender == governance || endorsers[msg.sender], "!endorser");
    }

    /// @notice Check is gov or a `tagger`.
    function _isTagger() internal view {
        require(msg.sender == governance || taggers[msg.sender], "!tagger");
    }

    // Struct stored for every endorsed vault or strategy for
    // off chain use to easily retrieve info.
    struct Info {
        // The token thats being used.
        address asset;
        // The release number corresponding to the release registries version.
        uint96 releaseVersion;
        // Type of vault.
        uint64 vaultType;
        // Time when the vault was deployed for easier indexing.
        uint128 deploymentTimestamp;
        // Index the vault is at in array for easy removals.
        uint64 index;
        // String so that management can tag a vault with any info for FE's.
        string tag;
    }

    // Address used to get the specific versions from.
    address public immutable releaseRegistry;

    // Default type used for Multi strategy "Allocator" vaults.
    uint256 public constant MULTI_STRATEGY_TYPE = 1;

    // Default type used for Single "Tokenized" Strategy vaults.
    uint256 public constant SINGLE_STRATEGY_TYPE = 2;

    // Custom name for this Registry.
    string public name;

    // Mapping for any address that is allowed to tag a vault.
    mapping(address => bool) public taggers;

    // Mapping for any address that is allowed to deploy or endorse.
    mapping(address => bool) public endorsers;

    // vault/strategy address => Info struct.
    mapping(address => Info) public vaultInfo;

    // Mapping to check if a specific `asset` has a vault.
    mapping(address => bool) public assetIsUsed;

    // asset => array of all endorsed vaults.
    mapping(address => address[]) internal _endorsedVaults;

    // Array of all tokens used as the underlying.
    address[] public assets;

    /**
     * @param _governance Address to set as owner of the Registry.
     * @param _name The custom string for this custom registry to be called.
     * @param _releaseRegistry The Permissionless releaseRegistry to deploy vaults through.
     */
    constructor(
        address _governance,
        string memory _name,
        address _releaseRegistry
    ) Governance(_governance) {
        // Set name.
        name = _name;
        // Set releaseRegistry.
        releaseRegistry = _releaseRegistry;
    }

    /**
     * @notice Returns the total number of assets being used as the underlying.
     * @return The amount of assets.
     */
    function numAssets() external view virtual returns (uint256) {
        return assets.length;
    }

    /**
     * @notice Get the full array of tokens being used.
     * @return The full array of underlying tokens being used/.
     */
    function getAssets() external view virtual returns (address[] memory) {
        return assets;
    }

    /**
     * @notice The amount of endorsed vaults for a specific token.
     * @return The amount of endorsed vaults.
     */
    function numEndorsedVaults(
        address _asset
    ) public view virtual returns (uint256) {
        return _endorsedVaults[_asset].length;
    }

    /**
     * @notice Get the array of vaults endorsed for an `_asset`.
     * @param _asset The underlying token used by the vaults.
     * @return The endorsed vaults.
     */
    function getEndorsedVaults(
        address _asset
    ) external view virtual returns (address[] memory) {
        return _endorsedVaults[_asset];
    }

    /**
     * @notice Get all endorsed vaults deployed using the Registry.
     * @dev This will return a nested array of all vaults deployed
     * separated by their underlying asset.
     *
     * This is only meant for off chain viewing and should not be used during any
     * on chain tx's.
     *
     * @return allEndorsedVaults A nested array containing all vaults.
     */
    function getAllEndorsedVaults()
        external
        view
        virtual
        returns (address[][] memory allEndorsedVaults)
    {
        address[] memory allAssets = assets;
        uint256 length = assets.length;

        allEndorsedVaults = new address[][](length);
        for (uint256 i; i < length; ++i) {
            allEndorsedVaults[i] = _endorsedVaults[allAssets[i]];
        }
    }

    /**
     * @notice Check if a vault is endorsed in this registry.
     * @dev This will check if the `asset` variable in the struct has been
     *   set for an easy external view check.
     * @param _vault Address of the vault to check.
     * @return . The vaults endorsement status.
     */
    function isEndorsed(address _vault) external view virtual returns (bool) {
        return vaultInfo[_vault].asset != address(0);
    }

    /**
     * @notice
     *    Create and endorse a new multi strategy "Allocator"
     *      vault and endorse it in this registry.
     * @dev
     *   Throws if caller isn't `owner`.
     *   Throws if no releases are registered yet.
     *   Emits a `NewEndorsedVault` event.
     * @param _asset The asset that may be deposited into the new Vault.
     * @param _name Specify a custom Vault name. .
     * @param _symbol Specify a custom Vault symbol name.
     * @param _roleManager The address authorized for guardian interactions in the new Vault.
     * @param _profitMaxUnlockTime The time strategy profits will unlock over.
     * @return _vault address of the newly-deployed vault
     */
    function newEndorsedVault(
        address _asset,
        string memory _name,
        string memory _symbol,
        address _roleManager,
        uint256 _profitMaxUnlockTime
    ) public virtual returns (address _vault) {
        return
            newEndorsedVault(
                _asset,
                _name,
                _symbol,
                _roleManager,
                _profitMaxUnlockTime,
                0 // Default to latest version.
            );
    }

    /**
     * @notice
     *    Create and endorse a new multi strategy "Allocator"
     *      vault and endorse it in this registry.
     * @dev
     *   Throws if caller isn't `owner`.
     *   Throws if no releases are registered yet.
     *   Emits a `NewEndorsedVault` event.
     * @param _asset The asset that may be deposited into the new Vault.
     * @param _name Specify a custom Vault name. .
     * @param _symbol Specify a custom Vault symbol name.
     * @param _roleManager The address authorized for guardian interactions in the new Vault.
     * @param _profitMaxUnlockTime The time strategy profits will unlock over.
     * @param _releaseDelta The number of releases prior to the latest to use as a target. NOTE: Set to 0 for latest.
     * @return _vault address of the newly-deployed vault
     */
    function newEndorsedVault(
        address _asset,
        string memory _name,
        string memory _symbol,
        address _roleManager,
        uint256 _profitMaxUnlockTime,
        uint256 _releaseDelta
    ) public virtual onlyEndorsers returns (address _vault) {
        // Get the target release based on the delta given.
        uint256 _releaseTarget = ReleaseRegistry(releaseRegistry)
            .numReleases() -
            1 -
            _releaseDelta;

        // Get the factory address for that specific Api version.
        address factory = ReleaseRegistry(releaseRegistry).factories(
            _releaseTarget
        );

        // Make sure we got an actual factory
        require(factory != address(0), "Registry: unknown release");

        // Deploy New vault.
        _vault = IVaultFactory(factory).deploy_new_vault(
            _asset,
            _name,
            _symbol,
            _roleManager,
            _profitMaxUnlockTime
        );

        // Register the vault with this Registry
        _registerVault(
            _vault,
            _asset,
            _releaseTarget,
            MULTI_STRATEGY_TYPE,
            block.timestamp
        );
    }

    /**
     * @notice Endorse an already deployed multi strategy vault.
     * @dev To be used with default values for `_releaseDelta`, `_vaultType`
     * and `_deploymentTimestamp`.

     * @param _vault Address of the vault to endorse.
     */
    function endorseMultiStrategyVault(address _vault) external virtual {
        endorseVault(_vault, 0, MULTI_STRATEGY_TYPE, 0);
    }

    /**
     * @notice Endorse an already deployed Single Strategy vault.
     * @dev To be used with default values for `_releaseDelta`, `_vaultType`
     * and `_deploymentTimestamp`.
     *
     * @param _vault Address of the vault to endorse.
     */
    function endorseSingleStrategyVault(address _vault) external virtual {
        endorseVault(_vault, 0, SINGLE_STRATEGY_TYPE, 0);
    }

    /**
     * @notice
     *    Adds an existing vault to the list of "endorsed" vaults for that asset.
     * @dev
     *    Throws if caller isn't `owner`.
     *    Throws if no releases are registered yet.
     *    Throws if `vault`'s api version does not match the release specified.
     *    Emits a `NewEndorsedVault` event.
     * @param _vault The vault that will be endorsed by the Registry.
     * @param _releaseDelta Specify the number of releases prior to the latest to use as a target.
     * @param _vaultType Type of vault to endorse.
     * @param _deploymentTimestamp The timestamp of when the vault was deployed for FE use.
     */
    function endorseVault(
        address _vault,
        uint256 _releaseDelta,
        uint256 _vaultType,
        uint256 _deploymentTimestamp
    ) public virtual onlyEndorsers {
        // Cannot endorse twice.
        require(vaultInfo[_vault].asset == address(0), "endorsed");
        require(_vaultType != 0, "no 0 type");
        require(_vaultType <= type(uint128).max, "type too high");
        require(_deploymentTimestamp <= block.timestamp, "!deployment time");

        // Will underflow if no releases created yet, or targeting prior to release history
        uint256 _releaseTarget = ReleaseRegistry(releaseRegistry)
            .numReleases() -
            1 -
            _releaseDelta; // dev: no releases

        // Get the API version for the target specified
        string memory apiVersion = IVaultFactory(
            ReleaseRegistry(releaseRegistry).factories(_releaseTarget)
        ).apiVersion();

        require(
            keccak256(bytes(IVault(_vault).apiVersion())) ==
                keccak256(bytes((apiVersion))),
            "Wrong API Version"
        );

        // Add to the end of the list of vaults for asset
        _registerVault(
            _vault,
            IVault(_vault).asset(),
            _releaseTarget,
            _vaultType,
            _deploymentTimestamp
        );
    }

    /**
     * @dev Function used to register a newly deployed or added vault.
     *
     * This well set all of the values for the vault in the `vaultInfo`
     * mapping as well as add the vault and the underlying asset to any
     * relevant arrays for tracking.
     *
     */
    function _registerVault(
        address _vault,
        address _asset,
        uint256 _releaseTarget,
        uint256 _vaultType,
        uint256 _deploymentTimestamp
    ) internal virtual {
        // Set the Info struct for this vault
        vaultInfo[_vault] = Info({
            asset: _asset,
            releaseVersion: uint96(_releaseTarget),
            vaultType: uint64(_vaultType),
            deploymentTimestamp: uint128(_deploymentTimestamp),
            index: uint64(_endorsedVaults[_asset].length),
            tag: ""
        });

        // Add to the endorsed vaults array.
        _endorsedVaults[_asset].push(_vault);

        if (!assetIsUsed[_asset]) {
            // We have a new asset to add
            assets.push(_asset);
            assetIsUsed[_asset] = true;
        }

        emit NewEndorsedVault(_vault, _asset, _releaseTarget, _vaultType);
    }

    /**
     * @notice Tag a vault with a specific string.
     * @dev This is available to governance to tag any vault or strategy
     * on chain if desired to arbitrarily classify any vaults.
     *   i.e. Certain ratings ("A") / Vault status ("Shutdown") etc.
     *
     * @param _vault Address of the vault or strategy to tag.
     * @param _tag The string to tag the vault or strategy with.
     */
    function tagVault(
        address _vault,
        string memory _tag
    ) external virtual onlyTaggers {
        require(vaultInfo[_vault].asset != address(0), "!Endorsed");
        vaultInfo[_vault].tag = _tag;

        emit VaultTagged(_vault);
    }

    /**
     * @notice Remove a `_vault`.
     * @dev Can be used as an efficient way to remove a vault
     * to not have to iterate over the full array.
     *
     * NOTE: This will not remove the asset from the `assets` array
     * if it is no longer in use and will have to be done manually.
     *
     * @param _vault Address of the vault to remove.
     */
    function removeVault(address _vault) external virtual onlyEndorsers {
        // Get the struct with all the vaults data.
        Info memory info = vaultInfo[_vault];
        require(info.asset != address(0), "!endorsed");
        require(
            _endorsedVaults[info.asset][info.index] == _vault,
            "wrong vault"
        );

        // Get the vault at the end of the array
        address lastVault = _endorsedVaults[info.asset][
            _endorsedVaults[info.asset].length - 1
        ];

        // If `_vault` is not the last item in the array.
        if (lastVault != _vault) {
            // Set the last index to the spot we are removing.
            _endorsedVaults[info.asset][info.index] = lastVault;

            // Update the index of the vault we moved
            vaultInfo[lastVault].index = uint64(info.index);
        }

        // Pop the last item off the array.
        _endorsedVaults[info.asset].pop();

        // Emit the event.
        emit RemovedVault(
            _vault,
            info.asset,
            info.releaseVersion,
            info.vaultType
        );

        // Delete the struct.
        delete vaultInfo[_vault];
    }

    /**
     * @notice Removes a specific `_asset` at `_index` from `assets`.
     * @dev Can be used if an asset is no longer in use after a vault or
     * strategy has also been removed.
     *
     * @param _asset The asset to remove from the array.
     * @param _index The index it sits at.
     */
    function removeAsset(
        address _asset,
        uint256 _index
    ) external virtual onlyEndorsers {
        require(assetIsUsed[_asset], "!in use");
        require(_endorsedVaults[_asset].length == 0, "still in use");
        require(assets[_index] == _asset, "wrong asset");

        // Replace `_asset` with the last index.
        assets[_index] = assets[assets.length - 1];

        // Pop last item off the array.
        assets.pop();

        // No longer used.
        assetIsUsed[_asset] = false;
    }

    /**
     * @notice Set a new address to be able to endorse or remove an existing endorser.
     * @param _account The address to set.
     * @param _canEndorse Bool if the `_account` can or cannot endorse.
     */
    function setEndorser(
        address _account,
        bool _canEndorse
    ) external virtual onlyGovernance {
        endorsers[_account] = _canEndorse;

        emit UpdateEndorser(_account, _canEndorse);
    }

    /**
     * @notice Set a new address to be able to tag a vault.
     * @param _account The address to set.
     * @param _canTag Bool if the `_account` can or cannot tag.
     */
    function setTagger(
        address _account,
        bool _canTag
    ) external virtual onlyGovernance {
        taggers[_account] = _canTag;

        emit UpdateTagger(_account, _canTag);
    }
}

// lib/vault-periphery/contracts/debtAllocators/DebtAllocator.sol

/**
 * @title YearnV3 Debt Allocator
 * @author yearn.finance
 * @notice
 *  This Debt Allocator is meant to be used alongside
 *  a Yearn V3 vault to provide the needed triggers for a keeper
 *  to perform automated debt updates for the vaults strategies.
 *
 *  Each allocator contract will serve one Vault and each strategy
 *  that should be managed by this allocator will need to be added
 *  manually by setting a `targetRatio` and `maxRatio`.
 *
 *  The allocator aims to allocate debt between the strategies
 *  based on their set target ratios. Which are denominated in basis
 *  points and represent the percent of total assets that specific
 *  strategy should hold.
 *
 *  The trigger will attempt to allocate up to the `maxRatio` when
 *  the strategy has `minimumChange` amount less than the `targetRatio`.
 *  And will pull funds from the strategy when it has `minimumChange`
 *  more than its `maxRatio`.
 */
contract DebtAllocator {
    /// @notice An event emitted when a strategies debt ratios are Updated.
    event UpdateStrategyDebtRatio(
        address indexed strategy,
        uint256 newTargetRatio,
        uint256 newMaxRatio,
        uint256 newTotalDebtRatio
    );

    /// @notice An event emitted when a strategy is added or removed.
    event StrategyChanged(address indexed strategy, Status status);

    /// @notice An event emitted when the minimum time to wait is updated.
    event UpdateMinimumWait(uint256 newMinimumWait);

    /// @notice An event emitted when the minimum change is updated.
    event UpdateMinimumChange(uint256 newMinimumChange);

    /// @notice An event emitted when a keeper is added or removed.
    event UpdateManager(address indexed manager, bool allowed);

    /// @notice An event emitted when the max debt update loss is updated.
    event UpdateMaxDebtUpdateLoss(uint256 newMaxDebtUpdateLoss);

    /// @notice Status when a strategy is added or removed from the allocator.
    enum Status {
        NULL,
        ADDED,
        REMOVED
    }

    /// @notice Struct for each strategies info.
    struct Config {
        // Flag to set when a strategy is added.
        bool added;
        // The ideal percent in Basis Points the strategy should have.
        uint16 targetRatio;
        // The max percent of assets the strategy should hold.
        uint16 maxRatio;
        // Timestamp of the last time debt was updated.
        // The debt updates must be done through this allocator
        // for this to be used.
        uint96 lastUpdate;
        // We have an extra 120 bits in the slot.
        // So we declare the variable in the struct so it can be
        // used if this contract is inherited.
        uint120 open;
    }

    /// @notice Make sure the caller is governance.
    modifier onlyGovernance() {
        _isGovernance();
        _;
    }

    /// @notice Make sure the caller is governance or a manager.
    modifier onlyManagers() {
        _isManager();
        _;
    }

    /// @notice Make sure the caller is a keeper
    modifier onlyKeepers() {
        _isKeeper();
        _;
    }

    /// @notice Check the Factories governance address.
    function _isGovernance() internal view virtual {
        require(
            msg.sender == DebtAllocatorFactory(factory).governance(),
            "!governance"
        );
    }

    /// @notice Check is either factories governance or local manager.
    function _isManager() internal view virtual {
        require(
            managers[msg.sender] ||
                msg.sender == DebtAllocatorFactory(factory).governance(),
            "!manager"
        );
    }

    /// @notice Check is one of the allowed keepers.
    function _isKeeper() internal view virtual {
        require(DebtAllocatorFactory(factory).keepers(msg.sender), "!keeper");
    }

    uint256 internal constant MAX_BPS = 10_000;

    /// @notice Address to get permissioned roles from.
    address public immutable factory;

    /// @notice Address of the vault this serves as allocator for.
    address public vault;

    /// @notice Time to wait between debt updates in seconds.
    uint256 public minimumWait;

    /// @notice The minimum amount denominated in asset that will
    // need to be moved to trigger a debt update.
    uint256 public minimumChange;

    /// @notice Total debt ratio currently allocated in basis points.
    // Can't be more than 10_000.
    uint256 public totalDebtRatio;

    /// @notice Max loss to accept on debt updates in basis points.
    uint256 public maxDebtUpdateLoss;

    /// @notice Mapping of addresses that are allowed to update debt ratios.
    mapping(address => bool) public managers;

    /// @notice Mapping of strategy => its config.
    mapping(address => Config) internal _configs;

    constructor() {
        // Set the factory to retrieve roles from. Will be the same for all clones so can use immutable.
        factory = msg.sender;

        // Don't allow for original version to be initialized.
        vault = address(1);
    }

    /**
     * @notice Initializes the debt allocator.
     * @dev Should be called atomically after cloning.
     * @param _vault Address of the vault this allocates debt for.
     * @param _minimumChange The minimum in asset that must be moved.
     */
    function initialize(address _vault, uint256 _minimumChange) public virtual {
        require(address(vault) == address(0), "!initialized");

        // Set initial variables.
        vault = _vault;
        minimumChange = _minimumChange;

        // Default max loss on debt updates to 1 BP.
        maxDebtUpdateLoss = 1;
    }

    /**
     * @notice Debt update wrapper for the vault.
     * @dev This can be used if a minimum time between debt updates
     *   is desired to be used for the trigger and to enforce a max loss.
     *
     *   This contract must have the DEBT_MANAGER role assigned to them.
     *
     *   The function signature matches the vault so no update to the
     *   call data is required.
     *
     *   This will also run checks on losses realized during debt
     *   updates to assure decreases did not realize profits outside
     *   of the allowed range.
     */
    function update_debt(
        address _strategy,
        uint256 _targetDebt
    ) public virtual onlyKeepers {
        IVault _vault = IVault(vault);

        // If going to 0 record full balance first.
        if (_targetDebt == 0) {
            _vault.process_report(_strategy);
        }

        // Update debt with the default max loss.
        _vault.update_debt(_strategy, _targetDebt, maxDebtUpdateLoss);

        // Update the last time the strategies debt was updated.
        _configs[_strategy].lastUpdate = uint96(block.timestamp);
    }

    /**
     * @notice Check if a strategy's debt should be updated.
     * @dev This should be called by a keeper to decide if a strategies
     * debt should be updated and if so by how much.
     *
     * @param _strategy Address of the strategy to check.
     * @return . Bool representing if the debt should be updated.
     * @return . Calldata if `true` or reason if `false`.
     */
    function shouldUpdateDebt(
        address _strategy
    ) public view virtual returns (bool, bytes memory) {
        // Get the strategy specific debt config.
        Config memory config = getConfig(_strategy);

        // Make sure the strategy has been added to the allocator.
        if (!config.added) return (false, bytes("!added"));

        // Check the base fee isn't too high.
        if (!DebtAllocatorFactory(factory).isCurrentBaseFeeAcceptable()) {
            return (false, bytes("Base Fee"));
        }

        // Cache the vault variable.
        IVault _vault = IVault(vault);
        // Retrieve the strategy specific parameters.
        IVault.StrategyParams memory params = _vault.strategies(_strategy);
        // Make sure its an active strategy.
        require(params.activation != 0, "!active");

        if (block.timestamp - config.lastUpdate <= minimumWait) {
            return (false, bytes("min wait"));
        }

        uint256 vaultAssets = _vault.totalAssets();

        // Get the target debt for the strategy based on vault assets.
        uint256 targetDebt = Math.min(
            (vaultAssets * config.targetRatio) / MAX_BPS,
            // Make sure it is not more than the max allowed.
            params.max_debt
        );

        // Get the max debt we would want the strategy to have.
        uint256 maxDebt = Math.min(
            (vaultAssets * config.maxRatio) / MAX_BPS,
            // Make sure it is not more than the max allowed.
            params.max_debt
        );

        // If we need to add more.
        if (targetDebt > params.current_debt) {
            uint256 currentIdle = _vault.totalIdle();
            uint256 minIdle = _vault.minimum_total_idle();

            // We can't add more than the available idle.
            if (minIdle >= currentIdle) {
                return (false, bytes("No Idle"));
            }

            // Add up to the max if possible
            uint256 toAdd = Math.min(
                maxDebt - params.current_debt,
                // Can't take more than is available.
                Math.min(
                    currentIdle - minIdle,
                    IVault(_strategy).maxDeposit(vault)
                )
            );

            // If the amount to add is over our threshold.
            if (toAdd > minimumChange) {
                // Return true and the calldata.
                return (
                    true,
                    abi.encodeWithSignature(
                        "update_debt(address,uint256)",
                        _strategy,
                        params.current_debt + toAdd
                    )
                );
            }
            // If current debt is greater than our max.
        } else if (maxDebt < params.current_debt) {
            uint256 toPull = params.current_debt - targetDebt;

            uint256 currentIdle = _vault.totalIdle();
            uint256 minIdle = _vault.minimum_total_idle();
            if (minIdle > currentIdle) {
                // Pull at least the amount needed for minIdle.
                toPull = Math.max(toPull, minIdle - currentIdle);
            }

            // Find out by how much. Aim for the target.
            toPull = Math.min(
                toPull,
                // Account for the current liquidity constraints.
                // Use max redeem to match vault logic.
                IVault(_strategy).convertToAssets(
                    IVault(_strategy).maxRedeem(address(_vault))
                )
            );

            // Check if it's over the threshold.
            if (toPull > minimumChange) {
                // Can't lower debt if there are unrealised losses.
                if (
                    _vault.assess_share_of_unrealised_losses(
                        _strategy,
                        params.current_debt
                    ) != 0
                ) {
                    return (false, bytes("unrealised loss"));
                }

                // If so return true and the calldata.
                return (
                    true,
                    abi.encodeWithSignature(
                        "update_debt(address,uint256)",
                        _strategy,
                        params.current_debt - toPull
                    )
                );
            }
        }

        // Either no change or below our minimumChange.
        return (false, bytes("Below Min"));
    }

    /**
     * @notice Increase a strategies target debt ratio.
     * @dev `setStrategyDebtRatio` functions will do all needed checks.
     * @param _strategy The address of the strategy to increase the debt ratio for.
     * @param _increase The amount in Basis Points to increase it.
     */
    function increaseStrategyDebtRatio(
        address _strategy,
        uint256 _increase
    ) external virtual {
        uint256 _currentRatio = getConfig(_strategy).targetRatio;
        setStrategyDebtRatio(_strategy, _currentRatio + _increase);
    }

    /**
     * @notice Decrease a strategies target debt ratio.
     * @param _strategy The address of the strategy to decrease the debt ratio for.
     * @param _decrease The amount in Basis Points to decrease it.
     */
    function decreaseStrategyDebtRatio(
        address _strategy,
        uint256 _decrease
    ) external virtual {
        uint256 _currentRatio = getConfig(_strategy).targetRatio;
        setStrategyDebtRatio(_strategy, _currentRatio - _decrease);
    }

    /**
     * @notice Sets a new target debt ratio for a strategy.
     * @dev This will default to a 20% increase for max debt.
     *
     * @param _strategy Address of the strategy to set.
     * @param _targetRatio Amount in Basis points to allocate.
     */
    function setStrategyDebtRatio(
        address _strategy,
        uint256 _targetRatio
    ) public virtual {
        uint256 maxRatio = Math.min((_targetRatio * 12_000) / MAX_BPS, MAX_BPS);
        setStrategyDebtRatio(_strategy, _targetRatio, maxRatio);
    }

    /**
     * @notice Sets a new target debt ratio for a strategy.
     * @dev A `minimumChange` for that strategy must be set first.
     * This is to prevent debt from being updated too frequently.
     *
     * @param _strategy Address of the strategy to set.
     * @param _targetRatio Amount in Basis points to allocate.
     * @param _maxRatio Max ratio to give on debt increases.
     */
    function setStrategyDebtRatio(
        address _strategy,
        uint256 _targetRatio,
        uint256 _maxRatio
    ) public virtual onlyManagers {
        // Make sure a minimumChange has been set.
        require(minimumChange != 0, "!minimum");
        // Cannot be more than 100%.
        require(_maxRatio <= MAX_BPS, "max too high");
        // Max cannot be lower than the target.
        require(_maxRatio >= _targetRatio, "max ratio");

        // Get the current config.
        Config memory config = getConfig(_strategy);

        // Set added flag if not set yet.
        if (!config.added) {
            config.added = true;
            emit StrategyChanged(_strategy, Status.ADDED);
        }

        // Get what will be the new total debt ratio.
        uint256 newTotalDebtRatio = totalDebtRatio -
            config.targetRatio +
            _targetRatio;

        // Make sure it is under 100% allocated
        require(newTotalDebtRatio <= MAX_BPS, "ratio too high");

        // Update local config.
        config.targetRatio = uint16(_targetRatio);
        config.maxRatio = uint16(_maxRatio);

        // Write to storage.
        _configs[_strategy] = config;
        totalDebtRatio = newTotalDebtRatio;

        emit UpdateStrategyDebtRatio(
            _strategy,
            _targetRatio,
            _maxRatio,
            newTotalDebtRatio
        );
    }

    /**
     * @notice Remove a strategy from this debt allocator.
     * @dev Will delete the full config for the strategy
     * @param _strategy Address of the address ro remove.
     */
    function removeStrategy(address _strategy) external virtual onlyManagers {
        Config memory config = getConfig(_strategy);
        require(config.added, "!added");

        uint256 target = config.targetRatio;

        // Remove any debt ratio the strategy holds.
        if (target != 0) {
            totalDebtRatio -= target;
            emit UpdateStrategyDebtRatio(_strategy, 0, 0, totalDebtRatio);
        }

        // Remove the full config including the `added` flag.
        delete _configs[_strategy];

        // Emit Event.
        emit StrategyChanged(_strategy, Status.REMOVED);
    }

    /**
     * @notice Set the minimum change variable for a strategy.
     * @dev This is the minimum amount of debt to be
     * added or pulled for it to trigger an update.
     *
     * @param _minimumChange The new minimum to set for the strategy.
     */
    function setMinimumChange(
        uint256 _minimumChange
    ) external virtual onlyGovernance {
        require(_minimumChange > 0, "zero");
        // Set the new minimum.
        minimumChange = _minimumChange;

        emit UpdateMinimumChange(_minimumChange);
    }

    /**
     * @notice Set the max loss in Basis points to allow on debt updates.
     * @dev Withdrawing during debt updates use {redeem} which allows for 100% loss.
     *      This can be used to assure a loss is not realized on redeem outside the tolerance.
     * @param _maxDebtUpdateLoss The max loss to accept on debt updates.
     */
    function setMaxDebtUpdateLoss(
        uint256 _maxDebtUpdateLoss
    ) external virtual onlyGovernance {
        require(_maxDebtUpdateLoss <= MAX_BPS, "higher than max");
        maxDebtUpdateLoss = _maxDebtUpdateLoss;

        emit UpdateMaxDebtUpdateLoss(_maxDebtUpdateLoss);
    }

    /**
     * @notice Set the minimum time to wait before re-updating a strategies debt.
     * @dev This is only enforced per strategy.
     * @param _minimumWait The minimum time in seconds to wait.
     */
    function setMinimumWait(
        uint256 _minimumWait
    ) external virtual onlyGovernance {
        minimumWait = _minimumWait;

        emit UpdateMinimumWait(_minimumWait);
    }

    /**
     * @notice Set if a manager can update ratios.
     * @param _address The address to set mapping for.
     * @param _allowed If the address can call {update_debt}.
     */
    function setManager(
        address _address,
        bool _allowed
    ) external virtual onlyGovernance {
        managers[_address] = _allowed;

        emit UpdateManager(_address, _allowed);
    }

    /**
     * @notice Get a strategies full config.
     * @dev Used for customizations by inheriting the contract.
     * @param _strategy Address of the strategy.
     * @return The strategies current Config.
     */
    function getConfig(
        address _strategy
    ) public view virtual returns (Config memory) {
        return _configs[_strategy];
    }

    /**
     * @notice Get a strategies target debt ratio.
     * @param _strategy Address of the strategy.
     * @return The strategies current targetRatio.
     */
    function getStrategyTargetRatio(
        address _strategy
    ) external view virtual returns (uint256) {
        return getConfig(_strategy).targetRatio;
    }

    /**
     * @notice Get a strategies max debt ratio.
     * @param _strategy Address of the strategy.
     * @return The strategies current maxRatio.
     */
    function getStrategyMaxRatio(
        address _strategy
    ) external view virtual returns (uint256) {
        return getConfig(_strategy).maxRatio;
    }
}

// lib/vault-periphery/contracts/debtAllocators/DebtAllocatorFactory.sol

interface IBaseFee {
    function basefee_global() external view returns (uint256);
}

/**
 * @title YearnV3  Debt Allocator Factory
 * @author yearn.finance
 * @notice
 *  Factory to deploy a debt allocator for a YearnV3 vault.
 */
contract DebtAllocatorFactory is Governance, Clonable {
    /// @notice Revert message for when a debt allocator already exists.
    error AlreadyDeployed(address _allocator);

    /// @notice An event emitted when the base fee provider is set.
    event UpdatedBaseFeeProvider(address baseFeeProvider);

    /// @notice An event emitted when a keeper is added or removed.
    event UpdateKeeper(address indexed keeper, bool allowed);

    /// @notice An event emitted when the max base fee is updated.
    event UpdateMaxAcceptableBaseFee(uint256 newMaxAcceptableBaseFee);

    /// @notice An event emitted when a new debt allocator is added or deployed.
    event NewDebtAllocator(address indexed allocator, address indexed vault);

    /// @notice Provider to read current block's base fee.
    address public baseFeeProvider;

    /// @notice Max the chains base fee can be during debt update.
    // Will default to max uint256 and need to be set to be used.
    uint256 public maxAcceptableBaseFee;

    /// @notice Mapping of addresses that are allowed to update debt.
    mapping(address => bool) public keepers;

    constructor(address _governance) Governance(_governance) {
        // Deploy a dummy allocator as the original.
        original = address(new DebtAllocator());

        // Default max base fee to uint max.
        maxAcceptableBaseFee = type(uint256).max;

        // Default to allow governance to be a keeper.
        keepers[_governance] = true;
        emit UpdateKeeper(_governance, true);
    }

    /**
     * @notice Clones a new debt allocator.
     * @dev defaults to msg.sender as the governance role and 0
     *  for the `minimumChange`.
     *
     * @param _vault The vault for the allocator to be hooked to.
     * @return Address of the new debt allocator
     */
    function newDebtAllocator(
        address _vault
    ) external virtual returns (address) {
        return newDebtAllocator(_vault, 0);
    }

    /**
     * @notice Clones a new debt allocator.
     * @param _vault The vault for the allocator to be hooked to.
     * @param _minimumChange The minimum amount needed to trigger debt update.
     * @return newAllocator Address of the new debt allocator
     */
    function newDebtAllocator(
        address _vault,
        uint256 _minimumChange
    ) public virtual returns (address newAllocator) {
        // Clone new allocator off the original.
        newAllocator = _clone();

        // Initialize the new allocator.
        DebtAllocator(newAllocator).initialize(_vault, _minimumChange);

        // Emit event.
        emit NewDebtAllocator(newAllocator, _vault);
    }

    /**
     * @notice
     *  Used to set our baseFeeProvider, which checks the network's current base
     *  fee price to determine whether it is an optimal time to harvest or tend.
     *
     *  This may only be called by governance.
     * @param _baseFeeProvider Address of our baseFeeProvider
     */
    function setBaseFeeOracle(
        address _baseFeeProvider
    ) external virtual onlyGovernance {
        baseFeeProvider = _baseFeeProvider;

        emit UpdatedBaseFeeProvider(_baseFeeProvider);
    }

    /**
     * @notice Set the max acceptable base fee.
     * @dev This defaults to max uint256 and will need to
     * be set for it to be used.
     *
     * Is denominated in gwei. So 50gwei would be set as 50e9.
     *
     * @param _maxAcceptableBaseFee The new max base fee.
     */
    function setMaxAcceptableBaseFee(
        uint256 _maxAcceptableBaseFee
    ) external virtual onlyGovernance {
        maxAcceptableBaseFee = _maxAcceptableBaseFee;

        emit UpdateMaxAcceptableBaseFee(_maxAcceptableBaseFee);
    }

    /**
     * @notice Set if a keeper can update debt.
     * @param _address The address to set mapping for.
     * @param _allowed If the address can call {update_debt}.
     */
    function setKeeper(
        address _address,
        bool _allowed
    ) external virtual onlyGovernance {
        keepers[_address] = _allowed;

        emit UpdateKeeper(_address, _allowed);
    }

    /**
     * @notice Returns wether or not the current base fee is acceptable
     *   based on the `maxAcceptableBaseFee`.
     * @return . If the current base fee is acceptable.
     */
    function isCurrentBaseFeeAcceptable() external view virtual returns (bool) {
        address _baseFeeProvider = baseFeeProvider;
        if (_baseFeeProvider == address(0)) return true;
        return
            maxAcceptableBaseFee >= IBaseFee(_baseFeeProvider).basefee_global();
    }
}

// src/RoleManager.sol

/// @title Yearn Stake the Bridge Role Manager.
contract RoleManager is Positions {
    /// @notice Revert message for when a contract has already been deployed.
    error AlreadyDeployed(address _contract);

    /// @notice Emitted when a new vault has been deployed or added.
    event AddedNewVault(
        address indexed vault,
        address indexed debtAllocator,
        uint32 rollupID
    );

    /// @notice Emitted when a vaults debt allocator is updated.
    event UpdateDebtAllocator(
        address indexed vault,
        address indexed debtAllocator
    );

    /// @notice Emitted when a vault is removed.
    event RemovedVault(address indexed vault);

    /// @notice Emitted when the defaultProfitMaxUnlock variable is updated.
    event UpdateDefaultProfitMaxUnlock(uint256 newDefaultProfitMaxUnlock);

    /// @notice Config that holds all vault info.
    struct VaultConfig {
        address asset;
        uint32 rollupID; // 0 == default.
        address debtAllocator;
        uint96 index;
    }

    /// @notice Make sure the vault has been added to the role manager.
    modifier vaultIsAdded(address _vault) {
        _vaultIsAdded(_vault);
        _;
    }

    /// @notice Check if the vault is added to the Role Manager.
    function _vaultIsAdded(address _vault) internal view virtual {
        require(vaultConfig[_vault].asset != address(0), "vault not added");
    }

    /// @notice ID to use for the L1
    uint32 internal constant ORIGIN_NETWORK_ID = 0;

    /*//////////////////////////////////////////////////////////////
                           POSITION ID'S
    //////////////////////////////////////////////////////////////*/

    /// @notice Position ID for "Czar".
    bytes32 public constant CZAR = keccak256("Czar");
    /// @notice Position ID for "Keeper".
    bytes32 public constant KEEPER = keccak256("Keeper");
    /// @notice Position ID for "Management".
    bytes32 public constant MANAGEMENT = keccak256("Management");
    /// @notice Position ID for "Governator".
    bytes32 public constant GOVERNATOR = keccak256("Governator");
    /// @notice Position ID for "Emergency Admin".
    bytes32 public constant EMERGENCY_ADMIN = keccak256("Emergency Admin");
    /// @notice Position ID for "Pending Governator".
    bytes32 public constant PENDING_GOVERNATOR =
        keccak256("Pending Governator");

    /// @notice Position ID for the Registry.
    bytes32 public constant REGISTRY = keccak256("Registry");
    /// @notice Position ID for the Accountant.
    bytes32 public constant ACCOUNTANT = keccak256("Accountant");
    /// @notice Position ID for Debt Allocator
    bytes32 public constant DEBT_ALLOCATOR = keccak256("Debt Allocator");
    /// @notice Position ID for the Allocator Factory.
    bytes32 public constant ALLOCATOR_FACTORY = keccak256("Allocator Factory");

    /// @notice Immutable address that the RoleManager position
    // will be transferred to when a vault is removed.
    address public immutable chad;

    /*//////////////////////////////////////////////////////////////
                           STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice Array storing addresses of all managed vaults.
    address[] public vaults;

    /// @notice Default time until profits are fully unlocked for new vaults.
    uint256 public defaultProfitMaxUnlock = 10 days;

    /// @notice Mapping of vault addresses to its config.
    mapping(address => VaultConfig) public vaultConfig;

    /// @notice Mapping of underlying asset => rollupID => vault address.
    /// NOTE: We use 0 for the default vaults since that should never be an L2 ID.
    mapping(address => mapping(uint32 => address)) internal _assetToVault;

    constructor(
        address _governator,
        address _czar,
        address _management,
        address _emergencyAdmin,
        address _keeper,
        address _registry,
        address _allocatorFactory
    ) {
        chad = _governator;

        // Governator gets no roles.
        _setPositionHolder(GOVERNATOR, _governator);

        // Czar gets all of the Roles.
        _setPositionHolder(CZAR, _czar);
        _setPositionRoles(CZAR, Roles.ALL);

        // Management reports, can update debt, queue, deposit limits and unlock time.
        _setPositionHolder(MANAGEMENT, _management);
        _setPositionRoles(
            MANAGEMENT,
            Roles.REPORTING_MANAGER |
                Roles.DEBT_MANAGER |
                Roles.QUEUE_MANAGER |
                Roles.DEPOSIT_LIMIT_MANAGER |
                Roles.DEBT_PURCHASER |
                Roles.PROFIT_UNLOCK_MANAGER
        );

        // Emergency Admin can set the max debt for strategies to have.
        _setPositionHolder(EMERGENCY_ADMIN, _emergencyAdmin);
        _setPositionRoles(EMERGENCY_ADMIN, Roles.EMERGENCY_MANAGER);

        // The keeper can process reports.
        _setPositionHolder(KEEPER, _keeper);
        _setPositionRoles(KEEPER, Roles.REPORTING_MANAGER);

        // Debt allocators manage debt and also need to process reports.
        _setPositionRoles(
            DEBT_ALLOCATOR,
            Roles.REPORTING_MANAGER | Roles.DEBT_MANAGER
        );

        _setPositionHolder(REGISTRY, _registry);
        _setPositionHolder(ALLOCATOR_FACTORY, _allocatorFactory);
    }

    /*//////////////////////////////////////////////////////////////
                           VAULT CREATION
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Deploys a new vault to the RoleManager for the default version.
     * @dev This will override any existing default vault to use a new API version.
     * @param _asset Address of the asset to be used.
     * @return _vault Address of the new vault
     */
    function newDefaultVault(
        address _asset
    ) external virtual onlyPositionHolder(GOVERNATOR) returns (address _vault) {
        _vault = _newVault(ORIGIN_NETWORK_ID, _asset);
    }

    /**
     * @notice Permissionless creation of a new endorsed vault.
     * @param _rollupID Id of the rollup to deploy for.
     * @param _asset Address of the underlying asset.
     * @return _vault Address of the newly created vault.
     */
    function newVault(
        uint32 _rollupID,
        address _asset
    ) external virtual returns (address _vault) {
        _vault = getVault(_asset, _rollupID);
        if (_vault != address(0)) revert AlreadyDeployed(_vault);
        _vault = _newVault(_rollupID, _asset);
    }

    /**
     * @notice Creates a new endorsed vault.
     * @param _rollupID Id of the rollup to deploy for.
     * @param _asset Address of the underlying asset.
     * @return _vault Address of the newly created vault.
     */
    function _newVault(
        uint32 _rollupID,
        address _asset
    ) internal virtual returns (address _vault) {
        // Append the rollup ID for the name and symbol of custom vaults.
        string memory _id = _rollupID == ORIGIN_NETWORK_ID
            ? ""
            : string.concat("-", Strings.toString(_rollupID));

        // Name is "{SYMBOL}-STB yVault"
        string memory _name = string.concat(
            ERC20(_asset).symbol(),
            "-STB",
            _id,
            " yVault"
        );

        // Symbol is "stb{SYMBOL}".
        string memory _symbol = string.concat(
            "stb",
            ERC20(_asset).symbol(),
            _id
        );

        // Deploy through the registry so it is automatically endorsed.
        _vault = Registry(getPositionHolder(REGISTRY)).newEndorsedVault(
            _asset,
            _name,
            _symbol,
            address(this),
            defaultProfitMaxUnlock
        );

        // Deploy a new debt allocator for the vault.
        address _debtAllocator = _deployAllocator(_vault);

        // Give out roles on the new vault.
        _sanctify(_vault, _debtAllocator);

        // Set up the accountant.
        _setAccountant(_vault);

        // Set deposit limit to max uint.
        _setDepositLimit(_vault, 2 ** 256 - 1);

        // Add the vault config to the mapping.
        vaultConfig[_vault] = VaultConfig({
            asset: _asset,
            rollupID: _rollupID,
            debtAllocator: _debtAllocator,
            index: uint96(vaults.length)
        });

        // Add the vault to the mapping.
        _assetToVault[_asset][_rollupID] = _vault;

        // Add the vault to the array.
        vaults.push(_vault);

        // Emit event for new vault.
        emit AddedNewVault(_vault, _debtAllocator, _rollupID);
    }

    /**
     * @dev Deploys a debt allocator for the specified vault.
     * @param _vault Address of the vault.
     * @return _debtAllocator Address of the deployed debt allocator.
     */
    function _deployAllocator(
        address _vault
    ) internal virtual returns (address _debtAllocator) {
        address factory = getPositionHolder(ALLOCATOR_FACTORY);

        // If we have a factory set.
        if (factory != address(0)) {
            // Deploy a new debt allocator for the vault with Management as the gov.
            _debtAllocator = DebtAllocatorFactory(factory).newDebtAllocator(
                _vault
            );
        } else {
            // If no factory is set we should be using one central allocator.
            _debtAllocator = getPositionHolder(DEBT_ALLOCATOR);
        }
    }

    /**
     * @dev Assigns roles to the newly added vault.
     *
     * This will override any previously set roles for the holders. But not effect
     * the roles held by other addresses.
     *
     * @param _vault Address of the vault to sanctify.
     * @param _debtAllocator Address of the debt allocator for the vault.
     */
    function _sanctify(
        address _vault,
        address _debtAllocator
    ) internal virtual {
        // Set the roles for the Czar.
        _setRole(_vault, _positions[CZAR]);

        // Set the roles for Management.
        _setRole(_vault, _positions[MANAGEMENT]);

        // Set the roles for EMERGENCY_ADMIN.
        _setRole(_vault, _positions[EMERGENCY_ADMIN]);

        // Set the roles for the Keeper.
        _setRole(_vault, _positions[KEEPER]);

        // Give the specific debt allocator its roles.
        _setRole(
            _vault,
            Position(_debtAllocator, _positions[DEBT_ALLOCATOR].roles)
        );
    }

    /**
     * @dev Used internally to set the roles on a vault for a given position.
     *   Will not set the roles if the position holder is address(0).
     *   This does not check that the roles are !=0 because it is expected that
     *   the holder will be set to 0 if the position is not being used.
     *
     * @param _vault Address of the vault.
     * @param _position Holder address and roles to set.
     */
    function _setRole(
        address _vault,
        Position memory _position
    ) internal virtual {
        if (_position.holder != address(0)) {
            IVault(_vault).set_role(_position.holder, uint256(_position.roles));
        }
    }

    /**
     * @dev Sets the accountant on the vault and adds the vault to the accountant.
     *   This temporarily gives the `ACCOUNTANT_MANAGER` role to this contract.
     * @param _vault Address of the vault to set up the accountant for.
     */
    function _setAccountant(address _vault) internal virtual {
        // Get the current accountant.
        address accountant = getPositionHolder(ACCOUNTANT);

        // If there is an accountant set.
        if (accountant != address(0)) {
            // Temporarily give this contract the ability to set the accountant.
            IVault(_vault).add_role(address(this), Roles.ACCOUNTANT_MANAGER);

            // Set the account on the vault.
            IVault(_vault).set_accountant(accountant);

            // Take away the role.
            IVault(_vault).remove_role(address(this), Roles.ACCOUNTANT_MANAGER);

            // Whitelist the vault in the accountant.
            IAccountant(accountant).addVault(_vault);
        }
    }

    /**
     * @dev Used to set an initial deposit limit when a new vault is deployed.
     *   Any further updates to the limit will need to be done by an address that
     *   holds the `DEPOSIT_LIMIT_MANAGER` role.
     * @param _vault Address of the newly deployed vault.
     * @param _depositLimit The deposit limit to set.
     */
    function _setDepositLimit(
        address _vault,
        uint256 _depositLimit
    ) internal virtual {
        // Temporarily give this contract the ability to set the deposit limit.
        IVault(_vault).add_role(address(this), Roles.DEPOSIT_LIMIT_MANAGER);

        // Set the initial deposit limit on the vault.
        IVault(_vault).set_deposit_limit(_depositLimit);

        // Take away the role.
        IVault(_vault).remove_role(address(this), Roles.DEPOSIT_LIMIT_MANAGER);
    }

    /*//////////////////////////////////////////////////////////////
                            VAULT MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Update a `_vault`s debt allocator.
     * @dev This will deploy a new allocator using the current
     *   allocator factory set.
     * @param _vault Address of the vault to update the allocator for.
     */
    function updateDebtAllocator(
        address _vault
    ) external virtual returns (address _newDebtAllocator) {
        _newDebtAllocator = _deployAllocator(_vault);
        updateDebtAllocator(_vault, _newDebtAllocator);
    }

    /**
     * @notice Update a `_vault`s debt allocator to a specified `_debtAllocator`.
     * @param _vault Address of the vault to update the allocator for.
     * @param _debtAllocator Address of the new debt allocator.
     */
    function updateDebtAllocator(
        address _vault,
        address _debtAllocator
    ) public virtual vaultIsAdded(_vault) onlyPositionHolder(MANAGEMENT) {
        // Remove the roles from the old allocator.
        _setRole(_vault, Position(vaultConfig[_vault].debtAllocator, 0));

        // Give the new debt allocator the relevant roles.
        _setRole(
            _vault,
            Position(_debtAllocator, _positions[DEBT_ALLOCATOR].roles)
        );

        // Update the vaults config.
        vaultConfig[_vault].debtAllocator = _debtAllocator;

        // Emit event.
        emit UpdateDebtAllocator(_vault, _debtAllocator);
    }

    /**
     * @notice Update a `_vault`s keeper to a specified `_keeper`.
     * @param _vault Address of the vault to update the keeper for.
     * @param _keeper Address of the new keeper.
     */
    function updateKeeper(
        address _vault,
        address _keeper
    ) external virtual vaultIsAdded(_vault) onlyPositionHolder(MANAGEMENT) {
        // Remove the roles from the old keeper if active.
        address defaultKeeper = getPositionHolder(KEEPER);
        if (
            _keeper != defaultKeeper && IVault(_vault).roles(defaultKeeper) != 0
        ) {
            _setRole(_vault, Position(defaultKeeper, 0));
        }

        // Give the new keeper the relevant roles.
        _setRole(_vault, Position(_keeper, _positions[KEEPER].roles));
    }

    /**
     * @notice Removes a vault from the RoleManager.
     * @dev This will NOT un-endorse the vault from the registry.
     * @param _vault Address of the vault to be removed.
     */
    function removeVault(
        address _vault
    ) external virtual vaultIsAdded(_vault) onlyPositionHolder(CZAR) {
        // Transfer the role manager position.
        IVault(_vault).transfer_role_manager(chad);

        // Address of the vault to replace it with.
        address vaultToMove = vaults[vaults.length - 1];

        // Get the vault specific config.
        VaultConfig memory config = vaultConfig[_vault];

        // Move the last vault to the index of `_vault`
        vaults[config.index] = vaultToMove;
        vaultConfig[vaultToMove].index = config.index;

        // Remove the last item.
        vaults.pop();

        // Delete the vault from the mapping.
        delete _assetToVault[config.asset][config.rollupID];

        // Delete the config for `_vault`.
        delete vaultConfig[_vault];

        emit RemovedVault(_vault);
    }

    /**
     * @notice Removes a specific role(s) for a `_holder` from the `_vaults`.
     * @dev Can be used to remove one specific role or multiple.
     * @param _vaults Array of vaults to adjust.
     * @param _holder Address who's having a role removed.
     * @param _role The role or roles to remove from the `_holder`.
     */
    function removeRoles(
        address[] calldata _vaults,
        address _holder,
        uint256 _role
    ) external virtual onlyPositionHolder(CZAR) {
        address _vault;
        for (uint256 i; i < _vaults.length; ++i) {
            _vault = _vaults[i];
            // Make sure the vault is added to this Role Manager.
            require(vaultConfig[_vault].asset != address(0), "vault not added");

            // Remove the role.
            IVault(_vault).remove_role(_holder, _role);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            SETTERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Setter function for updating a positions roles.
     * @param _position Identifier for the position.
     * @param _newRoles New roles for the position.
     */
    function setPositionRoles(
        bytes32 _position,
        uint256 _newRoles
    ) external virtual onlyPositionHolder(GOVERNATOR) {
        // Cannot change the debt allocator or keeper roles since holder can be updated.
        require(
            _position != DEBT_ALLOCATOR && _position != KEEPER,
            "cannot update"
        );
        _setPositionRoles(_position, _newRoles);
    }

    /**
     * @notice Setter function for updating a positions holder.
     * @dev Updating `Governator` requires setting `PENDING_GOVERNATOR`
     *  and then the pending address calling {acceptGovernator}.
     * @param _position Identifier for the position.
     * @param _newHolder New address for position.
     */
    function setPositionHolder(
        bytes32 _position,
        address _newHolder
    ) external virtual onlyPositionHolder(GOVERNATOR) {
        require(_position != GOVERNATOR, "!two step flow");
        _setPositionHolder(_position, _newHolder);
    }

    /**
     * @notice Sets the default time until profits are fully unlocked for new vaults.
     * @param _newDefaultProfitMaxUnlock New value for defaultProfitMaxUnlock.
     */
    function setDefaultProfitMaxUnlock(
        uint256 _newDefaultProfitMaxUnlock
    ) external virtual onlyPositionHolder(GOVERNATOR) {
        require(_newDefaultProfitMaxUnlock != 0, "too short");
        require(_newDefaultProfitMaxUnlock <= 31_556_952, "too long");
        defaultProfitMaxUnlock = _newDefaultProfitMaxUnlock;

        emit UpdateDefaultProfitMaxUnlock(_newDefaultProfitMaxUnlock);
    }

    /**
     * @notice Accept the Governator role.
     * @dev Caller must be the Pending Governator.
     */
    function acceptGovernator()
        external
        virtual
        onlyPositionHolder(PENDING_GOVERNATOR)
    {
        // Set the Governator role to the caller.
        _setPositionHolder(GOVERNATOR, msg.sender);
        // Reset the Pending Governator.
        _setPositionHolder(PENDING_GOVERNATOR, address(0));
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW METHODS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Get the name of this contract.
     */
    function name() external view virtual returns (string memory) {
        return string(abi.encodePacked("Stake the Bridge Role Manager"));
    }

    /**
     * @notice Get all vaults that this role manager controls..
     * @return The full array of vault addresses.
     */
    function getAllVaults() external view virtual returns (address[] memory) {
        return vaults;
    }

    /**
     * @notice Get the default vault for a specific asset.
     * @dev This will return address(0) if one has not been added or deployed.
     * @param _asset The underlying asset used.
     * @return The default vault for the specified `_asset`.
     */
    function getVault(address _asset) external view virtual returns (address) {
        return getVault(_asset, ORIGIN_NETWORK_ID);
    }

    /**
     * @notice Get the vault for a specific asset and chain ID.
     * @dev This will return address(0) if one has not been added or deployed.
     *      A `_rollupID` of 0 will return the default vault.
     * @param _asset The underlying asset used.
     * @param _rollupID The rollup chain ID or 0 for the default version.
     * @return The vault for the specified `_asset` and `_rollupID`.
     */
    function getVault(
        address _asset,
        uint32 _rollupID
    ) public view virtual returns (address) {
        return _assetToVault[_asset][_rollupID];
    }

    /**
     * @notice Check if a vault is managed by this contract.
     * @dev This will check if the `asset` variable in the struct has been
     *   set for an easy external view check.
     *
     *   Does not check the vaults `role_manager` position since that can be set
     *   by anyone for a random vault.
     *
     * @param _vault Address of the vault to check.
     * @return . The vaults role manager status.
     */
    function isVaultsRoleManager(
        address _vault
    ) external view virtual returns (bool) {
        return vaultConfig[_vault].asset != address(0);
    }

    /**
     * @notice Get the debt allocator for a specific vault.
     * @dev Will return address(0) if the vault is not managed by this contract.
     * @param _vault Address of the vault.
     * @return . Address of the debt allocator if any.
     */
    function getDebtAllocator(
        address _vault
    ) external view virtual returns (address) {
        return vaultConfig[_vault].debtAllocator;
    }
}
