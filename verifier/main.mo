import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import IC "Ic";

import Type "Types";
import Calculator "Calculator";

actor class Verifier() {
  type StudentProfile = Type.StudentProfile;

  stable var students : [(Principal, StudentProfile)] = [];
  var studentsProfileStore = HashMap.fromIter<Principal, StudentProfile>(students.vals(), 0, Principal.equal, Principal.hash);

  // STEP 1 - BEGIN
  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {

    switch (Principal.isAnonymous(caller)) {
      case (false) {
        return #err("Your user is anonymous. You aren't allowed to create a profile here.");
      };
      case (true) {
        studentsProfileStore.put(caller, profile);
        return #ok;
      };
    };

  };

  public shared ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    switch (studentsProfileStore.get(p)) {
      case (null) {
        return #err("Invalid principal key. Check your spelling.");
      };
      case (?ok) {
        return #ok(ok);
      };
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    switch (studentsProfileStore.get(caller)) {
      case (null) {
        return #err("Didn't find such profile.");
      };
      case (?ok) {
        let updatedProfile : StudentProfile = {
          name = ok.name;
          team = ok.team;
          graduate = ok.graduate;
        };
        studentsProfileStore.put(caller, profile);
        return #ok;
      };
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    switch (studentsProfileStore.remove(caller)) {
      case (null) {
        return #err("Didn't find such profile.");
      };
      case (?ok) {
        return #ok;
      };
    };
  };
  // STEP 1 - END

  // STEP 2 - BEGIN
  public type CalculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;
  public type TestError = Type.TestError;

  public func test(canisterId : Principal) : async TestResult {
    let calculatorActor = await Calculator.Calculator();
    try {
      let result1 = await calculatorActor.add(1);
      if (result1 != 1) {
        return #err(#UnexpectedValue("Expected 1, got " # Int.toText(result1)));
      };
      let result2 = await calculatorActor.add(2);
      if (result2 != 3) {
        return #err(#UnexpectedValue("Expected 3, got " # Int.toText(result2)));
      };
      return #ok();
    } catch (error : Error) {
      return #err(#UnexpectedError(Error.message(error)));
    };
  };

  // STEP - 2 END

  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally

  private func _parseControllers(errorMessage : Text) : [Principal] {
    let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
    let words = Iter.toArray(Text.split(lines[1], #text(" ")));
    var i = 2;
    let controllers = Buffer.Buffer<Principal>(0);
    while (i < words.size()) {
      controllers.add(Principal.fromText(words[i]));
      i += 1;
    };
    Buffer.toArray<Principal>(controllers);
  };

  public type CanisterId = IC.CanisterId;
  public type CanisterSettings = IC.CanisterSettings;
  public type CanisterManager = IC.ManagementCanisterInterface;

  public func verifyOwnership(canisterId : Principal, p : Principal) : async Bool {
    let manager : CanisterManager = actor ("aaaaa-aa");
    try {
      let temp = await manager.canister_status({ canister_id = canisterId });
      let controllers = temp.settings.controllers;
      return true;
    } catch (error) {
      let messageError = Error.message(error);
      let controllers = _parseControllers(messageError);
      // let controllersInText = Array.map<Principal , Text>(controllers, func x = Principal.toText( x ));
      switch (Array.find<Principal>(controllers, func x = p == x)) {
        case (null) {
          return false;
        };
        case (?_) {
          return true;
        };
      };
    };
  };
  // STEP 3 - END

  // STEP 4 - BEGIN
  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<Bool, Text> {

    let testMo = await test(canisterId : Principal);
    let verifyOwner = await verifyOwnership(canisterId : Principal, p : Principal);

    switch (verifyOwner) {
      case (false) {
        return #err "You aren't the real owner";
      };
      case (true) {
        switch (testMo) {
          case (#err(#UnexpectedError(text))) {
            return #err("Test didnt go as expected.");
          };
          case (#err(#UnexpectedValue(text))) {
            return #err("Test didnt go as expected.");
          };
          case (#ok) {

            let studentsProfileGet = studentsProfileStore.get(p);

            switch (studentsProfileGet) {
              case (null) {
                return #err("Test didnt go as expected.");
              };
              case (?ok) {
                let graduateUser : StudentProfile = {
                  name = ok.name;
                  team = ok.team;
                  graduate = true;
                };

                studentsProfileStore.put(p, graduateUser);
              };
            };
            return #ok(true);
          };
        };
      };
    };
  };
  // STEP 4 - END

  system func preupgrade() {
    students := Iter.toArray(studentsProfileStore.entries());
  };

  system func postupgrade() {
    students := [];
  };
};
