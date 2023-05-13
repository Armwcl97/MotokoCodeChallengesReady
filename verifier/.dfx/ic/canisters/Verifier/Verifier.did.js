export const idlFactory = ({ IDL }) => {
  const StudentProfile = IDL.Record({
    'graduate' : IDL.Bool,
    'name' : IDL.Text,
    'team' : IDL.Text,
  });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Result_2 = IDL.Variant({ 'ok' : StudentProfile, 'err' : IDL.Text });
  const TestError = IDL.Variant({
    'UnexpectedValue' : IDL.Text,
    'UnexpectedError' : IDL.Text,
  });
  const TestResult = IDL.Variant({ 'ok' : IDL.Null, 'err' : TestError });
  const Result = IDL.Variant({ 'ok' : IDL.Bool, 'err' : IDL.Text });
  const Verifier = IDL.Service({
    'addMyProfile' : IDL.Func([StudentProfile], [Result_1], []),
    'deleteMyProfile' : IDL.Func([], [Result_1], []),
    'seeAProfile' : IDL.Func([IDL.Principal], [Result_2], []),
    'test' : IDL.Func([IDL.Principal], [TestResult], []),
    'updateMyProfile' : IDL.Func([StudentProfile], [Result_1], []),
    'verifyOwnership' : IDL.Func(
        [IDL.Principal, IDL.Principal],
        [IDL.Bool],
        [],
      ),
    'verifyWork' : IDL.Func([IDL.Principal, IDL.Principal], [Result], []),
  });
  return Verifier;
};
export const init = ({ IDL }) => { return []; };
