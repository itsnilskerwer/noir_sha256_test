use sha2::{Sha256, Digest};
use std::fs::OpenOptions;
use std::io::Write;
use std::path::Path;

fn main() -> std::io::Result<()> {
    // Define secret
    let password: [u8; 32] = [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
        11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 
        21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 
        31, 32
    ];

    // Calculate hash with incremental api (crate sha2)

    // create a Sha256 object
    let mut hasher = Sha256::new();

    // write input message
    hasher.update(&password);

    // read hash digest and consume hasher
    let result = hasher.finalize();

    let path = Path::new("../Prover.toml");

    // Crate or overwrite toml file
    let mut file = OpenOptions::new()
        .write(true)
        .create(true)
        .truncate(true) // overwrite, if it exists.
        .open(path)?;

    // Format and write toml    
    writeln!(file, "password = {:?}", password)?; // {:?} formats arrays as [1, 2, 3], which Noir accepts for [u8; 32] inputs
    writeln!(file, "passwordHash = {:?}", result.as_slice())?; // // Converts generic array to slice

    println!("✅ Successfully updated Prover.toml");
    Ok(())
}
