
#[test_only]
module gameobject::gameobject_tests;
// uncomment this line to import the module
// use gameobject::gameobject;

use sui::test_utils::assert_eq;

#[error]
const ENotImplemented: vector<u8> = b"not implemented";

#[error]
const ENotValid: vector<u8> = b"not okay";

#[test]
fun test_gameobject() {
    // pass
    assert!(5 > 4, ENotValid);
    assert_eq(5, 5);
}

#[test, expected_failure(abort_code = ::gameobject::gameobject_tests::ENotImplemented)]
fun test_gameobject_fail() {
    abort ENotImplemented
}
