.intel_syntax noprefix

.include "list.macro"

.section .data
format_energy: .asciz "%.9f\n"
format_3f: .asciz "%f %f %f\n"

.align 16
initial_advance_value: .double 0.01, 0.01

.align 16
one: .double 1.0, 1.0
two: .double 2.0, 2.0

body_size     = (8 * 10)
bodies_length = 5
.align 16
bodies_data: /*
  x     y,    z,  padding,
  vx,   vy,   vz, padding,
  mass, mass2
*/
sun:
.double  2.0,       3.0,     4.0, 0.0
.double  2.0,       3.0,     4.0, 0.0
.double 39.478418, 39.478418

jupiter:
.double 4.841431, -1.160320, -0.103622, 0.0
.double 0.606326,  2.811987, -0.025218, 0.0
.double 0.037694,  0.037694

saturn:
.double 8.343367,  4.124799, -0.403523, 0.0
.double -1.010774, 1.825662,  0.008416, 0.0
.double  0.011286, 0.011286

uranus:
.double 12.894370, -15.111151, -0.223308, 0.0
.double  1.082791,   0.868713, -0.010833, 0.0
.double  0.001724,   0.001724

neptune:
.double 15.379697, -25.919315,  0.179259, 0.0
.double  0.979091,   0.594699, -0.034756, 0.0
.double  0.002034,   0.002034

pairs_data:
permutations sun, jupiter, saturn, uranus, neptune

.section .text
.global main
main: sub rsp, 8
  call   offset_momentum
  call   report_energy
  movapd xmm5, [initial_advance_value]
  mov    r8, 5000000
  call   advance
  call   report_energy
  mov rdi, 0; call exit
  add rsp, 8; ret

report_neptune:
  mov rdi, offset format_3f
  movlpd xmm0, [neptune]
  movlpd xmm1, [neptune + (8 * 1)]
  movlpd xmm2, [neptune + (8 * 2)]
  mov al, 3
  sub rsp, 8
  call printf
  add rsp, 8
  ret

offset_momentum: /* () -> () */
  i = rcx
  bodies = rdi

  mov bodies, offset bodies_data
  mov i, bodies_length
1:
  movapd xmm8,  [bodies + (8 * 4)]
  movapd xmm9,  [bodies + (8 * 8)]
  mulpd  xmm8,  xmm9
  divpd  xmm8,  [sun + (8 * 8)]
  movapd xmm11, [bodies + (8 * 6)]
  mulpd  xmm11, xmm9
  divpd  xmm11, [sun + (8 * 8)]

  movapd xmm12, [sun + (8 * 4)]
  subpd  xmm12, xmm8 
  movapd [sun + (8 * 4)], xmm12
  movapd xmm13, [sun + (8 * 6)]
  subpd  xmm13, xmm11
  movapd [sun + (8 * 6)], xmm13

  add bodies, body_size

  dec rcx
  jne 1b

  ret

report_energy: /* () -> () */
  pairs = rdi; pairs_index = rcx
  _1 = rsi; _2 = rdx

  x1y1 = xmm15; z101 = xmm14
  x2y2 = xmm13; z202 = xmm12
  m1m1 = xmm11; m2m2 = xmm10
  z0ee = xmm9;

  mov pairs, offset pairs_data
  mov pairs_index, 10

.align 16
1:
  mov _1, [pairs]
  mov _2, [pairs + (8 * 1)]
  movapd x1y1, [_1]
  movapd z101, [_1 + (8 * 2)]
  movapd x2y2, [_2]
  movapd z202, [_2 + (8 * 2)]
  subpd  x1y1, x2y2
  subpd  z101, z202

  movapd m1m1, [_1 + (8 * 8)]
  movapd m2m2, [_2 + (8 * 8)]
  mulpd  m1m1, m2m2

  mulpd  x1y1, x1y1
  mulpd  z101, z101
  haddpd x1y1, z101
  haddpd x1y1, x1y1
  
  sqrtpd x1y1, x1y1
  divpd  m1m1, x1y1
  subpd  z0ee, m1m1

  add pairs, (8 * 2)
  sub pairs_index, 1
  jnz 1b

  bodies = rdi; bodies_length = rcx
  vxvy = xmm15; vzv0 = xmm14
  mmmm = xmm13;

  mov bodies, offset bodies_data
  mov bodies_length, 5

