use sha256;

fn main(password: [u8; 32], passwordHash: pub [u8; 32]) {
    assert(sha256::digest(password) == passwordHash);
}

#[test]
fn test_main() {
    let password: [u8; 32] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32];
    let passwordHash: [u8; 32] = sha256::sha256_var(password, 32);

    std::println(passwordHash);
    
    main(password, passwordHash);

// --- code below --- is actually redundant. assertion happens inside main(), and if it returns successfully, we know the assertion holds
    let computed_hash = sha256::sha256_var(password, 32);
    assert(computed_hash == passwordHash);
}