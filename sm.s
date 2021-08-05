.intel_syntax noprefix

/* My macros for making function calling easier on the mind. */
.include "std.macro"

/* Macros for making state machines. */
.include "sm.macro"

GREEN   = 2
YELLOW  = 1
RED     = 0

MachineDefinition TrafficLights
  State GREEN,  YELLOW
  State YELLOW, RED
  State RED,    GREEN
  MachineDefinitionEnd

MachineIgnition TrafficLights GREEN
  Tick 3
  Halt

/* Translates to: */

sm_TrafficLights: push esp
  cmp state, GREEN;  cmove state, YELLOW; je sm_end_TrafficLights
  cmp state, YELLOW; cmove state, RED;    je sm_end_TrafficLights;
  cmp state, RED;    cmove state, GREEN;  je sm_end_TrafficLights;
  mov state, INVALID
sm_end_TrafficLights:
  pop esp; ret

.global main
xcode = rdi
main:
  mov state, GREEN
  λ   sm_TrafficLights, state
  λ   sm_TrafficLights, state
  λ   sm_TrafficLights, state
  cmp state, INVALID; cmove xcode, 1; cmovne xcode, 0
  λ   exit, xcode