.align 16
1:
  movapd vxvy, [bodies + (8 * 4)]
  movapd vzv0, [bodies + (8 * 6)]
  movapd mmmm, [bodies + (8 * 8)]
  mulpd  vxvy, vxvy
  mulpd  vzv0, vzv0
  haddpd vxvy, vzv0
  haddpd vxvy, vxvy
  divpd  vxvy, [two]
  mulpd  vxvy, mmmm
  addpd  z0ee, vxvy

  add bodies, (8 * 10)
  loop 1b

  mov rdi, offset format_energy
  movapd xmm0, z0ee
  mov al, 1
  sub rsp, 8
  call printf
  add rsp, 8

  ret

advance: /* dt: double, n: integer -> () */
  dt = xmm5; n = r8
  dto = xmm6

  pairs = rdi; pairs_index = rcx
  _1 = rsi; _2 = rdx

  x1y1 = xmm15; z101 = xmm14
  x2y2 = xmm13; z202 = xmm12
  m1m1 = xmm11; m2m2 = xmm10
  d0d1 = xmm8; d200 = xmm7

  movapd  dto, dt
.align 16
1:
  mov pairs, offset pairs_data
  mov pairs_index, 10

.align 16
2:
  movapd  dt, dto
  mov    _1, [pairs]
  mov    _2, [pairs + (8 * 1)]
  movapd x1y1, [_1]
  movapd z101, [_1 + (8 * 2)]

  movapd x2y2, [_2]
  movapd z202, [_2 + (8 * 2)]
  subpd  x1y1, x2y2
  movapd d0d1, x1y1
  subpd  z101, z202
  movapd d200, z101

  mulpd  x1y1, x1y1
  mulpd  z101, z101
  haddpd x1y1, z101
  haddpd x1y1, x1y1
  sqrtpd z101, x1y1
  mulpd  x1y1, z101
  divpd  dt, x1y1

  mag = dt; mag2 = xmm1
  movapd mag2, mag

  movapd m2m2, [_2 + (8 * 8)]
  movapd x1y1, d0d1
  movapd z101, d200

  v1v2 = xmm9; v300 = xmm4
  movapd v1v2, [_1 + (8 * 4)]
  movapd v300, [_1 + (8 * 6)]

  movapd m1m1, [_1 + (8 * 8)]
  movapd x2y2, d0d1
  movapd z202, d200

  v4v5 = xmm3; v600 = xmm2
  movapd v4v5, [_2 + (8 * 4)]
  movapd v600, [_2 + (8 * 6)]

  mulpd  m2m2, mag
  mulpd  x1y1, m2m2
  mulpd  z101, m2m2

  subpd  v1v2, x1y1
  subpd  v300, z101
  movapd [_1 + (8 * 4)], v1v2
  movapd [_1 + (8 * 6)], v300

  mulpd  m1m1, mag2
  mulpd  x2y2, m1m1
  mulpd  z202, m1m1

  addpd  v4v5, x2y2
  addpd  v600, z202
  movapd [_2 + (8 * 4)], v4v5
  movapd [_2 + (8 * 6)], v600

  add pairs, (8 * 2)
  sub pairs_index, 1
  jnz  2b

  bodies = rdi; bodies_length = rcx
  vxvy = xmm15; vzv0 = xmm14
  mmmm = xmm13;

  mov bodies, offset bodies_data
  mov bodies_length, 5
  movapd dt, dto

.align 16
2:
  movapd vxvy, [bodies + (8 * 4)]
  movapd vzv0, [bodies + (8 * 6)]

  mulpd  vxvy, dt
  mulpd  vzv0, dt

  addpd  vxvy, [bodies]
  addpd  vzv0, [bodies + (8 * 2)]

  movapd [bodies], vxvy
  movapd [bodies + (8 * 2)], vzv0

  add bodies, body_size
  loop 2b

  sub n, 1
  jnz  1b

  ret

