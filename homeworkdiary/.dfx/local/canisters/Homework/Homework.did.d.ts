import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Homework {
  'addHomework' : ActorMethod<[Homework__1], bigint>,
  'deleteHomework' : ActorMethod<[bigint], Result>,
  'getAllHomework' : ActorMethod<[], Array<Homework__1>>,
  'getHomework' : ActorMethod<[bigint], Result_1>,
  'getPendingHomework' : ActorMethod<[], Array<Homework__1>>,
  'markAsCompleted' : ActorMethod<[bigint], Result>,
  'searchHomework' : ActorMethod<[string], Array<Homework__1>>,
  'updateHomework' : ActorMethod<[bigint, Homework__1], Result>,
}
export interface Homework__1 {
  'title' : string,
  'dueDate' : Time,
  'description' : string,
  'complete' : boolean,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result_1 = { 'ok' : Homework__1 } |
  { 'err' : string };
export type Time = bigint;
export interface _SERVICE extends Homework {}