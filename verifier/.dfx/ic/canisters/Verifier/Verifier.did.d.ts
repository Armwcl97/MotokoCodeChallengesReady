import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type Result = { 'ok' : boolean } |
  { 'err' : string };
export type Result_1 = { 'ok' : null } |
  { 'err' : string };
export type Result_2 = { 'ok' : StudentProfile } |
  { 'err' : string };
export interface StudentProfile {
  'graduate' : boolean,
  'name' : string,
  'team' : string,
}
export type TestError = { 'UnexpectedValue' : string } |
  { 'UnexpectedError' : string };
export type TestResult = { 'ok' : null } |
  { 'err' : TestError };
export interface Verifier {
  'addMyProfile' : ActorMethod<[StudentProfile], Result_1>,
  'deleteMyProfile' : ActorMethod<[], Result_1>,
  'seeAProfile' : ActorMethod<[Principal], Result_2>,
  'test' : ActorMethod<[Principal], TestResult>,
  'updateMyProfile' : ActorMethod<[StudentProfile], Result_1>,
  'verifyOwnership' : ActorMethod<[Principal, Principal], boolean>,
  'verifyWork' : ActorMethod<[Principal, Principal], Result>,
}
export interface _SERVICE extends Verifier {}
